import 'package:flutter/material.dart';
import 'screens/selection_screen.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService().themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          title: 'SSU Schedule',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF2C2C2C),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1A1A1A),
              foregroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
            ),
            cardTheme: const CardThemeData(
              color: Color(0xFF3D3D3D),
            ),
            colorScheme: const ColorScheme.dark(
              primary: Colors.blue,
              surface: Color(0xFF3D3D3D),
            ),
          ),
          themeMode: mode,
          home: const SelectionScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
