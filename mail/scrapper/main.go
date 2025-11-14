package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/url"
	"os"
	"regexp"
	"strings"
	"sync"
	"sync/atomic"
	"time"

	"github.com/PuerkitoBio/goquery"
	"github.com/gocolly/colly/v2"
)

// ====== ДАННЫЕ

type Lesson struct {
	Time      string `json:"time"`
	Day       string `json:"day"`
	Type      string `json:"type"`
	Name      string `json:"name"`
	Teacher   string `json:"teacher"`
	Room      string `json:"room"`
	Subgroup  string `json:"subgroup"`
	Numerator bool   `json:"numerator"`
}

type GroupDoc struct {
	Faculty   string   `json:"faculty"`    // СЛАГ факультета: bf, uf, knt ...
	Group     string   `json:"group"`      // имя группы (текст ссылки или код)
	Form      string   `json:"form"`       // сырой токен: do | zo | vo
	Tag       string   `json:"tag"`        // <slug>/<form>/<code>, напр. knt/do/411
	URL       string   `json:"url"`        // полная ссылка
	UpdatedAt string   `json:"updated_at"` // "DD.MM.YYYY HH:MM" (или только дата)
	Schedule  []Lesson `json:"schedule"`   // занятия
}

type Output struct {
	GeneratedAt time.Time   `json:"generated_at"`
	Groups      []*GroupDoc `json:"groups"`
}

// ====== УТИЛИТЫ

func firstNonEmpty(s ...string) string {
	for _, v := range s {
		if strings.TrimSpace(v) != "" {
			return v
		}
	}
	return ""
}

func stripQueryAndHash(u string) string {
	if i := strings.Index(u, "#"); i >= 0 {
		u = u[:i]
	}
	if i := strings.Index(u, "?"); i >= 0 {
		u = u[:i]
	}
	return u
}

func canonicalize(raw string) string {
	raw = strings.TrimSpace(raw)
	raw = stripQueryAndHash(raw)
	// Раскодируем URL перед нормализацией
	if unescaped, err := url.QueryUnescape(raw); err == nil {
		raw = unescaped
	}
	for len(raw) > 0 && strings.HasSuffix(raw, "/") {
		raw = strings.TrimSuffix(raw, "/")
	}
	return raw
}

func pickDay(days []string, i int) string {
	if i < len(days) {
		return days[i]
	}
	return fmt.Sprintf("Day#%d", i+1)
}

// tag: первые три сегмента после /schedule/
func extractTagFromURL(u *url.URL) string {
	path := strings.TrimPrefix(u.Path, "/")
	parts := strings.Split(path, "/") // [schedule, <slug>, <form>, <code>...]
	if len(parts) == 0 || parts[0] != "schedule" {
		return ""
	}
	rest := parts[1:]
	n := 3
	if len(rest) < n {
		n = len(rest)
	}
	return strings.Join(rest[:n], "/")
}

// ====== updated_at (дата + время)
var (
	reDate = regexp.MustCompile(`\b(\d{1,2}\.\d{1,2}\.\d{2,4})\b`)                     // dd.mm.yyyy
	reTime = regexp.MustCompile(`\b([01]?\d|2[0-3])[:.]\d{2}(?::\d{2})?\b`)            // HH:MM[:SS]
	reISO  = regexp.MustCompile(`\b(\d{4}-\d{2}-\d{2})[ T](\d{2}:\d{2}(?::\d{2})?)\b`) // 2025-10-25 14:30[:ss]
)

