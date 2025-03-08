import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Classe responsável pelas operações de autenticação
class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Método de login
  Future<UserCredential> handleSignIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Método de cadastro utilizando instância secundária do Firebase
  Future<UserCredential> handleSignUp({
    required String name,
    required String email,
    required String tel,
    required String password,
    required String municipio,
    required String estado,
    required String cargo,
    required String cpf,
    required int nivelConta,
    User? currentUser,
  }) async {
    try {
      // Cria o usuário sem afetar a sessão atual
      UserCredential credential =
          await _createUserWithoutAffectingSession(email, password);

      // Adiciona os dados do usuário no Firestore
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'name': name,
        'email': email,
        'tel': tel,
        'municipio': municipio,
        'estado': estado,
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

  /// Cria um usuário usando uma instância secundária do Firebase
  Future<UserCredential> _createUserWithoutAffectingSession(
      String email, String password) async {
    // Inicializa uma instância secundária com um nome diferente
    final secondaryApp = await Firebase.initializeApp(
      name: 'SecondaryApp',
      options: Firebase.app().options,
    );
    // Obtém a instância de autenticação associada à instância secundária
    final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

    // Cria o usuário na instância secundária
    UserCredential credential =
        await secondaryAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Finaliza a instância secundária, se não for mais necessária
    await secondaryApp.delete();
    return credential;
  }

  /// Método para realizar logout
  Future<void> handleSignOut() async {
    await _auth.signOut();
  }
}
