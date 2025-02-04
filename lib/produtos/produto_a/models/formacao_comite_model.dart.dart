import 'package:cloud_firestore/cloud_firestore.dart';

class FormacaoComiteProdutoA {
  String formId;
  String preenchidoPor;
  String nomeCompleto;
  String cpf;
  String profissao;
  String funcao;
  String telefone;
  String email;
  String cargo;

  FormacaoComiteProdutoA({
    required this.formId,
    required this.preenchidoPor,
    required this.nomeCompleto,
    required this.cpf,
    required this.profissao,
    required this.funcao,
    required this.telefone,
    required this.email,
    required this.cargo,
  });

  // Converter para JSON para salvar no banco
  Map<String, dynamic> toJson() {
    return {
      'formId': formId,
      'preenchidoPor': preenchidoPor,
      'nomeCompleto': nomeCompleto,
      'cpf': cpf,
      'profissao': profissao,
      'funcao': funcao,
      'telefone': telefone,
      'email': email,
      'cargo': cargo,
    };
  }

  // Criar um modelo a partir de um documento Firestore
  factory FormacaoComiteProdutoA.fromJson(Map<String, dynamic> json) {
    return FormacaoComiteProdutoA(
      formId: json['formId'],
      preenchidoPor: json['preenchidoPor'],
      nomeCompleto: json['nomeCompleto'],
      cpf: json['cpf'],
      profissao: json['profissao'],
      funcao: json['funcao'],
      telefone: json['telefone'],
      email: json['email'],
      cargo: json['cargo'],
    );
  }
}
