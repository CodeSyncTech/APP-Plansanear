import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class AtribuirInstituicoesScreen extends StatefulWidget {
  @override
  _AtribuirInstituicoesScreenState createState() =>
      _AtribuirInstituicoesScreenState();
}

class _AtribuirInstituicoesScreenState
    extends State<AtribuirInstituicoesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  String? _selectedSetor;
  List<Map<String, String>> _instituicoes = [];
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
  String? _selectedInstituicaoOption;
  final TextEditingController _nomeInstituicaoController =
      TextEditingController();

  void _loadInstituicoes(String setorId) async {
    DocumentSnapshot doc = await _firestore
        .collection('formInfoMunicipio')
        .doc(uid)
        .collection('setores')
        .doc(setorId)
        .get();
    if (doc.exists) {
      List<dynamic>? inst = doc['instituicoes_sociais'];
      setState(() {
        _instituicoes = inst != null
            ? List<Map<String, String>>.from(
                inst.map((e) => Map<String, String>.from(e)))
            : [];
      });
    }
  }

  void _addInstituicao() {
    if (_selectedInstituicaoOption == null ||
        _nomeInstituicaoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Selecione um tipo e digite o nome completo da instituição",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.orange[600],
        ),
      );
      return;
    }

    Map<String, String> instituicao = {
      "tipo": _selectedInstituicaoOption!,
      "nome": _nomeInstituicaoController.text.trim(),
    };

    if (!_instituicoes.contains(instituicao)) {
      setState(() => _instituicoes.add(instituicao));
    }

    setState(() {
      _selectedInstituicaoOption = null;
      _nomeInstituicaoController.clear();
    });
  }

  void _removeInstituicao(int index) {
    setState(() => _instituicoes.removeAt(index));
  }

  void _saveInstituicoes() async {
    if (_selectedSetor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("Selecione um setor", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red[600],
        ),
      );
      return;
    }

    await _firestore
        .collection('formInfoMunicipio')
        .doc(uid)
        .collection('setores')
        .doc(_selectedSetor)
        .update({'instituicoes_sociais': _instituicoes});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Instituições atribuídas com sucesso",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[600],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: AppBar(
          elevation: 2,
          shadowColor: Colors.blue.shade100,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  // Conteúdo centralizado
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Image.asset(
                                'assets/logoredeplanrmbg.png',
                                height: 50,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        // Título
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Atribuição de',
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              'Instituições Sociais',
                              style: GoogleFonts.roboto(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Botão de adicionar estilizado
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: uid == null
              ? Center(
                  child: Text("Usuário não autenticado",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.red[700],
                          fontWeight: FontWeight.bold)))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSetorSelector(),
                    SizedBox(height: 25),
                    _buildInstituicaoForm(),
                    SizedBox(height: 25),
                    _buildInstituicoesList(),
                    SizedBox(height: 20),
                    _buildSaveButton(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSetorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Selecione um setor:",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900])),
        SizedBox(height: 10),
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
              return Text("Nenhum setor cadastrado.",
                  style: TextStyle(color: Colors.blueGrey));
            }
            return Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]),
              child: DropdownButtonFormField<String>(
                value: _selectedSetor,
                items: snapshot.data!.docs.map((doc) {
                  return DropdownMenuItem<String>(
                    value: doc.id,
                    child: Text(doc['nome'],
                        style:
                            TextStyle(color: Colors.blue[900], fontSize: 15)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSetor = value;
                    _instituicoes = [];
                  });
                  _loadInstituicoes(value!);
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  filled: true,
                  fillColor: Colors.transparent,
                  prefixIcon:
                      Icon(Icons.assignment_ind, color: Colors.blue[900]),
                ),
                style: TextStyle(color: Colors.blue[900]),
                dropdownColor: Colors.white,
                icon: Icon(Icons.arrow_drop_down, color: Colors.blue[900]),
                hint: Text("Selecione um setor",
                    style: TextStyle(color: Colors.blueGrey)),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInstituicaoForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tipo da Instituição:",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900])),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedInstituicaoOption,
                items: instituicoesOpcoes.map((option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child:
                        Text(option, style: TextStyle(color: Colors.blue[900])),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedInstituicaoOption = value),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  prefixIcon: Icon(Icons.category, color: Colors.blue[900]),
                ),
                style: TextStyle(color: Colors.blue[900]),
                dropdownColor: Colors.white,
                icon: Icon(Icons.arrow_drop_down, color: Colors.blue[900]),
                hint: Text("Selecione o tipo",
                    style: TextStyle(color: Colors.blueGrey)),
              ),
            ),
            SizedBox(height: 20),
            Text("Nome Completo:",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900])),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: TextField(
                controller: _nomeInstituicaoController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                  hintText: "Ex: Sindicato dos Trabalhadores Rurais",
                  hintStyle: TextStyle(color: Colors.blueGrey),
                  prefixIcon: Icon(Icons.text_fields, color: Colors.blue[900]),
                ),
              ),
            ),
            SizedBox(height: 15),
            ElevatedButton.icon(
              icon: Icon(Icons.add, size: 20),
              label: Text("Adicionar Instituição"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                elevation: 3,
              ),
              onPressed: _addInstituicao,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstituicoesList() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Instituições Adicionadas:",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900])),
          SizedBox(height: 10),
          Expanded(
            child: _instituicoes.isEmpty
                ? Center(
                    child: Text("Nenhuma instituição adicionada",
                        style: TextStyle(color: Colors.blueGrey)))
                : ListView.builder(
                    itemCount: _instituicoes.length,
                    itemBuilder: (context, index) {
                      final inst = _instituicoes[index];
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          title: Text("${inst['tipo']} - ${inst['nome']}",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue[900])),
                          trailing: Container(
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red[700]),
                              onPressed: () => _removeInstituicao(index),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _saveInstituicoes,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[600],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
          elevation: 3,
        ),
        child: Text("Salvar Atribuição",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  void dispose() {
    _nomeInstituicaoController.dispose();
    super.dispose();
  }
}
