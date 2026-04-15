import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  static const String _themeKey = 'is_dark_mode';
  static const String _dayBarKey = 'day_bar_at_bottom';

  final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
  final ValueNotifier<bool> dayBarNotifier = ValueNotifier(false);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    final isDark = prefs.getBool(_themeKey) ?? false;
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

    // Позиция дней false = сверху, true = снизу
    dayBarNotifier.value = prefs.getBool(_dayBarKey) ?? false;
  }

  bool get isDarkMode => themeNotifier.value == ThemeMode.dark;
  bool get isDayBarAtBottom => dayBarNotifier.value;

  Future<void> toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleDayBarPosition(bool atBottom) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dayBarKey, atBottom);
    dayBarNotifier.value = atBottom;
  }
}
