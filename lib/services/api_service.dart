import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8081';

  Future<List<dynamic>> getFaculties() async {
    try {
      print('🔄 Загружаем факультеты: $baseUrl/faculties');

      final response = await http.get(
        Uri.parse('$baseUrl/faculties'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('✅ Факультеты - Статус: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        print('📊 Получено факультетов: ${jsonData.length}');
        return jsonData;
      } else {
        throw Exception('HTTP ошибка: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Ошибка загрузки факультетов: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getGroups(int facultyId, int eduFormId) async {
    try {
      print('🔄 Загружаем группы для факультета: $facultyId, формы: $eduFormId');

      final response = await http.get(
        Uri.parse('$baseUrl/groups?faculty_id=$facultyId&edu_form_id=$eduFormId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('✅ Группы - Статус: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        print('📊 Получено групп: ${jsonData.length}');
        return jsonData;
      } else {
        throw Exception('Ошибка загрузки групп: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Ошибка загрузки групп: $e');
      // Временные тестовые группы
      return _getMockGroups(facultyId, eduFormId);
    }
  }

  // ДОБАВЛЯЕМ МЕТОД ДЛЯ РАСПИСАНИЯ
  Future<List<dynamic>> getSchedule(int groupId) async {
    try {
      print('🔄 Загружаем расписание для группы: $groupId');

      final response = await http.get(
        Uri.parse('$baseUrl/schedule?group_id=$groupId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('✅ Расписание - Статус: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        print('📊 Получено пар: ${jsonData.length}');
        return jsonData;
      } else {
        throw Exception('Ошибка загрузки расписания: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Ошибка загрузки расписания: $e');
      // Временные тестовые данные
      return _getMockSchedule();
    }
  }

  List<dynamic> _getMockGroups(int facultyId, int eduFormId) {
    // Тестовые данные для разработки
    if (facultyId == 619 && eduFormId == 1) { // КНИИТ очная
      return [
        {'id': 1, 'name': '411', 'course': 4, 'faculty_id': 619, 'edu_form_id': 1},
        {'id': 2, 'name': '412', 'course': 4, 'faculty_id': 619, 'edu_form_id': 1},
        {'id': 3, 'name': '421', 'course': 4, 'faculty_id': 619, 'edu_form_id': 1},
        {'id': 4, 'name': '431', 'course': 4, 'faculty_id': 619, 'edu_form_id': 1},
      ];
    }

    return [
      {'id': 5, 'name': '101', 'course': 1, 'faculty_id': facultyId, 'edu_form_id': eduFormId},
      {'id': 6, 'name': '102', 'course': 1, 'faculty_id': facultyId, 'edu_form_id': eduFormId},
      {'id': 7, 'name': '201', 'course': 2, 'faculty_id': facultyId, 'edu_form_id': eduFormId},
    ];
  }

  // ДОБАВЛЯЕМ МЕТОД ДЛЯ ТЕСТОВЫХ ДАННЫХ РАСПИСАНИЯ
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