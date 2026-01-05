import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_pbo/services/api_service.dart';
import 'package:project_pbo/models/user_model.dart';
import 'package:get/get.dart';
import 'package:project_pbo/screens/auth/login.dart';
import 'package:project_pbo/widgets/custom_button.dart';
import 'package:project_pbo/widgets/custom_text_field.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController nama = TextEditingController();
  TextEditingController nis = TextEditingController();
  TextEditingController nip = TextEditingController();

  String selectedRole = 'siswa';
  bool isLoading = false;
  bool isPasswordVisible = false;

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  Signup() async {
    if (email.text.isEmpty || password.text.isEmpty || nama.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Semua field harus diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedRole == 'siswa' && nis.text.isEmpty) {
      Get.snackbar(
        'Error',
        'NIS harus diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedRole == 'guru' && nip.text.isEmpty) {
      Get.snackbar(
        'Error',
        'NIP harus diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      UserCredential userCredential = await _authService.signUp(
        email.text,
        password.text,
      );

      UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        email: email.text,
        nama: nama.text,
        role: selectedRole,
        nis: selectedRole == 'siswa' ? nis.text : null,
        nip: selectedRole == 'guru' ? nip.text : null,
      );

      await _userService.createUserData(newUser);

      Get.snackbar(
        'Success',
        'Akun berhasil dibuat',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offAll(() => Login());
    } on FirebaseAuthException catch (e) {
      String message = 'Terjadi kesalahan';
      if (e.code == 'weak-password') {
        message = 'Password terlalu lemah';
      } else if (e.code == 'email-already-in-use') {
        message = 'Email sudah digunakan';
      }
      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1DE9B6), Color(0xFF00BFA5), Color(0xFF00897B)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 30),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: () => Get.back(),
                            ),
                          ),
                          SizedBox(height: 10),

                          Text(
                            'E.S.J.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 6,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: Offset(0, 4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'English Study Junior',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Create Account',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              color: Color(0xFFFFD54F),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 32),

                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedRole = 'siswa';
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 300),
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      gradient: selectedRole == 'siswa'
                                          ? LinearGradient(
                                              colors: [
                                                Color(0xFFFFD54F),
                                                Color(0xFFFFB300),
                                              ],
                                            )
                                          : null,
                                      color: selectedRole == 'siswa'
                                          ? null
                                          : Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.5),
                                        width: 2,
                                      ),
                                      boxShadow: selectedRole == 'siswa'
                                          ? [
                                              BoxShadow(
                                                color: Color(
                                                  0xFFFFB300,
                                                ).withOpacity(0.4),
                                                blurRadius: 8,
                                                offset: Offset(0, 4),
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: Text(
                                      'Siswa',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedRole = 'guru';
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 300),
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      gradient: selectedRole == 'guru'
                                          ? LinearGradient(
                                              colors: [
                                                Color(0xFFFFD54F),
                                                Color(0xFFFFB300),
                                              ],
                                            )
                                          : null,
                                      color: selectedRole == 'guru'
                                          ? null
                                          : Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.5),
                                        width: 2,
                                      ),
                                      boxShadow: selectedRole == 'guru'
                                          ? [
                                              BoxShadow(
                                                color: Color(
                                                  0xFFFFB300,
                                                ).withOpacity(0.4),
                                                blurRadius: 8,
                                                offset: Offset(0, 4),
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: Text(
                                      'Guru',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),

                          CustomTextField(
                            controller: nama,
                            hintText: 'Nama Lengkap',
                            prefixIcon: Icons.person_outline,
                          ),
                          SizedBox(height: 16),
                          CustomTextField(
                            controller: email,
                            hintText: 'Email',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: 16),
                          CustomTextField(
                            controller: password,
                            hintText: 'Password',
                            prefixIcon: Icons.lock_outline,
                            obscureText: !isPasswordVisible,
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Color(0xFF00BFA5),
                              ),
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 16),

                          if (selectedRole == 'siswa')
                            CustomTextField(
                              controller: nis,
                              hintText: 'NIS (Nomor Induk Siswa)',
                              prefixIcon: Icons.badge_outlined,
                            )
                          else
                            CustomTextField(
                              controller: nip,
                              hintText: 'NIP (Nomor Induk Pegawai)',
                              prefixIcon: Icons.work_outline,
                            ),
                          SizedBox(height: 32),
                          CustomButton(
                            text: 'Sign Up',
                            isLoading: isLoading,
                            onPressed: Signup,
                          ),
                          SizedBox(height: 24),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account? ",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                              TextButton(
                                onPressed: () => Get.back(),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size(0, 0),
                                ),
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: Color(0xFFFFD54F),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
