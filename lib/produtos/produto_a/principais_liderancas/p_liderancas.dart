import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class AtribuirLiderancasScreen extends StatefulWidget {
  @override
  _AtribuirLiderancasScreenState createState() =>
      _AtribuirLiderancasScreenState();
}

class _AtribuirLiderancasScreenState extends State<AtribuirLiderancasScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  String? _selectedSetor;
  List<Map<String, String>> _liderancas = [];
  final TextEditingController _localidadeController = TextEditingController();
  final TextEditingController _liderancaController = TextEditingController();
  final TextEditingController _tipoOrganizacaoController =
      TextEditingController();
  final TextEditingController _contatoController = TextEditingController();

  void _loadLiderancas(String setorId) async {
    DocumentSnapshot doc = await _firestore
        .collection('formInfoMunicipio')
        .doc(uid)
        .collection('setores')
        .doc(setorId)
        .get();
    if (doc.exists) {
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
        SnackBar(
          content: Text("Por favor, preencha todos os campos."),
          backgroundColor: Colors.red[400],
        ),
      );
      return;
    }

    Map<String, String> novaLideranca = {
      "localidade": localidade,
      "lideranca": lideranca,
      "tipo_organizacao": tipoOrganizacao,
      "contato": contato,
    };

    if (!_liderancas.contains(novaLideranca)) {
      setState(() {
        _liderancas.add(novaLideranca);
      });
    }

    _localidadeController.clear();
    _liderancaController.clear();
    _tipoOrganizacaoController.clear();
    _contatoController.clear();
  }

  void _removeLideranca(int index) {
    setState(() {
      _liderancas.removeAt(index);
    });
  }

  Future<void> _choosePontoFocal() async {
    if (_liderancas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Adicione pelo menos uma liderança."),
          backgroundColor: Colors.red[400],
        ),
      );
      return;
    }

    String? pontoFocalSelecionado;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue.shade50, Colors.white],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Escolha o Ponto Focal",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900])),
                    SizedBox(height: 15),
                    Container(
                      height: 200,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _liderancas.length,
                        itemBuilder: (context, index) {
                          var lider = _liderancas[index];
                          return Card(
                            elevation: 2,
                            margin: EdgeInsets.symmetric(vertical: 4),
                            child: RadioListTile<String>(
                              title: Text(lider['localidade'] ?? "",
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500)),
                              value: lider['localidade'] ?? "",
                              groupValue: pontoFocalSelecionado,
                              activeColor: Colors.blue[800],
                              onChanged: (value) {
                                setStateDialog(() {
                                  pontoFocalSelecionado = value;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Cancelar",
                              style: TextStyle(color: Colors.blue[800])),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            if (pontoFocalSelecionado == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Selecione um ponto focal."),
                                  backgroundColor: Colors.red[400],
                                ),
                              );
                              return;
                            }
                            Navigator.pop(context);
                          },
                          child: Text("Confirmar",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (pontoFocalSelecionado != null) {
      _saveLiderancas(pontoFocalSelecionado!);
    }
  }

  void _saveLiderancas(String pontoFocal) async {
    if (_selectedSetor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Selecione um setor."),
          backgroundColor: Colors.red[400],
        ),
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
        backgroundColor: Colors.green[600],
      ),
    );
    Navigator.pop(context);
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
                              'Lideranças Principais',
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
          padding: const EdgeInsets.all(16),
          child: uid == null
              ? Center(child: Text("Usuário não autenticado"))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Selecione um setor:",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900])),
                    SizedBox(height: 8),
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('formInfoMunicipio')
                          .doc(uid)
                          .collection('setores')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Text("Nenhum setor cadastrado.",
                              style: TextStyle(color: Colors.blueGrey));
                        }
                        final setores = snapshot.data!.docs;
                        return Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ]),
                          child: DropdownButtonFormField<String>(
                            value: _selectedSetor,
                            items: setores.map((doc) {
                              return DropdownMenuItem<String>(
                                value: doc.id,
                                child: Text(doc['nome'],
                                    style: TextStyle(color: Colors.blue[900])),
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
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 12),
                              filled: true,
                              fillColor: Colors.transparent,
                            ),
                            style: TextStyle(color: Colors.blue[900]),
                            dropdownColor: Colors.white,
                            icon: Icon(Icons.arrow_drop_down,
                                color: Colors.blue[900]),
                            hint: Text("Selecione um setor",
                                style: TextStyle(color: Colors.blueGrey)),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 25),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Informações da Liderança:",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[900])),
                            SizedBox(height: 12),
                            _buildTextField(
                                controller: _localidadeController,
                                hint: "Localidade",
                                icon: Icons.location_on),
                            SizedBox(height: 10),
                            _buildTextField(
                                controller: _liderancaController,
                                hint: "Liderança",
                                icon: Icons.person),
                            SizedBox(height: 10),
                            _buildTextField(
                                controller: _tipoOrganizacaoController,
                                hint: "Tipo de Organização",
                                icon: Icons.group),
                            SizedBox(height: 10),
                            _buildTextField(
                                controller: _contatoController,
                                hint: "Contato",
                                icon: Icons.phone),
                            SizedBox(height: 15),
                            Center(
                              child: ElevatedButton.icon(
                                icon: Icon(Icons.add, size: 20),
                                label: Text("Adicionar Liderança"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[800],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 25, vertical: 12),
                                ),
                                onPressed: _addLideranca,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 25),
                    Text("Lideranças Adicionadas:",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900])),
                    SizedBox(height: 8),
                    _liderancas.isEmpty
                        ? Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text("Nenhuma liderança adicionada.",
                                style: TextStyle(color: Colors.blueGrey)),
                          )
                        : Expanded(
                            child: ListView.builder(
                              itemCount: _liderancas.length,
                              itemBuilder: (context, index) {
                                var lider = _liderancas[index];
                                return Card(
                                  elevation: 2,
                                  margin: EdgeInsets.symmetric(vertical: 5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 8),
                                    title: Text(
                                      "${lider['localidade']} - ${lider['lideranca']}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.blue[900]),
                                    ),
                                    subtitle: Text(
                                      "Tipo: ${lider['tipo_organizacao']} | Contato: ${lider['contato']}",
                                      style: TextStyle(color: Colors.blueGrey),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.delete,
                                          color: Colors.red[600]),
                                      onPressed: () => _removeLideranca(index),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                    SizedBox(height: 15),
                    Center(
                      child: ElevatedButton(
                        onPressed: _choosePontoFocal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 35, vertical: 15),
                          elevation: 3,
                        ),
                        child: Text("Salvar Atribuição",
                            style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon, color: Colors.blue[900]),
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade300),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
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
