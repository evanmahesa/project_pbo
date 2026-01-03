import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:project_pbo/login.dart';
import 'package:project_pbo/student/student_main.dart';
import 'package:project_pbo/teacher/teacher_main.dart';

// MATERI: INHERITANCE - Wrapper extends StatelessWidget
class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // MATERI: FUTURE & ASYNC - StreamBuilder untuk real-time auth state
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User belum login
        if (!snapshot.hasData) {
          return const Login();
        }

        // User sudah login, cek role
        return RoleChecker(user: snapshot.data!);
      },
    );
  }
}

// MATERI: INHERITANCE - RoleChecker extends StatelessWidget
class RoleChecker extends StatelessWidget {
  final User user;

  const RoleChecker({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // MATERI: FUTURE & ASYNC - FutureBuilder untuk ambil data user
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get(),
      builder: (context, snapshot) {
        // Loading
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

        // Error
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

        // Document missing or empty -> fallback to default student data
        if (!snapshot.hasData ||
            snapshot.data == null ||
            !snapshot.data!.exists ||
            snapshot.data!.data() == null) {
          Map<String, dynamic> fallback = {
            'email': user.email,
            'role': 'siswa',
            'uid': user.uid,
          };
          return StudentMain(userData: fallback);
        }

        // Get user role
        Map<String, dynamic> userData =
            snapshot.data!.data() as Map<String, dynamic>;
        String role = userData['role'] ?? 'siswa';

        // MATERI: POLYMORPHISM - Return berbeda berdasarkan role
        if (role == 'guru') {
          return TeacherMain(userData: userData);
        } else {
          return StudentMain(userData: userData);
        }
      },
    );
  }
}
