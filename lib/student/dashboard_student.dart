import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:project_pbo/student/materi_list.dart';

// MATERI: INHERITANCE - DashboardStudent extends StatefulWidget
class DashboardStudent extends StatefulWidget {
  final Map<String, dynamic> userData;

  const DashboardStudent({super.key, required this.userData});

  @override
  State<DashboardStudent> createState() => _DashboardStudentState();
}

// MATERI: ENCAPSULATION - Private state class
class _DashboardStudentState extends State<DashboardStudent> {
  // MATERI: ENCAPSULATION - Private variables
  int _totalMateriSelesai = 0;
  double _nilaiRataRata = 0.0;
  int _totalPoin = 0;

  @override
  void initState() {
    super.initState();
    _loadStatistik();
  }

  // MATERI: ASYNC & AWAIT - Fungsi asynchronous untuk load data
  Future<void> _loadStatistik() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Get hasil belajar
      QuerySnapshot hasilSnapshot = await FirebaseFirestore.instance
          .collection('hasil_belajar')
          .doc(uid)
          .collection('results')
          .get();

      if (hasilSnapshot.docs.isNotEmpty) {
        double totalNilai = 0;
        for (var doc in hasilSnapshot.docs) {
          totalNilai += (doc.data() as Map<String, dynamic>)['nilai'] ?? 0;
        }

        setState(() {
          _totalMateriSelesai = hasilSnapshot.docs.length;
          _nilaiRataRata = totalNilai / hasilSnapshot.docs.length;
          _totalPoin = (_nilaiRataRata * 10).toInt();
        });
      }
    } catch (e) {
      print('Error loading statistik: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1DE9B6), Color(0xFF00BFA5), Color(0xFF00897B)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello,',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          Text(
                            widget.userData['nama'] ?? 'Student',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.notifications,
                          color: Color(0xFF00897B),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Statistik Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Materi Selesai',
                          _totalMateriSelesai.toString(),
                          Icons.book,
                          Color(0xFFFFD54F),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Rata-rata Nilai',
                          _nilaiRataRata.toStringAsFixed(1),
                          Icons.star,
                          Color(0xFFFF6B6B),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Poin',
                          _totalPoin.toString(),
                          Icons.emoji_events,
                          Color(0xFF4ECDC4),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Streak',
                          '0 hari',
                          Icons.local_fire_department,
                          Color(0xFFFF9F43),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Kategori Materi
                  Text(
                    'Kategori Materi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),

                  // MATERI: GENERIC - List dengan StreamBuilder
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('materi')
                        .snapshots(),
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
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      // MATERI: POLYMORPHISM - Grouping berdasarkan kategori (safely)
                      Map<String, List<DocumentSnapshot>> groupedMateri = {};
                      for (var doc in snapshot.data!.docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        final rawKategori = data['kategori'];
                        final String kategori =
                            (rawKategori is String &&
                                rawKategori.trim().isNotEmpty)
                            ? rawKategori
                            : 'Lainnya';
                        groupedMateri.putIfAbsent(kategori, () => []).add(doc);
                      }

                      if (groupedMateri.isEmpty) {
                        return Center(
                          child: Text(
                            'Belum ada kategori materi',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      return Column(
                        children: groupedMateri.entries.map((entry) {
                          return _buildKategoriCard(
                            entry.key,
                            entry.value.length,
                            _getKategoriIcon(entry.key),
                            _getKategoriColor(entry.key),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  SizedBox(height: 24),

                  // Recent Activity
                  Text(
                    'Aktivitas Terakhir',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildRecentActivity(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // MATERI: ENCAPSULATION - Private helper method
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
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
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00897B),
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildKategoriCard(
    String kategori,
    int jumlah,
    IconData icon,
    Color color,
  ) {
    return GestureDetector(
      onTap: () {
        Get.to(() => MateriList(kategori: kategori));
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
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kategori,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00897B),
                    ),
                  ),
                  Text(
                    '$jumlah materi tersedia',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('hasil_belajar')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('results')
          .orderBy('timestamp', descending: true)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Belum ada aktivitas',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return Container(
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      data['materiJudul'] ?? 'Materi',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    'Nilai: ${data['nilai']}',
                    style: TextStyle(
                      color: Color(0xFF00897B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
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
