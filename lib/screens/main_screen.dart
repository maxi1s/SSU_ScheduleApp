import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/teacher.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Teacher> teachers = [];
  bool isLoading = false;
  String errorMessage = '';

  Future<void> fetchTeachers() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final fetchedTeachers = await ApiService().getTeachers();
      setState(() {
        teachers = fetchedTeachers;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SSU Schedule - Преподаватели'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Кнопка для загрузки данных
            ElevatedButton(
              onPressed: isLoading ? null : fetchTeachers,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text(
                'Загрузить преподавателей',
                style: TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 20),

            // Сообщение об ошибке
            if (errorMessage.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Ошибка: $errorMessage',
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            const SizedBox(height: 20),

            // Заголовок таблицы
            if (teachers.isNotEmpty)
              const Text(
                'Список преподавателей:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

            const SizedBox(height: 10),

            // Таблица с преподавателями
            Expanded(
              child: teachers.isEmpty && !isLoading
                  ? const Center(
                child: Text(
                  'Нажмите кнопку для загрузки данных',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: teachers.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        teachers[index].name,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}