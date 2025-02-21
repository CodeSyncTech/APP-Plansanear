import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AtribuirLiderancasScreen extends StatefulWidget {
  @override
  _AtribuirLiderancasScreenState createState() =>
      _AtribuirLiderancasScreenState();
}

class _AtribuirLiderancasScreenState extends State<AtribuirLiderancasScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  // ID do setor selecionado e lista de lideranças principais
  String? _selectedSetor;
  List<Map<String, String>> _liderancas = [];

  // Controllers para os campos de preenchimento
  final TextEditingController _localidadeController = TextEditingController();
  final TextEditingController _liderancaController = TextEditingController();
  final TextEditingController _tipoOrganizacaoController =
      TextEditingController();
  final TextEditingController _contatoController = TextEditingController();

  // Carrega as lideranças já cadastradas para o setor selecionado
  void _loadLiderancas(String setorId) async {
    DocumentSnapshot doc = await _firestore
        .collection('formInfoMunicipio')
        .doc(uid)
        .collection('setores')
        .doc(setorId)
        .get();
    if (doc.exists) {
      // Converte os dados do documento para Map<String, dynamic>
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('liderancas_principais')) {
        List<dynamic>? liderancasData = data['liderancas_principais'];
        if (liderancasData != null) {
          setState(() {
            _liderancas = List<Map<String, String>>.from(
              liderancasData.map((e) => Map<String, String>.from(e)),
            );
          });
        }
      } else {
        setState(() {
          _liderancas = [];
        });
      }
    }
  }

  // Adiciona uma nova liderança à lista, validando se todos os campos foram preenchidos
  void _addLideranca() {
    String localidade = _localidadeController.text.trim();
    String lideranca = _liderancaController.text.trim();
    String tipoOrganizacao = _tipoOrganizacaoController.text.trim();
    String contato = _contatoController.text.trim();

    if (localidade.isEmpty ||
        lideranca.isEmpty ||
        tipoOrganizacao.isEmpty ||
        contato.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, preencha todos os campos.")),
      );
      return;
    }

    Map<String, String> novaLideranca = {
      "localidade": localidade,
      "lideranca": lideranca,
      "tipo_organizacao": tipoOrganizacao,
      "contato": contato,
    };

    // Evita duplicidade
    if (!_liderancas.contains(novaLideranca)) {
      setState(() {
        _liderancas.add(novaLideranca);
      });
    }

    // Limpa os campos após a adição
    _localidadeController.clear();
    _liderancaController.clear();
    _tipoOrganizacaoController.clear();
    _contatoController.clear();
  }

  // Remove uma liderança da lista
  void _removeLideranca(int index) {
    setState(() {
      _liderancas.removeAt(index);
    });
  }

  // Exibe um diálogo para que o usuário escolha o ponto focal dentre as localidades cadastradas
  Future<void> _choosePontoFocal() async {
    if (_liderancas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Adicione pelo menos uma liderança.")),
      );
      return;
    }

    String? pontoFocalSelecionado;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text("Escolha o Ponto Focal"),
              content: Container(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _liderancas.length,
                  itemBuilder: (context, index) {
                    var lider = _liderancas[index];
                    return RadioListTile<String>(
                      title: Text(lider['localidade'] ?? ""),
                      value: lider['localidade'] ?? "",
                      groupValue: pontoFocalSelecionado,
                      onChanged: (value) {
                        setStateDialog(() {
                          pontoFocalSelecionado = value;
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (pontoFocalSelecionado == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Selecione um ponto focal.")),
                      );
                      return;
                    }
                    Navigator.pop(context);
                  },
                  child: Text("Confirmar"),
                ),
              ],
            );
          },
        );
      },
    );

    if (pontoFocalSelecionado != null) {
      _saveLiderancas(pontoFocalSelecionado!);
    }
  }

  // Salva as lideranças e o ponto focal no Firestore
  void _saveLiderancas(String pontoFocal) async {
    if (_selectedSetor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Selecione um setor.")),
      );
      return;
    }

    await _firestore
        .collection('formInfoMunicipio')
        .doc(uid)
        .collection('setores')
        .doc(_selectedSetor)
        .update({
      'liderancas_principais': _liderancas,
      'ponto_focal': pontoFocal,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Lideranças atribuídas com sucesso!"),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Atribuir Lideranças Principais"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: uid == null
            ? Center(child: Text("Usuário não autenticado"))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Seleção do setor
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
                            _liderancas = [];
                          });
                          _loadLiderancas(value!);
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
                  // Campos para cadastro das lideranças
                  Text("Preencha as informações da liderança:",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  TextField(
                    controller: _localidadeController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Localidade",
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _liderancaController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Liderança",
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _tipoOrganizacaoController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Tipo de Organização",
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _contatoController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Contato",
                    ),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _addLideranca,
                    child: Text("Adicionar Liderança"),
                  ),
                  SizedBox(height: 20),
                  // Exibição das lideranças adicionadas
                  Text("Lideranças adicionadas:",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  _liderancas.isEmpty
                      ? Text("Nenhuma liderança adicionada.")
                      : Expanded(
                          child: ListView.builder(
                            itemCount: _liderancas.length,
                            itemBuilder: (context, index) {
                              var lider = _liderancas[index];
                              return ListTile(
                                title: Text(
                                    "${lider['localidade']} - ${lider['lideranca']}"),
                                subtitle: Text(
                                    "Tipo: ${lider['tipo_organizacao']} | Contato: ${lider['contato']}"),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeLideranca(index),
                                ),
                              );
                            },
                          ),
                        ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _choosePontoFocal,
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
    _localidadeController.dispose();
    _liderancaController.dispose();
    _tipoOrganizacaoController.dispose();
    _contatoController.dispose();
    super.dispose();
  }
}
