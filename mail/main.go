package main

import (
	"bufio"
	"context"
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
	"sync"
	"time"

	"github.com/gorilla/rpc"
	jsonrpc "github.com/gorilla/rpc/json"

	_ "github.com/lib/pq"
	"github.com/segmentio/kafka-go"
)

var db *sql.DB
var kafkaWriterScrape *kafka.Writer
var kafkaWriterScrapeError *kafka.Writer
var kafkaTopicScrape string
var kafkaTopicScrapeError string
var kafkaBrokers []string
var kafkaTopicScrapeCommands string

type scrapeRunState struct {
	Running        bool      `json:"running"`
	LastTrigger    string    `json:"last_trigger"` //Кто инициировал запуск скрапинга
	LastStartedAt  time.Time `json:"last_started_at"`
	LastFinishedAt time.Time `json:"last_finished_at"`
	LastDurationMs int64     `json:"last_duration_ms"`
	LastError      string    `json:"last_error"`
}

var scrapeMu sync.Mutex
var scrapeState scrapeRunState
var scrapePending bool
var scrapePendingTrigger string

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
	kafkaWriterScrape, kafkaWriterScrapeError, kafkaTopicScrape, kafkaTopicScrapeError = initKafkaFromEnv()
	if kafkaWriterScrape != nil {
		defer kafkaWriterScrape.Close()
	}
	if kafkaWriterScrapeError != nil {
		defer kafkaWriterScrapeError.Close()
	}
	startKafkaScrapeCommandConsumer()

	r := mux.NewRouter()

	// Эндпоинты заготовки
	r.HandleFunc("/faculties", GetFaculties).Methods("GET")
	r.HandleFunc("/groups", GetGroups).Methods("GET")
	r.HandleFunc("/schedule", GetSchedule).Methods("GET")
	r.HandleFunc("/last_updated", GetLastUpdated).Methods("GET")
	r.HandleFunc("/scrape/run", RunScrapeNow).Methods("POST")
	r.HandleFunc("/scrape/status", GetScrapeStatus).Methods("GET")

	// Роуты в стиле SGU: /faculty/form/group
	r.HandleFunc("/{faculty}/{form}/{group}", GetScheduleBySGUPath).Methods("GET")

	log.Println("Server started on :8081")

	go func() {
		interval := 1 * time.Hour
		if err := runScrapeAndUpsert(); err != nil {
			log.Printf("background scrape error: %v", err)
		}
		// первый прогон при старте
		_ = startScrapeAsync("startup")
		ticker := time.NewTicker(interval)
		defer ticker.Stop()
		for range ticker.C {
			_ = startScrapeAsync("interval")
		}
	}()

	http.ListenAndServe("0.0.0.0:8081", nil)
}

func initKafkaFromEnv() (*kafka.Writer, *kafka.Writer, string, string) {
	brokersRaw := strings.TrimSpace(os.Getenv("KAFKA_BROKERS"))
	if brokersRaw == "" {
		return nil, nil, "", ""
	}
	topic := strings.TrimSpace(os.Getenv("KAFKA_TOPIC_SCRAPE"))
	if topic == "" {
		topic = "schedule.scrape.finished"
	}
	topicErr := strings.TrimSpace(os.Getenv("KAFKA_TOPIC_SCRAPE_ERROR"))
	if topicErr == "" {
		topicErr = "schedule.scrape.failed"
	}

	var brokers []string
	for _, part := range strings.Split(brokersRaw, ",") {
		b := strings.TrimSpace(part)
		if b != "" {
			brokers = append(brokers, b)
		}
	}
	if len(brokers) == 0 {
		return nil, nil, "", ""
	}
	kafkaBrokers = brokers

	ensureKafkaTopic(brokers[0], topic)
	ensureKafkaTopic(brokers[0], topicErr)
	kafkaTopicScrapeCommands = strings.TrimSpace(os.Getenv("KAFKA_TOPIC_SCRAPE_COMMANDS"))
	if kafkaTopicScrapeCommands == "" {
		kafkaTopicScrapeCommands = "schedule.scrape.commands"
	}
	ensureKafkaTopic(brokers[0], kafkaTopicScrapeCommands)

	wScrape := &kafka.Writer{
		Addr:     kafka.TCP(brokers...),
		Topic:    topic,
		Balancer: &kafka.LeastBytes{},
	}
	wErr := &kafka.Writer{
		Addr:     kafka.TCP(brokers...),
		Topic:    topicErr,
		Balancer: &kafka.LeastBytes{},
	}

	return wScrape, wErr, topic, topicErr
}

