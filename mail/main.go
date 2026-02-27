package main

import (
	"bufio"
	"database/sql"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"

	"github.com/gorilla/rpc"
	jsonrpc "github.com/gorilla/rpc/json"

	_ "github.com/lib/pq"
)

var db *sql.DB

// --- Модели данных

type Faculty struct {
	ID   int    `json:"id"`
	Name string `json:"name"`
}

type EduForm struct {
	ID   int    `json:"id"`
	Name string `json:"name"`
}

type Group struct {
	ID        int    `json:"id"`
	Name      string `json:"name"`
	FacultyID int    `json:"faculty_id"`
	EduFormID int    `json:"edu_form_id"`
}

type Schedule struct {
	ID        int    `json:"id"`
	GroupID   int    `json:"group_id"`
	DayOfWeek int    `json:"day_of_week"`
	LessonNum int    `json:"lesson_num"`
	Subject   string `json:"subject"`
	Teacher   string `json:"teacher"`
	Room      string `json:"room"`
	StartTime string `json:"start_time"`
	EndTime   string `json:"end_time"`
	// Mode: "числитель", "знаменатель" или "оба"
	Mode     string `json:"mode"`
	Subgroup int    `json:"subgroup"`
}

type DataUpdate struct {
	TableName   string `json:"table_name"`
	LastUpdated string `json:"last_updated"`
}

// Создать таблицы при старте
func createTables() error {
	queries := []string{
		`CREATE TABLE IF NOT EXISTS faculties (
			id SERIAL PRIMARY KEY,
			name TEXT UNIQUE
		);`,
		`CREATE TABLE IF NOT EXISTS edu_forms (
			id SERIAL PRIMARY KEY,
			name TEXT UNIQUE
		);`,
		`CREATE TABLE IF NOT EXISTS groups (
			id SERIAL PRIMARY KEY,
			name TEXT,
			faculty_id INT REFERENCES faculties(id),
			edu_form_id INT REFERENCES edu_forms(id),
			UNIQUE(name, faculty_id, edu_form_id)
		);`,
		`CREATE TABLE IF NOT EXISTS schedules (
			id SERIAL PRIMARY KEY,
			group_id INT REFERENCES groups(id),
			day_of_week INT,
			lesson_num INT,
			subject TEXT,
			teacher TEXT,
			room TEXT,
			start_time TEXT,
			end_time TEXT,
			mode TEXT,
			subgroup INT,
			UNIQUE(group_id, day_of_week, lesson_num, subject, teacher, room, mode, subgroup)
		);`,
		`CREATE TABLE IF NOT EXISTS data_updates (
			table_name TEXT PRIMARY KEY,
			last_updated TIMESTAMP
		);`,
	}
	for _, q := range queries {
		_, err := db.Exec(q)
		if err != nil {
			return err
		}
	}
	return nil
}

func main() {
	var err error
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		dbURL = "postgres://postgres_user:postgres_password@localhost:5432/postgres_db?sslmode=disable"
	}

	db, err = sql.Open("postgres", dbURL)
	if err != nil {
		log.Fatalf("error connecting to DB: %v", err)
	}
	if err = db.Ping(); err != nil {
		log.Fatalf("DB not available: %v", err)
	}

	if err = createTables(); err != nil {
		log.Fatalf("db migration failed: %v", err)
	}

	s := rpc.NewServer()
	s.RegisterCodec(jsonrpc.NewCodec(), "application/json")
	s.RegisterCodec(jsonrpc.NewCodec(), "application/json;charset=UTF-8")
	_ = s.RegisterService(new(API), "")
	http.Handle("/rpc", s)
	log.Println("Server started on :8081")

	go func() {
		interval := 1 * time.Hour
		if err := runScrapeAndUpsert(); err != nil {
			log.Printf("background scrape error: %v", err)
		}
		ticker := time.NewTicker(interval)
		defer ticker.Stop()
		for range ticker.C {
			if err := runScrapeAndUpsert(); err != nil {
				log.Printf("background scrape error: %v", err)
			}
		}
	}()

	http.ListenAndServe("0.0.0.0:8081", nil)
}

// --- Интеграция с scrapper.go ---

// Маппинг форм обучения do/zo/vo из URL в БД
func mapForm(formSlug string) string {
	switch formSlug {
	case "do":
		return "очная"
	case "zo":
		return "заочная"
	case "vo":
		return "вечерняя"
	default:
		return formSlug
	}
}

// структуры под чтение schedule.json от scrapper.go.  (Куча хлама, из-за 2 версии скрапера)
type NumeratorAny struct {
	Val int
}

