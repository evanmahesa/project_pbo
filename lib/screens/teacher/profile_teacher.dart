import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:project_pbo/screens/auth/login.dart';

// MATERI: INHERITANCE
class ProfileTeacher extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ProfileTeacher({super.key, required this.userData});

  @override
  State<ProfileTeacher> createState() => _ProfileTeacherState();
}

// MATERI: ENCAPSULATION
class _ProfileTeacherState extends State<ProfileTeacher> {
  bool _isEditing = false;
  late TextEditingController _namaController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.userData['nama']);
    _emailController = TextEditingController(text: widget.userData['email']);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // MATERI: ASYNC & AWAIT
  Future<void> _updateProfile() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'nama': _namaController.text,
      });

      Get.snackbar(
        'Success',
        'Profil berhasil diupdate',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      setState(() {
        _isEditing = false;
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal update profil: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _changePassword() async {
    TextEditingController _newPasswordController = TextEditingController();

    Get.defaultDialog(
      title: 'Ganti Password',
      content: TextField(
        controller: _newPasswordController,
        decoration: InputDecoration(
          labelText: 'Password Baru',
          border: OutlineInputBorder(),
        ),
        obscureText: true,
      ),
      textConfirm: 'Ganti',
      textCancel: 'Batal',
      onConfirm: () async {
        if (_newPasswordController.text.length < 6) {
          Get.snackbar(
            'Error',
            'Password minimal 6 karakter',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        try {
          await FirebaseAuth.instance.currentUser!.updatePassword(
            _newPasswordController.text,
          );
          Get.back();
          Get.snackbar(
            'Success',
            'Password berhasil diganti',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } catch (e) {
          Get.snackbar(
            'Error',
            'Gagal ganti password: $e',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      },
    );
  }

  // MATERI: ASYNC & AWAIT - Logout
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAll(() => Login());
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),
                // Profile Header
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 60, color: Color(0xFF00BFA5)),
                ),
                SizedBox(height: 16),
                Text(
                  widget.userData['nama'] ?? 'Teacher',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  widget.userData['email'] ?? '',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFD54F),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'NIP: ${widget.userData['nip'] ?? '-'}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Profile Info
                Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Informasi Profil',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00897B),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              if (_isEditing) {
                                _updateProfile();
                              } else {
                                setState(() {
                                  _isEditing = true;
                                });
                              }
                            },
                            icon: Icon(
                              _isEditing ? Icons.save : Icons.edit,
                              color: Color(0xFF00BFA5),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      _buildInfoField('Nama', _namaController, _isEditing),
                      SizedBox(height: 12),
                      _buildInfoField('Email', _emailController, false),
                      SizedBox(height: 12),
                      _buildInfoItem('NIP', widget.userData['nip'] ?? '-'),
                      SizedBox(height: 12),
                      _buildInfoItem('Role', 'Guru'),
                    ],
                  ),
                ),

                // Statistik Mengajar
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statistik Mengajar',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00897B),
                        ),
                      ),
                      SizedBox(height: 16),
                      // MATERI: ASYNC - StreamBuilder
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('materi')
                            .where(
                              'createdBy',
                              isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                            )
                            .snapshots(),
                        builder: (context, snapshot) {
                          int totalMateri = snapshot.data?.docs.length ?? 0;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                'Total Materi',
                                totalMateri.toString(),
                              ),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .where('role', isEqualTo: 'siswa')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  int totalSiswa =
                                      snapshot.data?.docs.length ?? 0;
                                  return _buildStatItem(
                                    'Total Siswa',
                                    totalSiswa.toString(),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Change Password
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFD54F),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Ganti Password',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12),

                // Logout Button
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoField(
    String label,
    TextEditingController controller,
    bool enabled,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        TextField(
          controller: controller,
          enabled: enabled,
          style: TextStyle(fontSize: 16, color: Color(0xFF00897B)),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00897B),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00BFA5),
          ),
        ),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}