// Возвращает "DD.MM.YYYY HH:MM" если найдено, иначе "DD.MM.YYYY", иначе "".
func extractUpdatedAtWithTime(root *goquery.Selection) string {
	// time[datetime]
	if t := root.Find("time[datetime]").First(); t.Length() > 0 {
		if dt, ok := t.Attr("datetime"); ok {
			if m := reISO.FindStringSubmatch(dt); len(m) > 0 {
				parts := strings.Split(m[1], "-")
				if len(parts) == 3 {
					ddmmyyyy := fmt.Sprintf("%s.%s.%s", parts[2], parts[1], parts[0])
					return ddmmyyyy + " " + m[2][:5]
				}
			}
			if reDate.MatchString(dt) {
				date := reDate.FindStringSubmatch(dt)[1]
				if tm := reTime.FindString(dt); tm != "" {
					return date + " " + tm[:5]
				}
				return date
			}
		}
	}
	// тексты вокруг
	candidates := []*goquery.Selection{
		root,
		root.Parent(),
		root.Siblings(),
		root.ParentsFiltered("main"),
		root.ParentsFiltered("article"),
		root.ParentsFiltered("section"),
		root.Find(".schedule__last-update, .last-update, .updated, .update, .schedule-info, .page-info, .content, .node, .pane, .meta"),
	}

	var firstTime string
	for _, sel := range candidates {
		if sel == nil || sel.Length() == 0 {
			continue
		}
		txt := strings.Join(strings.Fields(sel.Text()), " ")
		if txt == "" {
			continue
		}
		if m := reISO.FindStringSubmatch(txt); len(m) > 0 {
			parts := strings.Split(m[1], "-")
			if len(parts) == 3 {
				ddmmyyyy := fmt.Sprintf("%s.%s.%s", parts[2], parts[1], parts[0])
				return ddmmyyyy + " " + m[2][:5]
			}
		}
		if reDate.MatchString(txt) {
			date := reDate.FindStringSubmatch(txt)[1]
			if tm := reTime.FindString(txt); tm != "" {
				return date + " " + tm[:5]
			}
			if firstTime == "" {
				firstTime = reTime.FindString(txt)
			}
			if date != "" && firstTime != "" {
				return date + " " + firstTime[:5]
			}
			return date
		}
		if firstTime == "" {
			if tm := reTime.FindString(txt); tm != "" {
				firstTime = tm
			}
		}
	}
	return ""
}
func appendLesson(mu *sync.Mutex, group *GroupDoc, timeSlot, day string, lesson *goquery.Selection) {
	lessonType := ""
	switch {
	case lesson.Find(".lesson-prop__lecture, .lecture").Length() > 0:
		lessonType = "ЛЕКЦИЯ"
	case lesson.Find(".lesson-prop__practice, .practice").Length() > 0:
		lessonType = "ПРАКТИКА"
	case lesson.Find(".lesson-prop__laboratory, .laboratory, .lab").Length() > 0:
		lessonType = "ЛАБОРАТОРНАЯ"
	}

	numerator := strings.Contains(strings.ToUpper(lesson.Find(".lesson-prop__num, .num").Text()), "Ч")
	name := strings.TrimSpace(firstNonEmpty(lesson.Find(".schedule-table__lesson-name, .name").Text()))
	teacher := strings.TrimSpace(firstNonEmpty(lesson.Find(".schedule-table__lesson-teacher, .teacher").Text()))
	teacher = strings.Join(strings.Fields(strings.ReplaceAll(teacher, "\n", " ")), " ")
	room := strings.TrimSpace(firstNonEmpty(lesson.Find(".schedule-table__lesson-room span, .room, .aud, .cab").Text()))
	subgroup := strings.TrimSpace(firstNonEmpty(lesson.Find(".schedule-table__lesson-uncertain, .subgroup, .sg").Text()))

	// пустые карточки отбрасываем
	if name == "" && teacher == "" && room == "" && lessonType == "" {
		return
	}
	mu.Lock()
	group.Schedule = append(group.Schedule, Lesson{
		Time:      timeSlot,
		Day:       day,
		Type:      lessonType,
		Name:      name,
		Teacher:   teacher,
		Room:      room,
		Subgroup:  subgroup,
		Numerator: numerator,
	})
	mu.Unlock()
}

