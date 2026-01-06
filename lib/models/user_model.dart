import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String nama;
  final String role;
  final String? nis;
  final String? nip;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.nama,
    required this.role,
    this.nis,
    this.nip,
    this.createdAt,
  });

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

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, nama: $nama, role: $role, nis: $nis, nip: $nip, createdAt: $createdAt)';
  }
}
