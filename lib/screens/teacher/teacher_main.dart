import 'package:flutter/material.dart';
import 'package:project_pbo/screens/teacher/dashboard_teacher.dart';
import 'package:project_pbo/screens/teacher/kelola_materi.dart';
import 'package:project_pbo/screens/teacher/profile_teacher.dart';

// MATERI: INHERITANCE
class TeacherMain extends StatefulWidget {
  final Map<String, dynamic> userData;

  const TeacherMain({super.key, required this.userData});

  @override
  State<TeacherMain> createState() => _TeacherMainState();
}

// MATERI: ENCAPSULATION
class _TeacherMainState extends State<TeacherMain> {
  int _currentIndex = 0;

  // MATERI: GENERIC - List<Widget>
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardTeacher(userData: widget.userData),
      KelolaMateri(userData: widget.userData),
      ProfileTeacher(userData: widget.userData),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00BFA5), Color(0xFF00897B)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          selectedItemColor: Color(0xFFFFD54F),
          unselectedItemColor: Colors.white.withOpacity(0.6),
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Materi'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}