func (n *NumeratorAny) UnmarshalJSON(b []byte) error {
	var asBool bool
	if err := json.Unmarshal(b, &asBool); err == nil {
		if asBool {
			n.Val = 1
		} else {
			n.Val = 2
		}
		return nil
	}
	var asInt int
	if err := json.Unmarshal(b, &asInt); err == nil {
		n.Val = asInt
		return nil
	}
	var asStr string
	if err := json.Unmarshal(b, &asStr); err == nil {
		s := strings.ToLower(strings.TrimSpace(asStr))
		switch s {
		case "числитель", "num", "ч", "true": //для разных версий парсера, чтобы не было багов нужно учесть все возможные варианты
			n.Val = 1
		case "знаменатель", "denom", "з", "false":
			n.Val = 2
		default:
			n.Val = 0
		}
		return nil
	}
	return fmt.Errorf("invalid numerator")
}

type scrapedLesson struct {
	Time      string       `json:"time"`
	Day       string       `json:"day"`
	Type      string       `json:"type"`
	Name      string       `json:"name"`
	Teacher   string       `json:"teacher"`
	Room      string       `json:"room"`
	Subgroup  string       `json:"subgroup"`
	Numerator NumeratorAny `json:"numerator"`
}

type scrapedGroup struct {
	Faculty   string          `json:"faculty"`
	Group     string          `json:"group"`
	Form      string          `json:"form"`
	Tag       string          `json:"tag"`
	URL       string          `json:"url"`
	UpdatedAt string          `json:"updated_at"`
	Schedule  []scrapedLesson `json:"schedule"`
}

type scrapedOutput struct {
	GeneratedAt time.Time       `json:"generated_at"`
	Groups      []*scrapedGroup `json:"groups"`
}

func runScrapeAndUpsert() error {
	startTime := time.Now()
	log.Println("Запуск парсера расписаний...")

	// 1) Запустить парсер: go run main.go
	workDir, _ := os.Getwd()
	scrapperDir := filepath.Join(workDir, "scrapper")
	cmd := exec.Command("go", "run", "main.go")
	cmd.Dir = scrapperDir
	cmd.Env = os.Environ()
	log.Println("Парсер выполняется...")

	// Создаем пайп для получения вывода парсера
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		return err
	}
	stderr, err := cmd.StderrPipe()
	if err != nil {
		return err
	}

	if err := cmd.Start(); err != nil {
		log.Printf("ERROR Ошибка запуска парсера: %v", err)
		return err
	}

	// Логируем вывод парсера
	go func() {
		scanner := bufio.NewScanner(stdout)
		for scanner.Scan() {
			log.Printf("[PARSER] %s", scanner.Text())
		}
	}()

	go func() {
		scanner := bufio.NewScanner(stderr)
		for scanner.Scan() {
			log.Printf("[PARSER STAT] %s", scanner.Text())
		}
	}()

	err = cmd.Wait()
	_, _ = io.ReadAll(stdout)
	stderrOut, _ := io.ReadAll(stderr)

	if err != nil {
		log.Printf("Ошибка выполнения парсера: %s", string(stderrOut))
		return err
	}

	// 2) Прочитать schedule.json из директории scrapper
	data, err := os.ReadFile(filepath.Join(scrapperDir, "schedule.json"))
	if err != nil {
		log.Printf("Ошибка чтения schedule.json: %v", err)
		return err
	}
	var outJSON scrapedOutput
	if err := json.Unmarshal(data, &outJSON); err != nil {
		log.Printf("Ошибка парсинга JSON: %v", err)
		return err
	}

	// 3) Маппинг форм обучения do/zo/vo (теперь используется глобальная функция)

	// 4) Вставка в БД
	for _, g := range outJSON.Groups {
		if g == nil {
			continue
		}
		// faculty: используем slug как имя
		if err := UpsertFaculty(g.Faculty); err != nil {
			log.Printf("upsert faculty error: %v", err)
		}
		// edu form id
		eduFormName := mapForm(g.Form)
		if err := UpsertEduForm(eduFormName); err != nil {
			log.Printf("upsert edu_form error: %v", err)
		}
		// получить id факультета и формы для связи группы
		var facultyID, eduFormID, groupID int
		_ = db.QueryRow("SELECT id FROM faculties WHERE name=$1", g.Faculty).Scan(&facultyID)
		_ = db.QueryRow("SELECT id FROM edu_forms WHERE name=$1", eduFormName).Scan(&eduFormID)
		if err := UpsertGroup(g.Group, facultyID, eduFormID); err != nil {
			log.Printf("upsert group error: %v", err)
		}
		_ = db.QueryRow("SELECT id FROM groups WHERE name=$1 AND faculty_id=$2 AND edu_form_id=$3", g.Group, facultyID, eduFormID).Scan(&groupID)

		// расписание
		for _, l := range g.Schedule {
			day := normalizeDayOfWeek(l.Day)
			start, end := splitTime(l.Time)
			mode := "знаменатель"
			if l.Numerator.Val == 1 {
				mode = "числитель"
			} else if l.Numerator.Val == 0 {
				mode = "оба"
			}
			subgroup := parseSubgroup(l.Subgroup)
			s := Schedule{
				GroupID:   groupID,
				DayOfWeek: day,
				LessonNum: 0,
				Subject:   l.Name,
				Teacher:   l.Teacher,
				Room:      l.Room,
				StartTime: start,
				EndTime:   end,
				Mode:      mode,
				Subgroup:  subgroup,
			}
			if err := UpsertSchedule(s); err != nil {
				log.Printf("upsert schedule error: %v", err)
			}
		}
	}

	// Логирование результатов
	duration := time.Since(startTime)
	groupsCount := len(outJSON.Groups)
	totalLessons := 0
	for _, g := range outJSON.Groups {
		if g != nil {
			totalLessons += len(g.Schedule)
		}
	}

	speed := float64(groupsCount) / duration.Minutes()
	if speed < 1 {
		speed = float64(groupsCount) / (duration.Seconds() / 60)
	}

	log.Printf(" Парсер завершен:")
	log.Printf("    Время выполнения: %s", duration.Round(time.Second))
	log.Printf("    Обработано групп: %d", groupsCount)
	log.Printf("    Всего занятий: %d", totalLessons)
	log.Printf("    Средняя скорость: %.2f групп/мин", speed)

	return nil
}

