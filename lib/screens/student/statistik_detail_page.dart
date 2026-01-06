import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StatistikDetailPage extends StatelessWidget {
  final String statType;
  final int totalMateriSelesai;
  final double nilaiRataRata;
  final int totalPoin;
  final int streak;

  const StatistikDetailPage({
    super.key,
    required this.statType,
    required this.totalMateriSelesai,
    required this.nilaiRataRata,
    required this.totalPoin,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        backgroundColor: const Color(0xFF00897B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _buildDetail(context),
      ),
    );
  }

  String _getTitle() {
    switch (statType) {
      case 'materi':
        return 'Detail Materi Selesai';
      case 'nilai':
        return 'Detail Rata-rata Nilai';
      case 'poin':
        return 'Detail Total Poin';
      case 'streak':
        return 'Detail Streak';
      default:
        return 'Detail Statistik';
    }
  }

  Widget _buildDetail(BuildContext context) {
    switch (statType) {
      case 'materi':
        return _buildMateriList();
      case 'nilai':
        return _buildNilaiList();
      case 'poin':
        return _buildPoinInfo();
      case 'streak':
        return _buildStreakInfo();
      default:
        return const Text('Data tidak ditemukan');
    }
  }

  Widget _buildMateriList() {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('hasil_belajar')
          .doc(uid)
          .collection('results')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Belum ada materi yang selesai'));
        }
        return ListView(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ListTile(
              title: Text(data['materiJudul'] ?? 'Materi'),
              subtitle: Text('Nilai: ${data['nilai'] ?? 0}'),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildNilaiList() {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('hasil_belajar')
          .doc(uid)
          .collection('results')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Belum ada nilai'));
        }
        return ListView(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ListTile(
              title: Text(data['materiJudul'] ?? 'Materi'),
              subtitle: Text('Nilai: ${data['nilai'] ?? 0}'),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildPoinInfo() {
    return Center(
      child: Text(
        'Total Poin: $totalPoin\nPoin dihitung dari rata-rata nilai x 10.',
        style: const TextStyle(fontSize: 18),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildStreakInfo() {
    return Center(
      child: Text(
        'Streak: $streak hari berturut-turut aktif belajar.',
        style: const TextStyle(fontSize: 18),
        textAlign: TextAlign.center,
      ),
    );
  }
}

extension DoubleExtension on double {
  String toFormattedString() {
    return this.toStringAsFixed(2);
  }
}
