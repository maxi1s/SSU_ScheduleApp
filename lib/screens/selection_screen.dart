import 'package:flutter/material.dart';
import '../models/faculty.dart';
import '../services/api_service.dart';
import 'schedule_screen.dart';
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
    _loadFaculties();
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

  Future<void> _loadGroups() async {
    if (selectedFaculty == null || selectedEduForm == null) return;

    try {
      setState(() {
        groups = [];
        selectedGroup = null;
      });

      final apiService = ApiService();
      final data =
          await apiService.getGroups(selectedFaculty!.id, selectedEduForm!.id);

      final List<Group> loadedGroups =
          data.map((json) => Group.fromJson(json)).toList();

      setState(() {
        groups = loadedGroups;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Ошибка загрузки групп: $e';
      });
    }
  }

  void _onFacultySelected(Faculty? faculty) {
    setState(() {
      selectedFaculty = faculty;
      selectedEduForm = null;
      selectedGroup = null;
      groups = [];
    });
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
  }

  void _onGroupSelected(Group? group) {
    setState(() {
      selectedGroup = group;
    });
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
                  style: const TextStyle(fontSize: 16),
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
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
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
                backgroundColor:
                    selectedGroup != null ? Colors.blue : Colors.grey,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Показать расписание'),
            ),

            // УБРАЛ БЛОК "ВЫБРАНО:" - теперь просто чистая кнопка
          ],
        ),
      ),
    );
  }
}