func ensureKafkaTopic(broker, topic string) {
	if strings.TrimSpace(broker) == "" || strings.TrimSpace(topic) == "" {
		return
	}

	for attempt := 1; attempt <= 10; attempt++ {
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		dialer := &kafka.Dialer{Timeout: 5 * time.Second}
		conn, err := dialer.DialContext(ctx, "tcp", broker)
		cancel()
		if err != nil {
			time.Sleep(1 * time.Second)
			continue
		}

		err = conn.CreateTopics(kafka.TopicConfig{
			Topic:             topic,
			NumPartitions:     1,
			ReplicationFactor: 1,
		})
		_ = conn.Close()

		if err == nil {
			return
		}
		if strings.Contains(strings.ToLower(err.Error()), "already exists") {
			return
		}
		time.Sleep(1 * time.Second)
	}
}

func startScrapeAsync(trigger string) bool {
	started, _ := requestScrape(trigger)
	return started
}

func requestScrape(trigger string) (bool, bool) {
	scrapeMu.Lock()
	if scrapeState.Running {
		scrapePending = true
		scrapePendingTrigger = trigger
		scrapeMu.Unlock()
		return false, true
	}
	scrapeState.Running = true
	scrapeState.LastTrigger = trigger
	startedAt := time.Now()
	scrapeState.LastStartedAt = startedAt
	scrapeState.LastError = ""
	scrapeMu.Unlock()

	startScrapeWorker(trigger, startedAt)
	return true, false
}

func startScrapeWorker(trigger string, startedAt time.Time) {
	go func(startedAt time.Time) {
		err := runScrapeAndUpsert()
		finishedAt := time.Now()

		scrapeMu.Lock()
		scrapeState.Running = false
		scrapeState.LastFinishedAt = finishedAt
		scrapeState.LastDurationMs = finishedAt.Sub(startedAt).Milliseconds()
		if err != nil {
			scrapeState.LastError = err.Error()
		}
		shouldStartNext := scrapePending
		nextTrigger := scrapePendingTrigger
		scrapePending = false
		scrapePendingTrigger = ""
		scrapeMu.Unlock()

		if shouldStartNext {
			_, _ = requestScrape(nextTrigger)
		}
	}(startedAt)
}

func RunScrapeNow(w http.ResponseWriter, r *http.Request) {
	started, queued := requestScrape("manual")
	if started || queued {
		w.WriteHeader(http.StatusAccepted)
		return
	}
	http.Error(w, "scrape not started", http.StatusInternalServerError)
}

func GetScrapeStatus(w http.ResponseWriter, r *http.Request) {
	scrapeMu.Lock()
	st := scrapeState
	scrapeMu.Unlock()

	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(st)
}

type scrapeCommand struct {
	Action string `json:"action"`
}

