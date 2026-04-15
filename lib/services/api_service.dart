import 'package:grpc/grpc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../generated/schedule.pbgrpc.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  static String get host {
    return '155.212.247.36';
  }

  static const int port = 8082;

  late ClientChannel _channel;
  late ScheduleServiceClient _stub;

  ApiService._internal() {
    _channel = ClientChannel(
      host,
      port: port,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    _stub = ScheduleServiceClient(_channel);
  }

  Future<List<dynamic>> getFaculties() async {
    try {
      print('🔄 Загружаем факультеты через gRPC: $host:$port');

      final response = await _stub
          .getFaculties(Empty())
          .timeout(const Duration(seconds: 10));

      print('✅ Факультеты - Получено: ${response.faculties.length}');

      if (response.faculties.isEmpty) {
        print('⚠️ Сервер вернул пустой список факультетов!');
      }

      final data = response.faculties.map((f) {
        return {
          'id': f.id,
          'name': f
              .name, // gRPC поле name -> в модели Faculty.fromJson попадет в code
        };
      }).toList();

      // Кэшируем список факультетов
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_faculties', json.encode(data));

      return data;
    } catch (e) {
      print(' Ошибка gRPC загрузки факультетов: $e');

      // Пытаемся загрузить из кэша
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cached_faculties');
      if (cached != null) {
        print(' Загружены факультеты из кэша (offline)');
        return json.decode(cached);
      }
      rethrow;
    }
  }

  Future<List<dynamic>> getGroups(int facultyId, int eduFormId) async {
    try {
      print(
          '🔄 Загружаем группы для факультета: $facultyId, формы: $eduFormId через gRPC');

      final response = await _stub
          .getGroups(
            GroupsRequest()
              ..facultyId = facultyId
              ..eduFormId = eduFormId,
          )
          .timeout(const Duration(seconds: 10));

      print('✅ Группы - Получено: ${response.groups.length}');

      final data = response.groups.map((g) {
        // Извлекаем курс из названия группы ("411" -> 4)
        int course = 1;
        if (g.name.isNotEmpty) {
          final firstDigit = g.name.substring(0, 1);
          course = int.tryParse(firstDigit) ?? 1;
        }

        return {
          'id': g.id,
          'name': g.name,
          'course': course,
          'faculty_id': facultyId,
          'edu_form_id': eduFormId,
        };
      }).toList();

      // Кэшируем список групп для этого сочетания
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'cached_groups_${facultyId}_$eduFormId', json.encode(data));

      return data;
    } catch (e) {
      print(' Ошибка gRPC загрузки групп: $e');

      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cached_groups_${facultyId}_$eduFormId');
      if (cached != null) {
        print(' Загружены группы из кэша (offline)');
        return json.decode(cached);
      }

      return _getMockGroups(facultyId, eduFormId);
    }
  }

  Future<List<dynamic>> getSchedule(int groupId) async {
    try {
      print('🔄 Загружаем расписание для группы: $groupId через gRPC');

      final response = await _stub
          .getSchedule(
            ScheduleRequest()..groupId = groupId,
          )
          .timeout(const Duration(seconds: 10));

      print('✅ Расписание - Получено пар: ${response.schedule.length}');

      final data = response.schedule.map((s) {
        return {
          'id': s.id,
          'group_id': s.groupId,
          'day_of_week': s.dayOfWeek,
          'lesson_num': 0,
          'subject': s.subject,
          'teacher': s.teacher,
          'room': s.room,
          'start_time': s.startTime,
          'end_time': s.endTime,
          'mode': s.mode,
          'subgroup': s.subgroup,
          'lesson_type': s.lessonType,
        };
      }).toList();

      // Кэшируем расписание группы
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_schedule_$groupId', json.encode(data));

      return data;
    } catch (e) {
      print(' Ошибка gRPC загрузки расписания: $e');

      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cached_schedule_$groupId');
      if (cached != null) {
        print(' Загружено расписание из кэша (offline)');
        return json.decode(cached);
      }

      return _getMockSchedule();
    }
  }

  List<dynamic> _getMockGroups(int facultyId, int eduFormId) {
    // Тестовые данные для разработки
    if (facultyId == 619 && eduFormId == 1) {
      // КНИИТ очная
      return [
        {
          'id': 1,
          'name': '411',
          'course': 4,
          'faculty_id': 619,
          'edu_form_id': 1
        },
        {
          'id': 2,
          'name': '412',
          'course': 4,
          'faculty_id': 619,
          'edu_form_id': 1
        },
        {
          'id': 3,
          'name': '421',
          'course': 4,
          'faculty_id': 619,
          'edu_form_id': 1
        },
        {
          'id': 4,
          'name': '431',
          'course': 4,
          'faculty_id': 619,
          'edu_form_id': 1
        },
      ];
    }

    return [
      {
        'id': 5,
        'name': '101',
        'course': 1,
        'faculty_id': facultyId,
        'edu_form_id': eduFormId
      },
      {
        'id': 6,
        'name': '102',
        'course': 1,
        'faculty_id': facultyId,
        'edu_form_id': eduFormId
      },
      {
        'id': 7,
        'name': '201',
        'course': 2,
        'faculty_id': facultyId,
        'edu_form_id': eduFormId
      },
    ];
  }

  // тестовые данные
  List<dynamic> _getMockSchedule() {
    return [
      {
        'subject': 'Математический анализ',
        'time': '09:00-10:30',
        'teacher': 'Иванов А.П.',
        'classroom': '405',
        'type': 'Лекция',
        'date': '2024-11-18',
        'day_of_week': 'Понедельник'
      },
      {
        'subject': 'Программирование',
        'time': '10:45-12:15',
        'teacher': 'Петрова С.М.',
        'classroom': '210',
        'type': 'Практика',
        'date': '2024-11-18',
        'day_of_week': 'Понедельник'
      },
      {
        'subject': 'Базы данных',
        'time': '13:00-14:30',
        'teacher': 'Сидоров В.К.',
        'classroom': '315',
        'type': 'Лабораторная',
        'date': '2024-11-19',
        'day_of_week': 'Вторник'
      },
      {
        'subject': 'Веб-технологии',
        'time': '14:45-16:15',
        'teacher': 'Козлова Е.Н.',
        'classroom': '420',
        'type': 'Практика',
        'date': '2024-11-19',
        'day_of_week': 'Вторник'
      },
      {
        'subject': 'Иностранный язык',
        'time': '09:00-10:30',
        'teacher': 'Смирнова О.Л.',
        'classroom': '105',
        'type': 'Практика',
        'date': '2024-11-20',
        'day_of_week': 'Среда'
      },
    ];
  }
}
