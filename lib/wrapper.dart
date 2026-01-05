import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_pbo/services/api_service.dart';
import 'package:project_pbo/models/user_model.dart';
import 'package:get/get.dart';
import 'package:project_pbo/screens/auth/login.dart';
import 'package:project_pbo/screens/student/student_main.dart';
import 'package:project_pbo/screens/teacher/teacher_main.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
    final UserService _userService = UserService();
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return const Login();
        }

        return RoleChecker(user: snapshot.data!);
      },
    );
  }
}

class RoleChecker extends StatelessWidget {
  final User user;

  const RoleChecker({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final UserService _userService = UserService();
    return FutureBuilder<UserModel?>(
      future: _userService.getUserData(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1DE9B6),
                    Color(0xFF00BFA5),
                    Color(0xFF00897B),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Loading...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error loading user data'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Get.offAll(() => Wrapper()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          UserModel fallback = UserModel(
            uid: user.uid,
            email: user.email ?? '',
            nama: '',
            role: 'siswa',
          );
          return StudentMain(userData: fallback.toMap());
        }

        UserModel userData = snapshot.data!;
        if (userData.role == 'guru') {
          return TeacherMain(userData: userData.toMap());
        } else {
          return StudentMain(userData: userData.toMap());
        }
      },
    );
  }
}
