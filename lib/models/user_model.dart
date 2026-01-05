import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid; // UID dari Firebase Auth
  final String email;
  final String nama;
  final String role; // 'siswa' atau 'guru'
  final String? nis; // Hanya untuk siswa
  final String? nip; // Hanya untuk guru
  final DateTime? createdAt; // Timestamp dari Firestore

  UserModel({
    required this.uid,
    required this.email,
    required this.nama,
    required this.role,
    this.nis,
    this.nip,
    this.createdAt,
  });

  // Factory constructor untuk membuat UserModel dari Map (dari Firestore)
  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      nama: data['nama'] ?? '',
      role: data['role'] ?? 'siswa',
      nis: data['nis'],
      nip: data['nip'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Method untuk mengubah UserModel ke Map (untuk disimpan ke Firestore)
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nama': nama,
      'role': role,
      'nis': nis,
      'nip': nip,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  // Method untuk copy (berguna untuk update data)
  UserModel copyWith({
    String? uid,
    String? email,
    String? nama,
    String? role,
    String? nis,
    String? nip,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nama: nama ?? this.nama,
      role: role ?? this.role,
      nis: nis ?? this.nis,
      nip: nip ?? this.nip,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Override toString untuk debugging
  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, nama: $nama, role: $role, nis: $nis, nip: $nip, createdAt: $createdAt)';
  }
}
