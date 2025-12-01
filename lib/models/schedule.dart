class Schedule {
  final int id;
  final int groupId;
  final int dayOfWeek; // 1-ПН, 2-ВТ, 3-СР, 4-ЧТ, 5-ПТ, 6-СБ, 7-ВС
  final int lessonNum;
  final String subject;
  final String teacher;
  final String room;
  final String startTime;
  final String endTime;
  final String mode; // "числитель" или "знаменатель"
  final int subgroup;

  Schedule({
    required this.id,
    required this.groupId,
    required this.dayOfWeek,
    required this.lessonNum,
    required this.subject,
    required this.teacher,
    required this.room,
    required this.startTime,
    required this.endTime,
    required this.mode,
    required this.subgroup,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] ?? 0,
      groupId: json['group_id'] ?? 0,
      dayOfWeek: json['day_of_week'] ?? 0,
      lessonNum: json['lesson_num'] ?? 0,
      subject: _toString(json['subject']),
      teacher: _toString(json['teacher']),
      room: _toString(json['room']),
      startTime: _toString(json['start_time']),
      endTime: _toString(json['end_time']),
      mode: _toString(json['mode']),
      subgroup: json['subgroup'] ?? 0,
    );
  }

  // Вспомогательный метод для конвертации любого типа в строку
  static String _toString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  // Геттер для времени в формате "10:00-11:30"
  String get timeRange {
    if (endTime.isEmpty) return startTime;
    return '$startTime-$endTime';
  }

  // Геттер для названия дня недели
  String get dayName {
    final days = ['', 'Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье'];
    return days[dayOfWeek] ?? 'День $dayOfWeek';
  }

  // Геттер для короткого названия дня
  String get shortDayName {
    final days = ['', 'ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'ВС'];
    return days[dayOfWeek] ?? '$dayOfWeek';
  }

  @override
  String toString() => '$subject ($startTime)';
}