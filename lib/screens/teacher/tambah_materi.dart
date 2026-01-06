import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class TambahMateri extends StatefulWidget {
  final Map<String, dynamic> userData;

  const TambahMateri({super.key, required this.userData});

  @override
  State<TambahMateri> createState() => _TambahMateriState();
}

class _TambahMateriState extends State<TambahMateri> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _kontenController = TextEditingController();

  String _selectedKategori = 'Grammar';
  List<Map<String, dynamic>> _soalList = [];

  bool _isLoading = false;

  final List<String> _kategoriList = [
    'Grammar',
    'Vocabulary',
    'Reading',
    'Listening',
    'Speaking',
  ];

  @override
  void dispose() {
    _judulController.dispose();
    _kontenController.dispose();
    super.dispose();
  }

  void _addSoal() {
    Get.dialog(
      AlertDialog(
        title: Text('Tambah Soal'),
        content: SingleChildScrollView(
          child: _SoalDialog(
            onAdd: (soal) {
              setState(() {
                _soalList.add(soal);
              });
              Get.back();
            },
          ),
        ),
      ),
    );
  }

  Future<void> _saveMateri() async {
    if (!_formKey.currentState!.validate()) return;

    if (_soalList.isEmpty) {
      Get.snackbar(
        'Error',
        'Minimal harus ada 1 soal',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('materi').add({
        'judul': _judulController.text,
        'konten': _kontenController.text,
        'kategori': _selectedKategori,
        'soal': _soalList,
        'createdBy': FirebaseAuth.instance.currentUser!.uid,
        'createdByName': widget.userData['nama'],
        'timestamp': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Success',
        'Materi berhasil ditambahkan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menambahkan materi: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Materi'),
        backgroundColor: Color(0xFF00BFA5),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF00BFA5).withOpacity(0.1), Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Judul Materi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00897B),
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _judulController,
                  decoration: InputDecoration(
                    hintText: 'Masukkan judul materi',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Judul tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                Text(
                  'Kategori',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00897B),
                  ),
                ),
                SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedKategori,
                  decoration: InputDecoration(prefixIcon: Icon(Icons.category)),
                  items: _kategoriList.map((kategori) {
                    return DropdownMenuItem(
                      value: kategori,
                      child: Text(kategori),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedKategori = value!;
                    });
                  },
                ),
                SizedBox(height: 16),

                Text(
                  'Konten Materi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00897B),
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _kontenController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Masukkan konten/penjelasan materi',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Konten tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Soal Quiz (${_soalList.length})',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00897B),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _addSoal,
                      icon: Icon(Icons.add),
                      label: Text('Tambah Soal'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFD54F),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                if (_soalList.isEmpty)
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Belum ada soal. Klik "Tambah Soal" untuk menambahkan.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  )
                else
                  ...List.generate(_soalList.length, (index) {
                    return _buildSoalCard(index);
                  }),

                SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveMateri,
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Simpan Materi',
                            style: TextStyle(
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
    );
  }

  Widget _buildSoalCard(int index) {
    Map<String, dynamic> soal = _soalList[index];
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(0xFF00BFA5),
          child: Text('${index + 1}', style: TextStyle(color: Colors.white)),
        ),
        title: Text(
          soal['pertanyaan'],
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('Jawaban: ${soal['jawaban']}'),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            setState(() {
              _soalList.removeAt(index);
            });
          },
        ),
      ),
    );
  }
}

class _SoalDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;

  const _SoalDialog({required this.onAdd});

  @override
  State<_SoalDialog> createState() => _SoalDialogState();
}

class _SoalDialogState extends State<_SoalDialog> {
  final TextEditingController _pertanyaanController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  String? _selectedJawaban;

  @override
  void dispose() {
    _pertanyaanController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _pertanyaanController,
          decoration: InputDecoration(
            labelText: 'Pertanyaan',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        SizedBox(height: 12),
        ...List.generate(4, (index) {
          String label = String.fromCharCode(65 + index);
          return Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Radio<String>(
                  value: _optionControllers[index].text,
                  groupValue: _selectedJawaban,
                  onChanged: (value) {
                    setState(() {
                      _selectedJawaban = _optionControllers[index].text;
                    });
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _optionControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Opsi $label',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            if (_pertanyaanController.text.isEmpty) {
              Get.snackbar('Error', 'Pertanyaan tidak boleh kosong');
              return;
            }

            List<String> options = _optionControllers
                .map((c) => c.text)
                .where((text) => text.isNotEmpty)
                .toList();

            if (options.length < 2) {
              Get.snackbar('Error', 'Minimal 2 opsi jawaban');
              return;
            }

            if (_selectedJawaban == null || _selectedJawaban!.isEmpty) {
              Get.snackbar('Error', 'Pilih jawaban yang benar');
              return;
            }

            widget.onAdd({
              'pertanyaan': _pertanyaanController.text,
              'options': options,
              'jawaban': _selectedJawaban,
            });
          },
          child: Text('Tambah'),
        ),
      ],
    );
  }
}
