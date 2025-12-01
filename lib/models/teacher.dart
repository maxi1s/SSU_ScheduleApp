class Teacher {
  final String name;

  Teacher({required this.name});

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      name: json['name'],
    );
  }
}