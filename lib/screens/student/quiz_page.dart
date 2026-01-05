import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

// MATERI: INHERITANCE
class QuizPage extends StatefulWidget {
  final String materiId;
  final Map<String, dynamic> materiData;

  const QuizPage({super.key, required this.materiId, required this.materiData});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

// MATERI: ENCAPSULATION
class _QuizPageState extends State<QuizPage> {
  int _currentQuestion = 0;
  int _score = 0;
  // MATERI: GENERIC - Map untuk menyimpan jawaban
  Map<int, String> _answers = {};
  bool _isFinished = false;

  // MATERI: GENERIC - List soal
  late List<Map<String, dynamic>> _soal;

  @override
  void initState() {
    super.initState();
    _soal = List<Map<String, dynamic>>.from(widget.materiData['soal'] ?? []);
  }

  // MATERI: ASYNC & AWAIT
  Future<void> _submitQuiz() async {
    // Hitung score
    for (int i = 0; i < _soal.length; i++) {
      if (_answers[i] == _soal[i]['jawaban']) {
        _score++;
      }
    }

    double nilai = (_score / _soal.length) * 100;

    // Simpan hasil
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('hasil_belajar')
          .doc(uid)
          .collection('results')
          .add({
            'materiId': widget.materiId,
            'materiJudul': widget.materiData['judul'],
            'kategori': widget.materiData['kategori'],
            'nilai': nilai,
            'benar': _score,
            'total': _soal.length,
            'timestamp': FieldValue.serverTimestamp(),
            'jawaban': _answers,
          });

      setState(() {
        _isFinished = true;
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan hasil: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_soal.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Quiz'), backgroundColor: Color(0xFF00BFA5)),
        body: Center(child: Text('Tidak ada soal tersedia')),
      );
    }

    if (_isFinished) {
      return _buildResultScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.materiData['judul']}'),
        backgroundColor: Color(0xFF00BFA5),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF00BFA5), Color(0xFF00897B)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Progress
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Soal ${_currentQuestion + 1}/${_soal.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFFFD54F),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_answers.length}/${_soal.length} dijawab',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: (_currentQuestion + 1) / _soal.length,
                      backgroundColor: Colors.white30,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFFFD54F),
                      ),
                      minHeight: 8,
                    ),
                  ],
                ),
              ),

              // Question Card
              Expanded(
                child: Container(
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
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _soal[_currentQuestion]['pertanyaan'] ?? '',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00897B),
                          ),
                        ),
                        SizedBox(height: 24),
                        // MATERI: GENERIC - List options
                        ...(_soal[_currentQuestion]['options'] as List)
                            .asMap()
                            .entries
                            .map((entry) {
                              String option = entry.value;
                              bool isSelected =
                                  _answers[_currentQuestion] == option;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _answers[_currentQuestion] = option;
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 12),
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Color(0xFF00BFA5).withOpacity(0.1)
                                        : Colors.grey[100],
                                    border: Border.all(
                                      color: isSelected
                                          ? Color(0xFF00BFA5)
                                          : Colors.grey[300]!,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? Color(0xFF00BFA5)
                                                : Colors.grey,
                                            width: 2,
                                          ),
                                          color: isSelected
                                              ? Color(0xFF00BFA5)
                                              : Colors.transparent,
                                        ),
                                        child: isSelected
                                            ? Icon(
                                                Icons.check,
                                                size: 16,
                                                color: Colors.white,
                                              )
                                            : null,
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          option,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF00897B),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            })
                            .toList(),
                      ],
                    ),
                  ),
                ),
              ),

              // Navigation Buttons
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (_currentQuestion > 0)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _currentQuestion--;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Sebelumnya',
                            style: TextStyle(
                              color: Color(0xFF00BFA5),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _answers.containsKey(_currentQuestion)
                            ? () {
                                if (_currentQuestion < _soal.length - 1) {
                                  setState(() {
                                    _currentQuestion++;
                                  });
                                } else {
                                  _submitQuiz();
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFFD54F),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _currentQuestion < _soal.length - 1
                              ? 'Selanjutnya'
                              : 'Selesai',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    double nilai = (_score / _soal.length) * 100;
    String grade = nilai >= 80
        ? 'Excellent!'
        : nilai >= 60
        ? 'Good Job!'
        : 'Keep Learning!';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF00BFA5), Color(0xFF00897B)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events, size: 100, color: Color(0xFFFFD54F)),
                  SizedBox(height: 24),
                  Text(
                    grade,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${nilai.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00BFA5),
                          ),
                        ),
                        Text(
                          'Nilai Anda',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  '$_score',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                Text(
                                  'Benar',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '${_soal.length - _score}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                Text(
                                  'Salah',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFD54F),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Kembali ke Dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
