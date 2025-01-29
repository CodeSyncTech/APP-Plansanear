import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/auth_model.dart';

class AuthController {
  final AuthModel _authModel = AuthModel();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> handleSignIn(String email, String password) async {
    return await _authModel.signIn(email, password);
  }

  Future<UserCredential> handleSignUp({
    required String name,
    required String email,
    required String tel,
    required String password,
    required String municipio,
    required String cargo,
    required String cpf,
    required int nivelConta,
    User? currentUser, // Usuário atual tentando criar a conta
  }) async {
    try {
      // Verificar se o usuário atual tem permissão para criar este nível de conta
      if (nivelConta <= 3) {
        // Supondo que níveis 1-3 são administrativos
        final User? user = currentUser ?? _auth.currentUser;
        if (user == null) throw Exception('Usuário não autenticado');

        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        final currentUserLevel = userDoc.data()?['nivelConta'] as int? ?? 4;

        if (currentUserLevel > nivelConta) {
          throw Exception('Permissão insuficiente para criar esta conta');
        }
      }

      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(credential.user!.uid).set({
        'name': name,
        'email': email,
        'tel': tel,
        'municipio': municipio,
        'cargo': cargo,
        'cpf': cpf,
        'nivelConta': nivelConta,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return credential;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> handleSignOut() async {
    await _authModel.signOut();
  }
}
