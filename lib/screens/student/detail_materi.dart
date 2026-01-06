import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MateriDetail extends StatefulWidget {
  final String materiId;

  const MateriDetail({super.key, required this.materiId});

  @override
  State<MateriDetail> createState() => _MateriDetailState();
}

class _MateriDetailState extends State<MateriDetail> {
  Map<int, String> selectedAnswers = {};
  bool isSubmitted = false;
  int nilai = 0;

  void submitJawaban(List soal) {
    int benar = 0;

    for (int i = 0; i < soal.length; i++) {
      if (selectedAnswers[i] == soal[i]['jawaban']) {
        benar++;
      }
    }

    setState(() {
      nilai = ((benar / soal.length) * 100).round();
      isSubmitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Materi'),
        backgroundColor: const Color(0xFF00897B),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('materi')
            .doc(widget.materiId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final List soal = data['soal'] ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['judul'] ?? '',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00897B),
                  ),
                ),

                const SizedBox(height: 16),
                Text(data['konten'] ?? ''),

                const SizedBox(height: 32),
                const Text(
                  'Latihan Soal',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: soal.length,
                  itemBuilder: (context, index) {
                    final item = soal[index];
                    final List options = item['options'] ?? [];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${index + 1}. ${item['pertanyaan']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            ...options.map<Widget>((opt) {
                              return RadioListTile<String>(
                                title: Text(opt),
                                value: opt,
                                groupValue: selectedAnswers[index],
                                onChanged: isSubmitted
                                    ? null
                                    : (val) {
                                        setState(() {
                                          selectedAnswers[index] = val!;
                                        });
                                      },
                              );
                            }).toList(),

                            if (isSubmitted)
                              Text(
                                selectedAnswers[index] == item['jawaban']
                                    ? '✔ Jawaban Benar'
                                    : '✘ Salah (Jawaban benar: ${item['jawaban']})',
                                style: TextStyle(
                                  color:
                                      selectedAnswers[index] == item['jawaban']
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                if (!isSubmitted)
                  ElevatedButton(
                    onPressed: selectedAnswers.length < soal.length
                        ? null
                        : () => submitJawaban(soal),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00897B),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text(
                      'Submit Jawaban',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                if (isSubmitted)
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        const Text('Nilai Kamu'),
                        Text(
                          nilai.toString(),
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
