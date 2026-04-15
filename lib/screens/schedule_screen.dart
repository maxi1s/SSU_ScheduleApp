import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../models/schedule.dart';
import '../models/faculty.dart';
import '../services/api_service.dart';
import '../services/widget_service.dart';
import '../services/theme_service.dart';

class AnimatedTimeCard extends StatefulWidget {
  final String timeRange;
  final bool isCurrent;
  final bool isDark;

  const AnimatedTimeCard({
    super.key,
    required this.timeRange,
    required this.isCurrent,
    required this.isDark,
  });

  @override
  State<AnimatedTimeCard> createState() => _AnimatedTimeCardState();
}

class _AnimatedTimeCardState extends State<AnimatedTimeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 1.5, end: 4.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isCurrent) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedTimeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCurrent && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isCurrent && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final times = widget.timeRange.split('-');
    final startTime = times.isNotEmpty ? times[0] : '';
    final endTime = times.length > 1 ? times[1] : '';

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 60, // Вернул 60
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          decoration: BoxDecoration(
            color: widget.isDark
                ? const Color.fromARGB(255, 49, 49, 49)
                : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: widget.isCurrent
                ? Border.all(
                    color: Colors.red.withOpacity(0.8),
                    width: _animation.value,
                  )
                : null,
            boxShadow: widget.isCurrent
                ? [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: _animation.value * 2,
                      spreadRadius: _animation.value / 2,
                    )
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                startTime,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: widget.isDark ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              if (endTime.isNotEmpty) ...[
                Container(
                  height: 1,
                  width: 10,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  color: (widget.isDark ? Colors.white : Colors.black)
                      .withOpacity(0.3),
                ),
                Text(
                  endTime,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: widget.isDark ? Colors.white : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

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
      print(
          '🎯 Начинаем загрузку расписания для группы: ${widget.selectedGroup.id}');

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
      // Обновляем виджет после загрузки свежего расписания
      await WidgetService.updateWidgetData();
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
      filteredSchedules = schedules
          .where((schedule) => schedule.dayOfWeek == selectedDayNumber)
          .toList();
    });
  }

  Color _getTypeColor(String mode) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (mode.toLowerCase()) {
      case 'числитель':
        return isDark
            ? const Color.fromARGB(255, 31, 98, 142)
            : Colors.blue[100]!;
      case 'знаменатель':
        return isDark
            ? const Color.fromARGB(255, 55, 98, 84)
            : Colors.green[100]!;
      default:
        return isDark ? const Color(0xFF424242) : Colors.grey[100]!;
    }
  }

  String _getFullDayName(int index) {
    final fullDays = [
      'Понедельник',
      'Вторник',
      'Среда',
      'Четверг',
      'Пятница',
      'Суббота',
      'Воскресенье'
    ];
    return fullDays[index];
  }

  String _cleanMode(String mode) {
    if (mode.toLowerCase() == 'оба') return '';
    return mode;
  }

  String _buildModeRoom(Schedule schedule) {
    final mode = _cleanMode(schedule.mode);
    if (mode.isEmpty) return schedule.room;
    if (schedule.room.isEmpty) return mode;
    return '$mode · ${schedule.room}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService().dayBarNotifier,
      builder: (context, atBottom, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Расписание ${widget.selectedGroup.name}'),
            shape: atBottom
                ? const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  )
                : null,
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
                  : Stack(
                      children: [
                        Positioned.fill(
                          child: Stack(
                            children: [
                              // Список пар
                              Positioned.fill(
                                child: filteredSchedules.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'На этот день пар нет',
                                          style: TextStyle(
                                              fontSize: 16, color: Colors.grey),
                                        ),
                                      )
                                    : ListView.builder(
                                        padding: EdgeInsets.only(
                                          top: atBottom ? 70 : 130,
                                          bottom: atBottom ? 100 : 40,
                                        ),
                                        itemCount: filteredSchedules.length,
                                        itemBuilder: (context, index) {
                                          final schedule =
                                              filteredSchedules[index];
                                          final typeColor =
                                              _getTypeColor(schedule.mode);

                                          return Card(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 4),
                                            child: Stack(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: typeColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: ListTile(
                                                    leading: AnimatedTimeCard(
                                                      timeRange:
                                                          schedule.timeRange,
                                                      isCurrent:
                                                          schedule.isCurrent,
                                                      isDark: isDark,
                                                    ),
                                                    title: Text(
                                                      schedule.subject,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                        color: isDark
                                                            ? Colors.white
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                    subtitle: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        if (schedule.subgroup
                                                            .isNotEmpty)
                                                          Text(
                                                            schedule.subgroup,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: isDark
                                                                  ? Colors
                                                                      .blue[200]
                                                                  : Colors.blue[
                                                                      700],
                                                            ),
                                                          ),
                                                        Text(
                                                          _buildModeRoom(
                                                              schedule),
                                                          style: TextStyle(
                                                            color: isDark
                                                                ? Colors.white70
                                                                : Colors
                                                                    .black87,
                                                          ),
                                                        ),
                                                        Text(
                                                          schedule.teacher,
                                                          style: TextStyle(
                                                            color: isDark
                                                                ? Colors.white60
                                                                : Colors
                                                                    .black54,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                if (schedule
                                                    .lessonType.isNotEmpty)
                                                  Positioned(
                                                    bottom: 8,
                                                    right: 12,
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 2),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        border: Border.all(
                                                          color: isDark
                                                              ? Colors.white38
                                                              : Colors.black26,
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        schedule.lessonType,
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: isDark
                                                              ? Colors.white70
                                                              : Colors.black54,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                              ),
                              // Заголовок дня
                              Positioned(
                                top: atBottom ? 0 : 70,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.5,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: BackdropFilter(
                                        filter: ui.ImageFilter.blur(
                                            sigmaX: 10, sigmaY: 10),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: (isDark
                                                    ? const Color(0xFF2C2C2C)
                                                    : Colors.white)
                                                .withOpacity(0.8),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: isDark
                                                  ? Colors.white10
                                                  : Colors.black12,
                                              width: 1,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            _getFullDayName(selectedDayIndex),
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: isDark
                                                  ? Colors.blue[300]
                                                  : Colors.blue,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: atBottom ? null : 0,
                          bottom: atBottom ? 0 : null,
                          left: 0,
                          right: 0,
                          child: ClipRRect(
                            borderRadius: atBottom
                                ? const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  )
                                : const BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  ),
                            child: BackdropFilter(
                              filter: ui.ImageFilter.blur(
                                sigmaX: atBottom ? 15 : 0,
                                sigmaY: atBottom ? 15 : 0,
                              ),
                              child: Container(
                                padding:
                                    EdgeInsets.only(bottom: atBottom ? 20 : 0),
                                height: 60 + (atBottom ? 20 : 0),
                                decoration: BoxDecoration(
                                  color: atBottom
                                      ? (isDark
                                              ? const Color(0xFF1A1A1A)
                                              : Colors.grey[50]!)
                                          .withOpacity(0.6)
                                      : (isDark
                                          ? const Color(0xFF1A1A1A)
                                          : Colors.grey[50]),
                                  borderRadius: atBottom
                                      ? const BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        )
                                      : const BorderRadius.only(
                                          bottomLeft: Radius.circular(20),
                                          bottomRight: Radius.circular(20),
                                        ),
                                ),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: daysOfWeek.length,
                                  itemBuilder: (context, index) {
                                    final isSelected =
                                        selectedDayIndex == index;
                                    return GestureDetector(
                                      onTap: () => _filterSchedulesByDay(index),
                                      child: Container(
                                        width: 60,
                                        margin: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.blue
                                              : (isDark
                                                  ? const Color(0xFF3D3D3D)
                                                  : Colors.white),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.blue
                                                : (isDark
                                                    ? Colors.grey[700]!
                                                    : Colors.grey),
                                          ),
                                          boxShadow: [
                                            if (!isDark)
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.3),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              daysOfWeek[index],
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: isSelected
                                                    ? Colors.white
                                                    : (isDark
                                                        ? Colors.white70
                                                        : Colors.black),
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.transparent,
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
                            ),
                          ),
                        ),
                      ],
                    ),
        );
      },
    );
  }
}
