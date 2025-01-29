import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<UserCredential> signUp({
    required String name,
    required String email,
    required String tel,
    required String password,
    required String municipio,
    required String cargo,
    required String cpf,
    required int nivelConta,
  }) async {
    UserCredential user = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    await _firestore.collection('users').doc(user.user?.uid).set({
      'uid': user.user?.uid,
      'name': name,
      'municipio': municipio,
      'cargo': cargo,
      'tel': tel,
      'email': email,
      'cpf': cpf,
      'nivelConta': nivelConta,
    });
    return user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
