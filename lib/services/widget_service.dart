import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/schedule.dart';

class WidgetService {
  static const String _groupIdKey = 'selected_group_id';
  static const String _androidWidgetName = 'SimpleWidgetProvider';

  /// Обновляет данные виджета
  static Future<void> updateWidgetData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final groupId = prefs.getInt(_groupIdKey);

      if (groupId == null) {
        await _updateWidget('Расписание', 'Выберите группу в приложении');
        return;
      }

      final cachedSchedule = prefs.getString('cached_schedule_$groupId');
      if (cachedSchedule == null) {
        await _updateWidget('Расписание', 'Нет данных. Откройте расписание в приложении');
        return;
      }

      final List<dynamic> decoded = json.decode(cachedSchedule);
      final List<Schedule> allSchedule =
          decoded.map((item) => Schedule.fromJson(item)).toList();

      // Определяем текущий день недели (Dart: 1=ПН, 7=ВС)
      final now = DateTime.now();
      final currentDayOfWeek = now.weekday;

      // Фильтруем расписание на сегодня
      final todaySchedule =
          allSchedule.where((s) => s.dayOfWeek == currentDayOfWeek).toList();

      // Сортируем по времени начала
      todaySchedule.sort((a, b) => a.startTime.compareTo(b.startTime));

      final dayName = _getDayName(currentDayOfWeek);
      
      String content;
      if (todaySchedule.isEmpty) {
        content = 'Пар на сегодня нет';
      } else {
        content = todaySchedule.map((s) {
          final time = s.startTime.isNotEmpty ? s.startTime : '--:--';
          return '$time | ${s.subject}';
        }).join('\n');
      }

      await _updateWidget(dayName, content);
    } catch (e) {
      print('Error updating widget data: $e');
    }
  }

  static Future<void> _updateWidget(String title, String content) async {
    await HomeWidget.saveWidgetData<String>('widget_title', title);
    await HomeWidget.saveWidgetData<String>('widget_content', content);

    await HomeWidget.updateWidget(
      name: _androidWidgetName,
      androidName: _androidWidgetName,
    );
  }

  static String _getDayName(int day) {
    const days = {
      1: 'Понедельник',
      2: 'Вторник',
      3: 'Среда',
      4: 'Четверг',
      5: 'Пятница',
      6: 'Суббота',
      7: 'Воскресенье',
    };
    return days[day] ?? 'Сегодня';
  }
}
