package main

import (
	"context"
	"fmt"
	"time"

	pb "mail/proto"
)

// Сервер gRPC для работы с расписанием
type grpcServer struct {
	pb.UnimplementedScheduleServiceServer
}

// Получает список факультетов
func (s *grpcServer) GetFaculties(ctx context.Context, req *pb.Empty) (*pb.FacultiesResponse, error) {
	rows, err := db.Query("SELECT id, name FROM faculties ORDER BY name")
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var faculties []*pb.Faculty
	for rows.Next() {
		var f pb.Faculty
		if err := rows.Scan(&f.Id, &f.Name); err != nil {
			continue
		}
		faculties = append(faculties, &f)
	}
	return &pb.FacultiesResponse{Faculties: faculties}, nil
}

// Получает список групп
func (s *grpcServer) GetGroups(ctx context.Context, req *pb.GroupsRequest) (*pb.GroupsResponse, error) {
	rows, err := db.Query("SELECT id, name, faculty_id, edu_form_id FROM groups WHERE faculty_id=$1 AND edu_form_id=$2 ORDER BY name", req.FacultyId, req.EduFormId)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var groups []*pb.Group
	for rows.Next() {
		var g pb.Group
		if err := rows.Scan(&g.Id, &g.Name, &g.FacultyId, &g.EduFormId); err != nil {
			continue
		}
		groups = append(groups, &g)
	}
	return &pb.GroupsResponse{Groups: groups}, nil
}

// Получает расписание группы
func (s *grpcServer) GetSchedule(ctx context.Context, req *pb.ScheduleRequest) (*pb.ScheduleResponse, error) {
	rows, err := db.Query(`SELECT id, group_id, day_of_week, subject, teacher, room, start_time, end_time, mode, subgroup FROM schedules WHERE group_id=$1 ORDER BY day_of_week, start_time, mode, subgroup`, req.GroupId)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var items []*pb.ScheduleItem
	for rows.Next() {
		var i pb.ScheduleItem
		if err := rows.Scan(
			&i.Id, &i.GroupId, &i.DayOfWeek, &i.Subject, &i.Teacher, &i.Room, &i.StartTime, &i.EndTime,
			&i.Mode, &i.Subgroup,
		); err != nil {
			continue
		}
		items = append(items, &i)
	}
	return &pb.ScheduleResponse{Schedule: items}, nil
}

// Получает даты последнего обновления
func (s *grpcServer) GetLastUpdated(ctx context.Context, req *pb.Empty) (*pb.LastUpdatedResponse, error) {
	rows, err := db.Query("SELECT table_name, last_updated FROM data_updates")
	if err != nil {
		return nil, err
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
	return &pb.LastUpdatedResponse{Updates: res}, nil
}

// Получает расписание по пути
func (s *grpcServer) GetScheduleByPath(ctx context.Context, req *pb.SGUPathRequest) (*pb.ScheduleResponse, error) {
	formName := mapForm(req.Form)
	var groupID int
	query := `SELECT g.id FROM groups g
			  JOIN faculties f ON g.faculty_id = f.id
			  JOIN edu_forms ef ON g.edu_form_id = ef.id
			  WHERE f.name = $1 AND ef.name = $2 AND g.name = $3`
	err := db.QueryRow(query, req.Faculty, formName, req.Group).Scan(&groupID)
	if err != nil {
		return nil, fmt.Errorf("group not found")
	}
	return s.GetSchedule(ctx, &pb.ScheduleRequest{GroupId: int32(groupID)})
}

// Запускает скрапинг
func (s *grpcServer) RunScrape(ctx context.Context, req *pb.Empty) (*pb.ScrapeResponse, error) {
	started, queued := requestScrape("grpc")
	return &pb.ScrapeResponse{Success: started || queued}, nil
}

// Получает статус скрапинга
func (s *grpcServer) GetScrapeStatus(ctx context.Context, req *pb.Empty) (*pb.ScrapeStatusResponse, error) {
	scrapeMu.Lock()
	st := scrapeState
	scrapeMu.Unlock()
	return &pb.ScrapeStatusResponse{
		Running:        st.Running,
		LastTrigger:    st.LastTrigger,
		LastStartedAt:  st.LastStartedAt.Format(time.RFC3339),
		LastFinishedAt: st.LastFinishedAt.Format(time.RFC3339),
		LastDurationMs: st.LastDurationMs,
		LastError:      st.LastError,
	}, nil
}
