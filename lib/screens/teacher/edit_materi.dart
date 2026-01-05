import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

// MATERI: INHERITANCE
class EditMateri extends StatefulWidget {
  final String materiId;
  final Map<String, dynamic> materiData;
  final Map<String, dynamic> userData;

  const EditMateri({
    super.key,
    required this.materiId,
    required this.materiData,
    required this.userData,
  });

  @override
  State<EditMateri> createState() => _EditMateriState();
}

// MATERI: ENCAPSULATION
class _EditMateriState extends State<EditMateri> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _judulController;
  late TextEditingController _kontenController;
  late String _selectedKategori;
  late List<Map<String, dynamic>> _soalList;
  bool _isLoading = false;

  final List<String> _kategoriList = [
    'Grammar',
    'Vocabulary',
    'Reading',
    'Listening',
    'Speaking',
  ];

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.materiData['judul']);
    _kontenController = TextEditingController(
      text: widget.materiData['konten'],
    );
    _selectedKategori = widget.materiData['kategori'] ?? 'Grammar';
    _soalList = List<Map<String, dynamic>>.from(
      widget.materiData['soal'] ?? [],
    );
  }

  @override
  void dispose() {
    _judulController.dispose();
    _kontenController.dispose();
    super.dispose();
  }

  // MATERI: ASYNC & AWAIT
  Future<void> _updateMateri() async {
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
      await FirebaseFirestore.instance
          .collection('materi')
          .doc(widget.materiId)
          .update({
            'judul': _judulController.text,
            'konten': _kontenController.text,
            'kategori': _selectedKategori,
            'soal': _soalList,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      Get.snackbar(
        'Success',
        'Materi berhasil diupdate',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengupdate materi: $e',
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
        title: Text('Edit Materi'),
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
                      onPressed: () {
                        // Same dialog as TambahMateri
                        Get.snackbar(
                          'Info',
                          'Fitur tambah soal dalam edit (implementasi sama dengan tambah materi)',
                          backgroundColor: Colors.blue,
                          colorText: Colors.white,
                        );
                      },
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
                    child: Center(child: Text('Belum ada soal')),
                  )
                else
                  ...List.generate(_soalList.length, (index) {
                    Map<String, dynamic> soal = _soalList[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(0xFF00BFA5),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(color: Colors.white),
                          ),
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
                  }),

                SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateMateri,
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Update Materi',
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
}
