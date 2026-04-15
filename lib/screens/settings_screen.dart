import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: ListView(
        children: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeService().themeNotifier,
            builder: (_, mode, __) {
              return SwitchListTile(
                secondary: Icon(
                  mode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                  color: mode == ThemeMode.dark ? Colors.blue : Colors.orange,
                ),
                title: const Text('Тёмная тема'),
                value: mode == ThemeMode.dark,
                onChanged: (bool value) {
                  ThemeService().toggleTheme(value);
                },
              );
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: ThemeService().dayBarNotifier,
            builder: (_, atBottom, __) {
              return SwitchListTile(
                secondary: Icon(
                  atBottom
                      ? Icons.align_vertical_bottom
                      : Icons.align_vertical_top,
                  color: Colors.blue,
                ),
                title: const Text('Дни недели внизу'),
                subtitle: const Text('Перенести выбор дня вниз экрана'),
                value: atBottom,
                onChanged: (bool value) {
                  ThemeService().toggleDayBarPosition(value);
                },
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.group_outlined),
            title: const Text('Авторы'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Авторы', textAlign: TextAlign.center),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Россахацкий Сергей',
                          style: TextStyle(fontSize: 16)),
                      const Text('Куракин Эмиль',
                          style: TextStyle(fontSize: 16)),
                      const Text('Засовин Максим',
                          style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('ФИиИТ ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                          Icon(Icons.favorite, color: Colors.red, size: 20),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Закрыть'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('О приложении'),
            subtitle: const Text('Расписание СГУ v1.0.2'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Расписание СГУ',
                applicationVersion: '1.0.2',
                applicationIcon:
                    const Icon(Icons.school, color: Colors.blue, size: 48),
                children: [
                  const Text(
                      'Удобное приложение для просмотра расписания Саратовского государственного университета.'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