func runCmd(name string, args ...string) error {
	cmd := exec.Command(name, args...)
	cmd.Env = os.Environ()
	out, err := cmd.CombinedOutput()
	if err != nil {
		log.Printf("cmd '%s %v' failed: %v; out: %s", name, args, err, string(out))
	}
	return err
}

func normalizeDayOfWeek(day string) int {
	d := strings.ToLower(strings.TrimSpace(day))
	switch d {
	case "пн", "пон", "понедельник":
		return 1
	case "вт", "вторник":
		return 2
	case "ср", "среда":
		return 3
	case "чт", "четверг":
		return 4
	case "пт", "пятница":
		return 5
	case "сб", "суббота":
		return 6
	case "вс", "воскресенье":
		return 7
	default:
		return 0
	}
}

func splitTime(ts string) (string, string) {
	parts := strings.Split(ts, "-")
	if len(parts) >= 2 {
		return strings.TrimSpace(parts[0]), strings.TrimSpace(parts[1])
	}
	return "", ""
}

func parseSubgroup(s string) int {
	s = strings.TrimSpace(s)
	if s == "" {
		return 0
	}
	if s == "1" {
		return 1
	}
	if s == "2" {
		return 2
	}
	return 0
}

 

// --- UPSERT-функции для заполнения БД ---

func UpsertFaculty(name string) error {
	_, err := db.Exec(`INSERT INTO faculties (name) VALUES ($1)
		ON CONFLICT (name) DO NOTHING`, name)
	if err == nil {
		updateLastUpdated("faculties")
	}
	return err
}

func UpsertEduForm(name string) error {
	_, err := db.Exec(`INSERT INTO edu_forms (name) VALUES ($1)
		ON CONFLICT (name) DO NOTHING`, name)
	if err == nil {
		updateLastUpdated("edu_forms")
	}
	return err
}

func UpsertGroup(name string, facultyID, eduFormID int) error {
	_, err := db.Exec(`INSERT INTO groups (name, faculty_id, edu_form_id) VALUES ($1, $2, $3)
		ON CONFLICT (name, faculty_id, edu_form_id) DO NOTHING`, name, facultyID, eduFormID)
	if err == nil {
		updateLastUpdated("groups")
	}
	return err
}

func UpsertSchedule(s Schedule) error {
	_, err := db.Exec(`INSERT INTO schedules (
		group_id, day_of_week, lesson_num, subject, teacher, room, start_time, end_time, mode, subgroup) VALUES
		($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
		ON CONFLICT (group_id, day_of_week, lesson_num, subject, teacher, room, mode, subgroup) DO NOTHING`,
		s.GroupID, s.DayOfWeek, s.LessonNum, s.Subject, s.Teacher, s.Room,
		s.StartTime, s.EndTime, s.Mode, s.Subgroup,
	)
	if err == nil {
		updateLastUpdated("schedules")
	}
	return err
}

