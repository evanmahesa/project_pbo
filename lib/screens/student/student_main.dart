import 'package:flutter/material.dart';
import 'package:project_pbo/screens/student/dashboard_student.dart';
import 'package:project_pbo/screens/student/tugas_student.dart';
import 'package:project_pbo/screens/student/profile_student.dart';

// MATERI: INHERITANCE - StudentMain extends StatefulWidget
class StudentMain extends StatefulWidget {
  final Map<String, dynamic> userData;

  const StudentMain({super.key, required this.userData});

  @override
  State<StudentMain> createState() => _StudentMainState();
}

// MATERI: ENCAPSULATION - Private state class
class _StudentMainState extends State<StudentMain> {
  // MATERI: ENCAPSULATION - Private variable
  int _currentIndex = 0;

  // MATERI: GENERIC - List<Widget> untuk halaman
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Initialize pages with user data
    _pages = [
      DashboardStudent(userData: widget.userData),
      TugasStudent(userData: widget.userData),
      ProfileStudent(userData: widget.userData),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_currentIndex],
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
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
                icon: Icon(Icons.home),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assignment),
                label: 'Tugas',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