// ====== MAIN
func main() {
	const parallelism = 20 // число потоков
	c := colly.NewCollector(
		colly.AllowedDomains("sgu.ru", "www.sgu.ru"),
		colly.UserAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36"),
		colly.MaxDepth(2),
		colly.Async(true),
	)
	c.SetRequestTimeout(05 * time.Second)
	_ = c.Limit(&colly.LimitRule{
		DomainGlob:  "*sgu.ru*",
		Parallelism: parallelism,
	})
	var (
		mu           sync.Mutex
		parsedGroups uint64
		groupByURL   = make(map[string]*GroupDoc) // канонический URL → группа
		visitedLink  = make(map[string]struct{})  // защита от дублей
		output       = Output{GeneratedAt: time.Now()}
	)
	// скорость «групп/мин»
	stopGroups := startRateLoggerLabeled(&parsedGroups, 10*time.Second, "групп")
	defer stopGroups()

	// Логи только ошибок
	c.OnError(func(r *colly.Response, err error) {
		log.Printf("Ошибка %s: %v (HTTP %d)", r.Request.URL, err, r.StatusCode)
	})

	// ===== 1) /schedule: ссылки на группы /schedule/<slug>/(do|zo|vo)/<code>
	c.OnHTML("body", func(e *colly.HTMLElement) {
		if p := e.Request.URL.Path; p != "/schedule" && p != "/schedule/" {
			return
		}

		e.DOM.Find("a[href^='/schedule/']").Each(func(_ int, a *goquery.Selection) {
			href := strings.TrimSpace(a.AttrOr("href", ""))
			if href == "" {
				return
			}
			link := href
			if !strings.HasPrefix(link, "http") {
				link = "https://sgu.ru" + link
			}
			link = canonicalize(link)

			u, err := url.Parse(link)
			if err != nil {
				return
			}

			parts := strings.Split(strings.Trim(u.Path, "/"), "/")
			if len(parts) < 4 || parts[0] != "schedule" {
				return
			}
			formSeg := strings.ToLower(parts[2])
			if formSeg != "do" && formSeg != "zo" && formSeg != "vo" {
				return
			}
			slug := parts[1]
			tag := extractTagFromURL(u)
			form := formSeg // сырой токен

			groupName := strings.TrimSpace(a.Text())
			if groupName == "" {
				groupName = parts[3] // подстраховка кодом группы
			}

			mu.Lock()
			if _, ok := visitedLink[link]; ok {
				mu.Unlock()
				return
			}
			visitedLink[link] = struct{}{}

			g := &GroupDoc{
				Faculty:   slug, // теперь faculty = СЛАГ
				Group:     groupName,
				Form:      form,
				Tag:       tag,
				URL:       link,
				UpdatedAt: "",
			}
			groupByURL[link] = g
			output.Groups = append(output.Groups, g)
			mu.Unlock()

			e.Request.Visit(link)
		})
	})

	// ===== 2) Страница группы: updated_at и расписание (универсальный проход)
	c.OnHTML(".schedule-table", func(e *colly.HTMLElement) {
		urlStr := canonicalize(e.Request.URL.String())

		mu.Lock()
		group := groupByURL[urlStr]
		if group == nil {
			base := stripQueryAndHash(urlStr)
			group = groupByURL[base]
		}
		mu.Unlock()
		if group == nil {
			log.Printf("⚠️  Не нашли группу по URL: %s", urlStr)
			return
		}

		// updated_at: дата + время
		if group.UpdatedAt == "" {
			if up := extractUpdatedAtWithTime(e.DOM); up != "" {
				group.UpdatedAt = up
			}
		}

		// Дни недели
		var days []string
		if e.DOM.Find("thead tr th").Length() > 0 {
			e.DOM.Find("thead tr th").Each(func(i int, th *goquery.Selection) {
				if i == 0 {
					return
				}
				if day := strings.TrimSpace(th.Text()); day != "" {
					days = append(days, day)
				}
			})
		} else {
			e.DOM.Find(".schedule-table__day, .schedule-table__dayname, .schedule-day, .day-header").Each(func(_ int, s *goquery.Selection) {
				if day := strings.TrimSpace(s.Text()); day != "" {
					days = append(days, day)
				}
			})
		}

		// Универсальный проход по строкам и колонкам
		rowSel, colSel := "", ""
		switch {
		case e.DOM.Find(".schedule-table__row").Length() > 0:
			rowSel = ".schedule-table__row"
			colSel = ".schedule-table__col"
		case e.DOM.Find("tbody tr").Length() > 0:
			rowSel = "tbody tr"
			colSel = "td, .schedule-table__col"
		default:
			rowSel = ".schedule-row, .row, tbody tr"
			colSel = ".schedule-table__col, .day-col, .col, td"
		}

		e.DOM.Find(rowSel).Each(func(_ int, row *goquery.Selection) {
			timeSlot := strings.TrimSpace(firstNonEmpty(
				row.Find(".schedule-table__header").First().Text(),
				row.Find("th .schedule-table__header").Text(),
				row.Find("th").First().Text(),
				row.Find(".time, .pair-time, .slot").First().Text(),
			))
			timeSlot = strings.ReplaceAll(timeSlot, "\n", "-")
			timeSlot = strings.Join(strings.Fields(timeSlot), " ")

			row.Find(colSel).Each(func(dayIndex int, col *goquery.Selection) {
				day := pickDay(days, dayIndex)
				col.Find(".schedule-table__lesson, .lesson, .pair").Each(func(_ int, lesson *goquery.Selection) {
					appendLesson(&mu, group, timeSlot, day, lesson)
				})
			})
		})

		atomic.AddUint64(&parsedGroups, 1) // считаем группу ровно один раз
	})

	// Старт
	if err := c.Visit("https://sgu.ru/schedule"); err != nil {
		log.Fatal("Ошибка загрузки главной страницы:", err)
	}
	c.Wait()

	buf, err := json.MarshalIndent(output, "", "  ")
	if err != nil {
		log.Fatal(err)
	}
	if err := os.WriteFile("schedule.json", buf, 0o644); err != nil {
		log.Fatal(err)
	}
	log.Printf("Готово: schedule.json. Всего групп: %d", len(output.Groups))

	totalLessons := 0
	for _, g := range output.Groups {
		totalLessons += len(g.Schedule)
	}
	fmt.Printf("Total groups: %d, total lessons: %d\n", len(output.Groups), totalLessons)
}

// ===== логгер скорости (групп/мин)

func startRateLoggerLabeled(counter *uint64, interval time.Duration, label string) func() {
	done := make(chan struct{})
	start := time.Now()
	ticker := time.NewTicker(interval)

	go func() {
		for {
			select {
			case <-ticker.C:
				total := atomic.LoadUint64(counter)
				mins := time.Since(start).Minutes()
				if mins <= 0 {
					mins = 1.0 / 60.0
				}
				rate := float64(total) / mins
				log.Printf("Средняя скорость (%s): %.2f /мин (всего: %d, прошло: %s)",
					label, rate, total, time.Since(start).Truncate(time.Second))
			case <-done:
				ticker.Stop()
				total := atomic.LoadUint64(counter)
				mins := time.Since(start).Minutes()
				if mins <= 0 {
					mins = 1.0 / 60.0
				}
				rate := float64(total) / mins
				log.Printf("Итоговая средняя скорость (%s): %.2f /мин (всего: %d, прошло: %s)",
					label, rate, total, time.Since(start).Truncate(time.Second))
				return
			}
		}
	}()
	return func() { close(done) }
}
