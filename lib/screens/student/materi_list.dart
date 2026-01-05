import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
// Import halaman detail materi jika ada, misalnya:
// import 'package:project_pbo/student/materi_detail.dart';

class MateriList extends StatefulWidget {
  final String kategori;

  const MateriList({super.key, required this.kategori});

  @override
  State<MateriList> createState() => _MateriListState();
}

class _MateriListState extends State<MateriList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.kategori, style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF00897B),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1DE9B6), Color(0xFF00BFA5), Color(0xFF00897B)],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('materi').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'Belum ada materi',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              );
            }

            // Filter client-side to support missing/null kategori values ("Lainnya")
            final docs = snapshot.data!.docs.where((d) {
              final data = d.data() as Map<String, dynamic>;
              final raw = data['kategori'];
              if (widget.kategori == 'Lainnya') {
                return raw == null || (raw is String && raw.trim().isEmpty);
              }
              return raw == widget.kategori;
            }).toList();

            if (docs.isEmpty) {
              return Center(
                child: Text(
                  'Belum ada materi di kategori ini',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                var doc = docs[index];
                var data = doc.data() as Map<String, dynamic>;
                String judul = data['judul'] ?? 'Judul Materi';
                String deskripsi = data['deskripsi'] ?? 'Deskripsi materi';

                return GestureDetector(
                  onTap: () {
                    // Navigasi ke detail materi atau quiz
                    // Misalnya: Get.to(() => MateriDetail(materiId: doc.id));
                    // Jika belum ada, bisa tampilkan snackbar sementara
                    Get.snackbar(
                      'Info',
                      'Navigasi ke detail materi belum diimplementasi',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(16),
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
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getKategoriColor(
                              widget.kategori,
                            ).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getKategoriIcon(widget.kategori),
                            color: _getKategoriColor(widget.kategori),
                            size: 28,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                judul,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00897B),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                deskripsi,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

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
