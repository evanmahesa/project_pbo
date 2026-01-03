import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:project_pbo/teacher/tambah_materi.dart';
import 'package:project_pbo/teacher/edit_materi.dart';

// MATERI: INHERITANCE
class KelolaMateri extends StatelessWidget {
  final Map<String, dynamic> userData;

  const KelolaMateri({super.key, required this.userData});

  // MATERI: ASYNC & AWAIT - Delete function
  Future<void> _deleteMateri(String materiId) async {
    try {
      await FirebaseFirestore.instance
          .collection('materi')
          .doc(materiId)
          .delete();
      Get.snackbar(
        'Success',
        'Materi berhasil dihapus',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus materi: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _confirmDelete(String materiId, String judul) {
    Get.defaultDialog(
      title: 'Hapus Materi',
      middleText: 'Yakin ingin menghapus "$judul"?',
      textConfirm: 'Hapus',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        _deleteMateri(materiId);
        Get.back();
      },
    );
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
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kelola Materi',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Tambah, Edit, dan Hapus Materi',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Get.to(() => TambahMateri(userData: userData));
                      },
                      icon: Icon(Icons.add),
                      label: Text('Tambah'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFD54F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  child: StreamBuilder<QuerySnapshot>(
                    // MATERI: ASYNC - Real-time data stream
                    stream: FirebaseFirestore.instance
                        .collection('materi')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.folder_open,
                                size: 80,
                                color: Colors.white54,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Belum ada materi',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Klik tombol Tambah untuk membuat materi baru',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      // MATERI: GENERIC - List with map
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot doc = snapshot.data!.docs[index];
                          Map<String, dynamic> data =
                              doc.data() as Map<String, dynamic>;

                          return _buildMateriCard(doc.id, data);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMateriCard(String materiId, Map<String, dynamic> data) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getKategoriColor(
                      data['kategori'] ?? 'Lainnya',
                    ).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getKategoriIcon(data['kategori'] ?? 'Lainnya'),
                    color: _getKategoriColor(data['kategori'] ?? 'Lainnya'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['judul'] ?? 'Untitled',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00897B),
                        ),
                      ),
                      Text(
                        data['kategori'] ?? 'Lainnya',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              data['konten'] ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.quiz, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  '${(data['soal'] as List? ?? []).length} soal',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Spacer(),
                IconButton(
                  onPressed: () {
                    Get.to(
                      () => EditMateri(
                        materiId: materiId,
                        materiData: data,
                        userData: userData,
                      ),
                    );
                  },
                  icon: Icon(Icons.edit, color: Color(0xFF00BFA5)),
                ),
                IconButton(
                  onPressed: () {
                    _confirmDelete(materiId, data['judul'] ?? 'materi');
                  },
                  icon: Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // MATERI: POLYMORPHISM - Different return based on input
  IconData _getKategoriIcon(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'grammar':
        return Icons.text_fields;
      case 'vocabulary':
        return Icons.menu_book;
      case 'reading':
        return Icons.chrome_reader_mode;
      case 'listening':
        return Icons.headphones;
      case 'speaking':
        return Icons.mic;
      default:
        return Icons.school;
    }
  }

  Color _getKategoriColor(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'grammar':
        return Color(0xFF4ECDC4);
      case 'vocabulary':
        return Color(0xFFFF6B6B);
      case 'reading':
        return Color(0xFFFFD54F);
      case 'listening':
        return Color(0xFF95E1D3);
      case 'speaking':
        return Color(0xFFFF9F43);
      default:
        return Color(0xFF00BFA5);
    }
  }
}
