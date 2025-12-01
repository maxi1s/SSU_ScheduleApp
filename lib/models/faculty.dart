class Faculty {
  final int id;
  final String code;
  final String name;

  Faculty({required this.id, required this.code, required this.name});

  factory Faculty.fromJson(Map<String, dynamic> json) {
    final code = json['name'] ?? '';
    final fullName = _getFullName(code);

    return Faculty(
      id: json['id'] ?? 0,
      code: code,
      name: fullName,
    );
  }

  static String _getFullName(String code) {
    final facultyNames = {
      'bf': 'Биологический факультет',
      'biff': 'Филологический факультет',
      'bippf': 'Психолого-педагогический факультет',
      'cre': 'Колледж радиоэлектроники им. П.Н. Яблочкова',
      'ef': 'Экономический факультет',
      'ff': 'Институт физики',
      'fmen': 'Факультет математики и естественных наук',
      'fmend': 'Факультет физико-математических и естественно-научных дисциплин (ПИ)',
      'fmimt': 'Факультет фундаментальной медицины и медицинских технологий',
      'fp': 'Философский факультет',
      'fppso': 'Факультет психолого-педагогического и специального образования (ПИ)',
      'fps': 'Факультет психологии',
      'gdrin': 'Факультет гуманитарных дисциплин, русского и иностранных языков (ПИ)',
      'gf': 'Географический факультет',
      'gl': 'Геологический факультет',
      'idpo': 'Институт дополнительного профессионального образования',
      'ifg': 'Институт филологии и журналистики',
      'ih': 'Институт химии',
      'imo': 'Институт истории и международных отношений',
      'kgl': 'Геологический колледж',
      'knt': 'Факультет компьютерных наук и информационных технологий',
      'mm': 'Механико-математический факультет',
      'piifk': 'Факультет физической культуры и спорта (ПИ)',
      'piii': 'Факультет искусств (ПИ)',
      'sf': 'Социологический факультет',
      'uf': 'Юридический факультет',
    };

    return facultyNames[code] ?? code;
  }

  @override
  String toString() => name;
}

class EduForm {
  final int id;
  final String name;
  final String code;

  EduForm({required this.id, required this.name, required this.code});

  static List<EduForm> get allForms => [
    EduForm(id: 1, name: 'Очная форма', code: 'do'),
    EduForm(id: 2, name: 'Очно-заочная форма', code: 'oz'),
    EduForm(id: 3, name: 'Заочная форма', code: 'zo'),
  ];

  @override
  String toString() => name;
}

class Group {
  final int id;
  final String name;
  final int course;
  final int facultyId;
  final int eduFormId;

  Group({
    required this.id,
    required this.name,
    required this.course,
    required this.facultyId,
    required this.eduFormId,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      course: json['course'] ?? 1,
      facultyId: json['faculty_id'] ?? 0,
      eduFormId: json['edu_form_id'] ?? 0,
    );
  }

  @override
  String toString() => name;
}