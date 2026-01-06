import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_pbo/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> getUserData(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(uid, doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> createUserData(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<void> updateUserData(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).update(user.toMap());
  }

  Future<void> deleteUserData(String uid) async {
    return await _firestore.collection('users').doc(uid).delete();
  }
}
