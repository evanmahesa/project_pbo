import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'materi_list.dart';
import 'statistik_detail_page.dart';

class DashboardStudent extends StatefulWidget {
  final Map<String, dynamic> userData;

  const DashboardStudent({super.key, required this.userData});

  @override
  State<DashboardStudent> createState() => _DashboardStudentState();
}

class _DashboardStudentState extends State<DashboardStudent> {
  int _totalMateriSelesai = 0;
  double _nilaiRataRata = 0.0;
  int _totalPoin = 0;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _loadStatistik();
  }

  Future<void> _loadStatistik() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      QuerySnapshot hasilSnapshot = await FirebaseFirestore.instance
          .collection('hasil_belajar')
          .doc(uid)
          .collection('results')
          .get();

      if (hasilSnapshot.docs.isNotEmpty) {
        double totalNilai = 0;

        List<DateTime> tanggalAktif = [];
        for (var doc in hasilSnapshot.docs) {
          totalNilai += (doc.data() as Map<String, dynamic>)['nilai'] ?? 0;
          var data = doc.data() as Map<String, dynamic>;
          if (data['timestamp'] != null) {
            Timestamp ts = data['timestamp'];
            tanggalAktif.add(ts.toDate());
          }
        }

        tanggalAktif.sort((a, b) => b.compareTo(a));
        int streak = 0;
        DateTime? prev;
        for (var tgl in tanggalAktif) {
          DateTime hariIni = DateTime(tgl.year, tgl.month, tgl.day);
          if (prev == null) {
            prev = hariIni;
            streak = 1;
          } else {
            if (prev.difference(hariIni).inDays == 1) {
              streak++;
              prev = hariIni;
            } else if (prev.difference(hariIni).inDays == 0) {
              continue;
            } else {
              break;
            }
          }
        }
        setState(() {
          _totalMateriSelesai = hasilSnapshot.docs.length;
          _nilaiRataRata = totalNilai / hasilSnapshot.docs.length;
          _totalPoin = (_nilaiRataRata * 10).toInt();
          _streak = streak;
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
                    ],
                  ),
                  SizedBox(height: 24),

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
                          '${_streak} hari',
                          Icons.local_fire_department,
                          Color(0xFFFF9F43),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  Text(
                    'Kategori Materi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),

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

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return GestureDetector(
      onTap: () => _navigateToStatDetail(title),
      child: Container(
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
      ),
    );
  }

  void _navigateToStatDetail(String title) {
    String statType = '';
    switch (title) {
      case 'Materi Selesai':
        statType = 'materi';
        break;
      case 'Rata-rata Nilai':
        statType = 'nilai';
        break;
      case 'Total Poin':
        statType = 'poin';
        break;
      case 'Streak':
        statType = 'streak';
        break;
    }
    if (statType.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => StatistikDetailPage(
            statType: statType,
            totalMateriSelesai: _totalMateriSelesai,
            nilaiRataRata: _nilaiRataRata,
            totalPoin: _totalPoin,
            streak: _streak,
          ),
        ),
      );
    }
  }

  void _showStatDialog(String title) {
    String content;
    switch (title) {
      case 'Materi Selesai':
        content = 'Jumlah materi yang sudah kamu selesaikan.';
        break;
      case 'Rata-rata Nilai':
        content = 'Nilai rata-rata dari semua materi yang sudah kamu kerjakan.';
        break;
      case 'Total Poin':
        content = 'Total poin yang kamu dapatkan berdasarkan nilai rata-rata.';
        break;
      case 'Streak':
        content = 'Jumlah hari berturut-turut kamu aktif belajar.';
        break;
      default:
        content = '';
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Tutup'),
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