func startKafkaScrapeCommandConsumer() {
	if len(kafkaBrokers) == 0 || strings.TrimSpace(kafkaTopicScrapeCommands) == "" {
		return
	}

	r := kafka.NewReader(kafka.ReaderConfig{
		Brokers:     kafkaBrokers,
		Topic:       kafkaTopicScrapeCommands,
		Partition:   0,
		MinBytes:    1,
		MaxBytes:    10e6,
		StartOffset: kafka.LastOffset,
	})

	go func() {
		log.Printf("kafka command consumer started: topic=%s", kafkaTopicScrapeCommands)
		for {
			msg, err := r.ReadMessage(context.Background())
			if err != nil {
				time.Sleep(1 * time.Second)
				continue
			}

			action := strings.TrimSpace(string(msg.Value))
			var cmd scrapeCommand
			if json.Unmarshal(msg.Value, &cmd) == nil {
				if strings.TrimSpace(cmd.Action) != "" {
					action = strings.TrimSpace(cmd.Action)
				}
			}
			action = strings.ToLower(action)

			if action == "run" || action == "scrape" || action == "start" {
				started, queued := requestScrape("kafka")
				if started {
					log.Printf("scrape triggered by kafka: topic=%s", kafkaTopicScrapeCommands)
				} else if queued {
					log.Printf("scrape queued by kafka: topic=%s", kafkaTopicScrapeCommands)
				}
			}
		}
	}()
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

type scrapeFinishedEvent struct {
	Type 		 string    `json:"type"`
	GeneratedAt  time.Time `json:"generated_at"`
	PublishedAt  time.Time `json:"published_at"`
	GroupsCount  int       `json:"groups_count"`
	TotalLessons int       `json:"total_lessons"`
	DurationMs   int64     `json:"duration_ms"`
}

type scrapeFailedEvent struct {
	Type   	    string    `json:"type"`
	Stage       string    `json:"stage"`
	Error       string    `json:"error"`
	Details     string    `json:"details"`
	PublishedAt time.Time `json:"published_at"`
	DurationMs  int64     `json:"duration_ms"`
}

func publishScrapeFinished(generatedAt time.Time, groupsCount, totalLessons int, duration time.Duration) {
	if kafkaWriterScrape == nil {
		return
	}

	ev := scrapeFinishedEvent{
		Type:         "schedule.scrape.finished",
		GeneratedAt:  generatedAt,
		PublishedAt:  time.Now(),
		GroupsCount:  groupsCount,
		TotalLessons: totalLessons,
		DurationMs:   duration.Milliseconds(),
	}
	b, err := json.Marshal(ev)
	if err != nil {
		log.Printf("kafka marshal error: %v", err)
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := kafkaWriterScrape.WriteMessages(ctx, kafka.Message{Key: []byte("scrape"), Value: b}); err != nil {
		log.Printf("kafka publish error: %v", err)
	}
}

func publishScrapeFailed(stage string, scrapeErr error, details string, duration time.Duration) {
	if kafkaWriterScrapeError == nil {
		return
	}

	ev := scrapeFailedEvent{
		Type:        "schedule.scrape.failed",
		Stage:       strings.TrimSpace(stage),
		Error:       errorString(scrapeErr),
		Details:     truncateString(details, 4000),
		PublishedAt: time.Now(),
		DurationMs:  duration.Milliseconds(),
	}

	b, err := json.Marshal(ev)
	if err != nil {
		log.Printf("kafka marshal error: %v", err)
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := kafkaWriterScrapeError.WriteMessages(ctx, kafka.Message{Key: []byte("scrape_error"), Value: b}); err != nil {
		log.Printf("kafka publish error: %v", err)
	}
}

func errorString(err error) string {
	if err == nil {
		return ""
	}
	return err.Error()
}

func truncateString(s string, max int) string {
	s = strings.TrimSpace(s)
	if max <= 0 {
		return ""
	}
	if len(s) <= max {
		return s
	}
	return s[:max]
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
		publishScrapeFailed("scrapper_stdout_pipe", err, "", time.Since(startTime))
		return err
	}
	stderr, err := cmd.StderrPipe()
	if err != nil {
		publishScrapeFailed("scrapper_stderr_pipe", err, "", time.Since(startTime))
		return err
	}

	if err := cmd.Start(); err != nil {
		log.Printf("ERROR Ошибка запуска парсера: %v", err)
		publishScrapeFailed("scrapper_start", err, "", time.Since(startTime))
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
		publishScrapeFailed("scrapper_wait", err, string(stderrOut), time.Since(startTime))
		return err
	}

	// 2) Прочитать schedule.json из директории scrapper
	data, err := os.ReadFile(filepath.Join(scrapperDir, "schedule.json"))
	if err != nil {
		log.Printf("Ошибка чтения schedule.json: %v", err)
		publishScrapeFailed("read_schedule_json", err, "", time.Since(startTime))
		return err
	}
	var outJSON scrapedOutput
	if err := json.Unmarshal(data, &outJSON); err != nil {
		log.Printf("Ошибка парсинга JSON: %v", err)
		publishScrapeFailed("parse_schedule_json", err, "", time.Since(startTime))
		return err
	}

	groupsCount := len(outJSON.Groups)
	totalLessons := 0
	for _, g := range outJSON.Groups {
		if g != nil {
			totalLessons += len(g.Schedule)
		}
	}
	publishScrapeFinished(outJSON.GeneratedAt, groupsCount, totalLessons, time.Since(startTime))

	// 3) Маппинг форм обучения do/zo/vo (теперь используется глобальная функция)

	// 4) Вставка в БД
	var firstUpsertErr error
	for _, g := range outJSON.Groups {
		if g == nil {
			continue
		}
		// faculty: используем slug как имя
		if err := UpsertFaculty(g.Faculty); err != nil {
			log.Printf("upsert faculty error: %v", err)
			if firstUpsertErr == nil {
				firstUpsertErr = err
			}
		}
		// edu form id
		eduFormName := mapForm(g.Form)
		if err := UpsertEduForm(eduFormName); err != nil {
			log.Printf("upsert edu_form error: %v", err)
			if firstUpsertErr == nil {
				firstUpsertErr = err
			}
		}
		// получить id факультета и формы для связи группы
		var facultyID, eduFormID, groupID int
		_ = db.QueryRow("SELECT id FROM faculties WHERE name=$1", g.Faculty).Scan(&facultyID)
		_ = db.QueryRow("SELECT id FROM edu_forms WHERE name=$1", eduFormName).Scan(&eduFormID)
		if err := UpsertGroup(g.Group, facultyID, eduFormID); err != nil {
			log.Printf("upsert group error: %v", err)
			if firstUpsertErr == nil {
				firstUpsertErr = err
			}
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
				if firstUpsertErr == nil {
					firstUpsertErr = err
				}
			}
		}
	}

	// Логирование результатов
	duration := time.Since(startTime)

	speed := float64(groupsCount) / duration.Minutes()
	if speed < 1 {
		speed = float64(groupsCount) / (duration.Seconds() / 60)
	}

	log.Printf(" Парсер завершен:")
	log.Printf("    Время выполнения: %s", duration.Round(time.Second))
	log.Printf("    Обработано групп: %d", groupsCount)
	log.Printf("    Всего занятий: %d", totalLessons)
	log.Printf("    Средняя скорость: %.2f групп/мин", speed)

	if firstUpsertErr != nil {
		publishScrapeFailed("db_upsert", firstUpsertErr, "", duration)
	}

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
