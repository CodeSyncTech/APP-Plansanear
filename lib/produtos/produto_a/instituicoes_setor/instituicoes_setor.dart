import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AtribuirInstituicoesScreen extends StatefulWidget {
  @override
  _AtribuirInstituicoesScreenState createState() =>
      _AtribuirInstituicoesScreenState();
}

class _AtribuirInstituicoesScreenState
    extends State<AtribuirInstituicoesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  // Armazena o ID do setor selecionado e a lista de instituições (cada uma como Map com "tipo" e "nome")
  String? _selectedSetor;
  List<Map<String, String>> _instituicoes = [];

  // Opções pré-definidas para o tipo de instituição, incluindo "Outro"
  final List<String> instituicoesOpcoes = [
    "Cooperativa",
    "Sindicato",
    "Associação",
    "Centro Educacional",
    "Grupo Religioso",
    "Grupo de Mulheres",
    "ONG",
    "Movimento Social",
    "Consórcio",
    "Outro"
  ];

  // Variáveis para armazenar o tipo selecionado e o nome digitado
  String? _selectedInstituicaoOption;
  final TextEditingController _nomeInstituicaoController =
      TextEditingController();

  // Carrega as instituições já atribuídas para o setor selecionado
  void _loadInstituicoes(String setorId) async {
    DocumentSnapshot doc = await _firestore
        .collection('formInfoMunicipio')
        .doc(uid)
        .collection('setores')
        .doc(setorId)
        .get();
    if (doc.exists) {
      List<dynamic>? inst = doc['instituicoes_sociais'];
      if (inst != null) {
        setState(() {
          _instituicoes = List<Map<String, String>>.from(
              inst.map((e) => Map<String, String>.from(e)));
        });
      } else {
        setState(() {
          _instituicoes = [];
        });
      }
    }
  }

  // Adiciona a instituição à lista (validando se o tipo foi selecionado e o nome informado)
  void _addInstituicao() {
    if (_selectedInstituicaoOption == null ||
        _nomeInstituicaoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Selecione um tipo e digite o nome completo da instituição")),
      );
      return;
    }
    Map<String, String> instituicao = {
      "tipo": _selectedInstituicaoOption!,
      "nome": _nomeInstituicaoController.text.trim(),
    };

    // Evita duplicidade se a mesma instituição já foi adicionada
    if (!_instituicoes.contains(instituicao)) {
      setState(() {
        _instituicoes.add(instituicao);
      });
    }
    // Limpa os campos após a adição
    setState(() {
      _selectedInstituicaoOption = null;
      _nomeInstituicaoController.clear();
    });
  }

  // Remove uma instituição da lista
  void _removeInstituicao(int index) {
    setState(() {
      _instituicoes.removeAt(index);
    });
  }

  // Salva a lista de instituições no Firestore para o setor selecionado
  void _saveInstituicoes() async {
    if (_selectedSetor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Selecione um setor")),
      );
      return;
    }
    await _firestore
        .collection('formInfoMunicipio')
        .doc(uid)
        .collection('setores')
        .doc(_selectedSetor)
        .update({
      'instituicoes_sociais': _instituicoes,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Instituições atribuídas com sucesso")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Atribuir Instituições Sociais"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: uid == null
            ? Center(child: Text("Usuário não autenticado"))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Seleção do setor (já cadastrado)
                  Text("Selecione um setor:",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('formInfoMunicipio')
                        .doc(uid)
                        .collection('setores')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Text("Nenhum setor cadastrado.");
                      }
                      final setores = snapshot.data!.docs;
                      return DropdownButtonFormField<String>(
                        value: _selectedSetor,
                        items: setores.map((doc) {
                          return DropdownMenuItem<String>(
                            value: doc.id,
                            child: Text(doc['nome']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSetor = value;
                            _instituicoes =
                                []; // Limpa a lista ao trocar de setor
                          });
                          _loadInstituicoes(value!);
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        ),
                        hint: Text("Selecione um setor"),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  // Dropdown para seleção do tipo de instituição
                  Text("Selecione o tipo da instituição social:",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedInstituicaoOption,
                    items: instituicoesOpcoes.map((option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedInstituicaoOption = value;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    ),
                    hint: Text("Selecione um tipo"),
                  ),
                  SizedBox(height: 20),
                  // Campo para o usuário digitar o nome completo da instituição
                  Text("Digite o nome completo da instituição social:",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  TextField(
                    controller: _nomeInstituicaoController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Ex: Sindicato dos Trabalhadores Rurais",
                    ),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _addInstituicao,
                    child: Text("Adicionar Instituição"),
                  ),
                  SizedBox(height: 20),
                  // Exibição das instituições adicionadas
                  Text("Instituições adicionadas:",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  _instituicoes.isEmpty
                      ? Text("Nenhuma instituição adicionada.")
                      : Expanded(
                          child: ListView.builder(
                            itemCount: _instituicoes.length,
                            itemBuilder: (context, index) {
                              var inst = _instituicoes[index];
                              return ListTile(
                                title:
                                    Text("${inst['tipo']} - ${inst['nome']}"),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeInstituicao(index),
                                ),
                              );
                            },
                          ),
                        ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _saveInstituicoes,
                      child: Text("Salvar Atribuição"),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _nomeInstituicaoController.dispose();
    super.dispose();
  }
}
