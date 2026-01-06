import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_pbo/extensions/firestore_extensions.dart';

class MateriDetail extends StatelessWidget {
  final String materiId;
  const MateriDetail({super.key, required this.materiId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Materi',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF00897B),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('materi')
            .doc(materiId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Materi tidak ditemukan'));
          }

          final doc = snapshot.data!;
          final judul = doc.getString('judul', defaultValue: 'Judul Materi');
          final deskripsi = doc.getString(
            'deskripsi',
            defaultValue: 'Deskripsi materi',
          );

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00897B),
                  ),
                ),
                const SizedBox(height: 16),
                Text(deskripsi, style: const TextStyle(fontSize: 16)),
              ],
            ),
          );
        },
      ),
    );
  }
}
