import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/faculty.dart';
import '../services/api_service.dart';
import '../services/widget_service.dart';
import 'schedule_screen.dart';
import 'settings_screen.dart';
import '../widgets/custom_dropdown.dart';

class SelectionScreen extends StatefulWidget {
  const SelectionScreen({super.key});

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  List<Faculty> faculties = [];
  List<EduForm> eduForms = EduForm.allForms;
  List<Group> groups = [];

  Faculty? selectedFaculty;
  EduForm? selectedEduForm;
  Group? selectedGroup;

  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadFaculties();
    await _loadSavedSelection();
    // Обновляем виджет при запуске приложения
    await WidgetService.updateWidgetData();
  }

  // Сохранение выбора
  Future<void> _saveSelection() async {
    final prefs = await SharedPreferences.getInstance();
    if (selectedFaculty != null) {
      await prefs.setString(
          'selected_faculty',
          json.encode({
            'id': selectedFaculty!.id,
            'name': selectedFaculty!.code,
          }));
    }
    if (selectedEduForm != null) {
      await prefs.setInt('selected_edu_form_id', selectedEduForm!.id);
    }
    if (selectedGroup != null) {
      await prefs.setString(
          'selected_group',
          json.encode({
            'id': selectedGroup!.id,
            'name': selectedGroup!.name,
            'course': selectedGroup!.course,
            'faculty_id': selectedGroup!.facultyId,
            'edu_form_id': selectedGroup!.eduFormId,
          }));
      await prefs.setInt('selected_group_id', selectedGroup!.id);
      // Обновляем виджет при смене группы
      await WidgetService.updateWidgetData();
    }
  }

  // Загрузка сохраненного выбора
  Future<void> _loadSavedSelection() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final facultyJson = prefs.getString('selected_faculty');
      if (facultyJson != null) {
        selectedFaculty = Faculty.fromJson(json.decode(facultyJson));
      }

      final eduFormId = prefs.getInt('selected_edu_form_id');
      if (eduFormId != null) {
        selectedEduForm = eduForms.firstWhere((f) => f.id == eduFormId);
      }

      final groupJson = prefs.getString('selected_group');
      if (groupJson != null) {
        selectedGroup = Group.fromJson(json.decode(groupJson));
        // Если группа есть, сразу подгружаем список групп для этого факультета
        if (selectedFaculty != null && selectedEduForm != null) {
          _loadGroups(silent: true);
        }
      }

      setState(() {});
    } catch (e) {
      print('Ошибка загрузки кэша: $e');
    }
  }

  Future<void> _loadFaculties() async {
    try {
      final apiService = ApiService();
      final data = await apiService.getFaculties();

      final List<Faculty> loadedFaculties =
          data.map((json) => Faculty.fromJson(json)).toList();

      setState(() {
        faculties = loadedFaculties;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Ошибка загрузки факультетов: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _loadGroups({bool silent = false}) async {
    if (selectedFaculty == null || selectedEduForm == null) return;

    try {
      if (!silent) {
        setState(() {
          groups = [];
          selectedGroup = null;
        });
      }

      final apiService = ApiService();
      final data =
          await apiService.getGroups(selectedFaculty!.id, selectedEduForm!.id);

      final List<Group> loadedGroups =
          data.map((json) => Group.fromJson(json)).toList();

      setState(() {
        groups = loadedGroups;
      });
    } catch (e) {
      if (!silent) {
        setState(() {
          errorMessage = 'Ошибка загрузки групп: $e';
        });
      }
    }
  }

  void _onFacultySelected(Faculty? faculty) {
    setState(() {
      selectedFaculty = faculty;
      selectedEduForm = null;
      selectedGroup = null;
      groups = [];
    });
    _saveSelection();
  }

  void _onEduFormSelected(EduForm? eduForm) {
    setState(() {
      selectedEduForm = eduForm;
      selectedGroup = null;
      groups = [];
    });

    if (eduForm != null) {
      _loadGroups();
    }
    _saveSelection();
  }

  void _onGroupSelected(Group? group) {
    setState(() {
      selectedGroup = group;
    });
    _saveSelection();
  }

  void _showSchedule() {
    if (selectedGroup != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScheduleScreen(
            selectedGroup: selectedGroup!,
            selectedFaculty: selectedFaculty!,
            selectedEduForm: selectedEduForm!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ошибка'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red[400], size: 64),
                const SizedBox(height: 20),
                Text(
                  errorMessage,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _loadFaculties,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Расписание СГУ'),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Факультет
            CustomDropdown<Faculty>(
              title: 'Факультет',
              value: selectedFaculty,
              items: faculties,
              onChanged: _onFacultySelected,
              icon: Icons.school,
              displayText: (faculty) => faculty.name,
            ),

            const SizedBox(height: 20),

            // Форма обучения
            CustomDropdown<EduForm>(
              title: 'Форма обучения',
              value: selectedEduForm,
              items: eduForms,
              onChanged: _onEduFormSelected,
              icon: Icons.schedule,
              enabled: selectedFaculty != null,
              displayText: (eduForm) => eduForm.name,
            ),

            const SizedBox(height: 20),

            // Группа
            CustomDropdown<Group>(
              title: 'Группа',
              value: selectedGroup,
              items: groups,
              onChanged: _onGroupSelected,
              icon: Icons.group,
              enabled: selectedEduForm != null,
              displayText: (group) => group.name,
            ),

            const SizedBox(height: 30),

            // Кнопка показа расписания
            ElevatedButton(
              onPressed: selectedGroup != null ? _showSchedule : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedGroup != null
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Показать расписание'),
            ),
          ],
        ),
      ),
    );
  }
}
