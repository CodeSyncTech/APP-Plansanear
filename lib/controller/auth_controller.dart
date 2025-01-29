import 'package:firebase_auth/firebase_auth.dart';
import '../model/auth_model.dart';

class AuthController {
  final AuthModel _authModel = AuthModel();

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
  }) async {
    return await _authModel.signUp(
      name: name,
      email: email,
      tel: tel,
      password: password,
      municipio: municipio,
      cargo: cargo,
      cpf: cpf,
      nivelConta: nivelConta,
    );
  }

  Future<void> handleSignOut() async {
    await _authModel.signOut();
  }
}
