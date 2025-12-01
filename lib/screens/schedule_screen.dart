import 'package:flutter/material.dart';
import '../models/schedule.dart';
import '../models/faculty.dart';
import '../services/api_service.dart';

class ScheduleScreen extends StatefulWidget {
  final Group selectedGroup;
  final Faculty selectedFaculty;
  final EduForm selectedEduForm;

  const ScheduleScreen({
    super.key,
    required this.selectedGroup,
    required this.selectedFaculty,
    required this.selectedEduForm,
  });

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<Schedule> schedules = [];
  List<Schedule> filteredSchedules = [];
  bool isLoading = true;
  String errorMessage = '';

  // Дни недели для ползунка
  final List<String> daysOfWeek = ['ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'ВС'];
  int selectedDayIndex = DateTime.now().weekday - 1; // Текущий день

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    try {
      print('🎯 Начинаем загрузку расписания для группы: ${widget.selectedGroup.id}');

      final apiService = ApiService();
      final data = await apiService.getSchedule(widget.selectedGroup.id);

      print('📦 Получены сырые данные: $data');

      final List<Schedule> loadedSchedules = data.map((json) {
        print('🔍 Обрабатываем JSON: $json');
        return Schedule.fromJson(json);
      }).toList();

      print('✅ Успешно создано расписаний: ${loadedSchedules.length}');

      setState(() {
        schedules = loadedSchedules;
        _filterSchedulesByDay(selectedDayIndex);
        isLoading = false;
      });
    } catch (e) {
      print('💥 Критическая ошибка: $e');
      setState(() {
        errorMessage = 'Ошибка загрузки расписания: $e';
        isLoading = false;
      });
    }
  }

  void _filterSchedulesByDay(int dayIndex) {
    // dayIndex: 0=ПН, 1=ВТ, 2=СР, 3=ЧТ, 4=ПТ, 5=СБ, 6=ВС
    // dayOfWeek в данных: 1=ПН, 2=ВТ, 3=СР, 4=ЧТ, 5=ПТ, 6=СБ, 7=ВС
    final selectedDayNumber = dayIndex + 1;

    setState(() {
      selectedDayIndex = dayIndex;
      filteredSchedules = schedules.where((schedule) => schedule.dayOfWeek == selectedDayNumber).toList();
    });
  }

  Color _getTypeColor(String mode) {
    switch (mode.toLowerCase()) {
      case 'числитель':
        return Colors.blue[100]!;
      case 'знаменатель':
        return Colors.green[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  String _getFullDayName(int index) {
    final fullDays = ['Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье'];
    return fullDays[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Расписание ${widget.selectedGroup.name}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ошибка: $errorMessage'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadSchedule,
              child: const Text('Повторить'),
            ),
          ],
        ),
      )
          : Column(
        children: [
          // Ползунок с днями недели
          Container(
            height: 60,
            color: Colors.grey[50],
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: daysOfWeek.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _filterSchedulesByDay(index),
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selectedDayIndex == index ? Colors.blue : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selectedDayIndex == index ? Colors.blue : Colors.grey,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          daysOfWeek[index],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: selectedDayIndex == index ? Colors.white : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: selectedDayIndex == index ? Colors.white : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Заголовок дня
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _getFullDayName(selectedDayIndex),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),

          // Список пар
          Expanded(
            child: filteredSchedules.isEmpty
                ? const Center(
              child: Text(
                'На этот день пар нет',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: filteredSchedules.length,
              itemBuilder: (context, index) {
                final schedule = filteredSchedules[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getTypeColor(schedule.mode),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 60,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          schedule.timeRange,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      title: Text(
                        schedule.subject,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${schedule.mode} · ${schedule.room}'),
                          Text(schedule.teacher),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}