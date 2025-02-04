import 'package:Plansanear/produtos/produto_a/models/formacao_comite_model.dart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FormacaoComiteController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String collectionName = "formacao_comite";

  // Método para obter o UID do usuário logado
  String? getUserId() {
    final user = _auth.currentUser;
    return user?.uid;
  }

  Future<String> verificarStatusCargo(String cargo) async {
    String? userId = getUserId();
    if (userId == null) return "não preenchido";

    QuerySnapshot snapshot = await _firestore
        .collection(collectionName)
        .where('preenchidoPor', isEqualTo: userId)
        .where('cargo', isEqualTo: cargo)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      var data = snapshot.docs.first.data() as Map<String, dynamic>;

      // Verifica se todos os campos essenciais estão preenchidos
      bool todosPreenchidos = data['nomeCompleto'] != null &&
          data['cpf'] != null &&
          data['profissao'] != null &&
          data['funcao'] != null &&
          data['telefone'] != null &&
          data['email'] != null;

      return todosPreenchidos ? "completo" : "parcial";
    }

    return "não preenchido";
  }

  // Método para buscar o formulário do usuário para um cargo específico
  Future<FormacaoComiteProdutoA?> buscarFormularioPorCargo(String cargo) async {
    try {
      String? userId = getUserId();
      if (userId == null) {
        throw Exception("Usuário não autenticado!");
      }

      QuerySnapshot snapshot = await _firestore
          .collection(collectionName)
          .where('preenchidoPor', isEqualTo: userId)
          .where('cargo', isEqualTo: cargo)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return FormacaoComiteProdutoA.fromJson(
            snapshot.docs.first.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      print("Erro ao buscar formulário: $e");
      return null;
    }
  }

  // Método para salvar ou atualizar formulário
  Future<void> salvarOuAtualizarFormulario(FormacaoComiteProdutoA form) async {
    try {
      String? userId = getUserId();
      if (userId == null) {
        throw Exception("Usuário não autenticado!");
      }

      QuerySnapshot snapshot = await _firestore
          .collection(collectionName)
          .where('preenchidoPor', isEqualTo: userId)
          .where('cargo', isEqualTo: form.cargo)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Atualizar o registro existente
        String docId = snapshot.docs.first.id;
        await _firestore
            .collection(collectionName)
            .doc(docId)
            .update(form.toJson());
      } else {
        // Criar um novo registro
        await _firestore
            .collection(collectionName)
            .doc(form.formId)
            .set(form.toJson());
      }
    } catch (e) {
      print("Erro ao salvar ou atualizar formulário: $e");
    }
  }
}