func updateLastUpdated(table string) {
	_, _ = db.Exec(`INSERT INTO data_updates (table_name, last_updated) VALUES ($1, NOW()) ON CONFLICT (table_name) DO UPDATE SET last_updated=EXCLUDED.last_updated WHERE data_updates.last_updated < EXCLUDED.last_updated`, table)
}

// Получить id формы обучения по имени, создать если надо
func UpsertEduFormIfNotExistsByName(name string) (int, error) {
	var id int
	err := db.QueryRow("SELECT id FROM edu_forms WHERE name = $1", name).Scan(&id)
	if err == sql.ErrNoRows {
		err2 := db.QueryRow(`INSERT INTO edu_forms (name) VALUES ($1) RETURNING id`, name).Scan(&id)
		return id, err2
	} else if err != nil {
		return 0, err
	}
	return id, nil
}

type API struct{}

type EmptyArgs struct{}
type GroupsArgs struct {
	FacultyID int `json:"faculty_id"`
	EduFormID int `json:"edu_form_id"`
}
type ScheduleArgs struct {
	GroupID int `json:"group_id"`
}
type SGUPathArgs struct {
	Faculty string `json:"faculty"`
	Form    string `json:"form"`
	Group   string `json:"group"`
}

func (a *API) GetFaculties(_ *http.Request, _ *EmptyArgs, reply *[]Faculty) error {
	rows, err := db.Query("SELECT id, name FROM faculties ORDER BY name")
	if err != nil {
		return err
	}
	defer rows.Close()
	var res []Faculty
	for rows.Next() {
		var f Faculty
		if err := rows.Scan(&f.ID, &f.Name); err != nil {
			continue
		}
		res = append(res, f)
	}
	*reply = res
	return nil
}

func (a *API) GetGroups(_ *http.Request, args *GroupsArgs, reply *[]Group) error {
	if args == nil || args.FacultyID == 0 || args.EduFormID == 0 {
		return fmt.Errorf("faculty_id and edu_form_id required")
	}
	rows, err := db.Query("SELECT id, name, faculty_id, edu_form_id FROM groups WHERE faculty_id=$1 AND edu_form_id=$2 ORDER BY name", args.FacultyID, args.EduFormID)
	if err != nil {
		return err
	}
	defer rows.Close()
	var res []Group
	for rows.Next() {
		var g Group
		if err := rows.Scan(&g.ID, &g.Name, &g.FacultyID, &g.EduFormID); err != nil {
			continue
		}
		res = append(res, g)
	}
	*reply = res
	return nil
}

func (a *API) GetSchedule(_ *http.Request, args *ScheduleArgs, reply *[]Schedule) error {
	if args == nil || args.GroupID == 0 {
		return fmt.Errorf("group_id required")
	}
	rows, err := db.Query(`SELECT id, group_id, day_of_week, lesson_num, subject, teacher, room, start_time, end_time, mode, subgroup FROM schedules WHERE group_id=$1 ORDER BY day_of_week, lesson_num, mode, subgroup`, args.GroupID)
	if err != nil {
		return err
	}
	defer rows.Close()
	var res []Schedule
	for rows.Next() {
		var s Schedule
		if err := rows.Scan(
			&s.ID, &s.GroupID, &s.DayOfWeek, &s.LessonNum,
			&s.Subject, &s.Teacher, &s.Room, &s.StartTime, &s.EndTime,
			&s.Mode, &s.Subgroup,
		); err != nil {
			continue
		}
		res = append(res, s)
	}
	*reply = res
	return nil
}

func (a *API) GetLastUpdated(_ *http.Request, _ *EmptyArgs, reply *map[string]string) error {
	rows, err := db.Query("SELECT table_name, last_updated FROM data_updates")
	if err != nil {
		return err
	}
	defer rows.Close()
	res := map[string]string{}
	for rows.Next() {
		var t, d string
		if err := rows.Scan(&t, &d); err != nil {
			continue
		}
		res[t] = d
	}
	*reply = res
	return nil
}

func (a *API) GetScheduleByPath(_ *http.Request, args *SGUPathArgs, reply *[]Schedule) error {
	if args == nil || args.Faculty == "" || args.Form == "" || args.Group == "" {
		return fmt.Errorf("faculty, form and group required")
	}
	formName := mapForm(args.Form)
	var groupID int
	query := `SELECT g.id FROM groups g
			  JOIN faculties f ON g.faculty_id = f.id
			  JOIN edu_forms ef ON g.edu_form_id = ef.id
			  WHERE f.name = $1 AND ef.name = $2 AND g.name = $3`
	err := db.QueryRow(query, args.Faculty, formName, args.Group).Scan(&groupID)
	if err != nil {
		return fmt.Errorf("group not found")
	}
	return a.GetSchedule(nil, &ScheduleArgs{GroupID: groupID}, reply)
}
