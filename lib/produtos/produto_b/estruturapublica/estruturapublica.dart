import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class Tela1 extends StatefulWidget {
  const Tela1({Key? key}) : super(key: key);

  @override
  _Tela1State createState() => _Tela1State();
}

class _Tela1State extends State<Tela1> {
  String? _qtdVereadores;
  final TextEditingController _leiMunicipalController = TextEditingController();
  List<Map<String, dynamic>> _programasSaneamento = [];
  final TextEditingController _programaSaneamentoController =
      TextEditingController();
  final TextEditingController _secretariaSaneamentoController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDados();
  }

  Future<void> _loadDados() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('formInfoMunicipio')
          .doc(uid)
          .collection('caracterizacoes')
          .doc('caracterizacaoMunicipio')
          .get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          if (data.containsKey('estruturaPublicaMunicipal')) {
            final esp = data['estruturaPublicaMunicipal'];
            setState(() {
              _qtdVereadores = esp['qtdVereadores'];
              _leiMunicipalController.text = esp['leiMunicipal'] ?? "";
            });
          }
          if (data.containsKey('programasAcoesSaneamento')) {
            final List<dynamic> programas = data['programasAcoesSaneamento'];
            setState(() {
              _programasSaneamento = programas.map((item) {
                return {
                  "programa": item['programa'] ?? "",
                  "secretaria": item['secretaria'] ?? "",
                };
              }).toList();
            });
          }
        }
      }
    } catch (e) {
      print("Erro ao carregar dados na Tela 1: $e");
    }
  }

  void _addProgramaSaneamento() {
    final prog = _programaSaneamentoController.text.trim();
    final sec = _secretariaSaneamentoController.text.trim();
    if (prog.isEmpty || sec.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Informe o programa e a secretaria responsável.",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.orange[600],
        ),
      );
      return;
    }
    setState(() {
      _programasSaneamento.add({"programa": prog, "secretaria": sec});
      _programaSaneamentoController.clear();
      _secretariaSaneamentoController.clear();
    });
  }

  void _removeProgramaSaneamento(int index) {
    setState(() {
      _programasSaneamento.removeAt(index);
    });
  }

  Widget _buildDropdownVereadores() {
    final options = List<String>.generate(21, (i) => '${i + 5}');
    return Container(
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
        value: _qtdVereadores,
        items: options
            .map((op) => DropdownMenuItem(
                  value: op,
                  child: Text(op, style: TextStyle(color: Colors.blue[900])),
                ))
            .toList(),
        onChanged: (value) => setState(() => _qtdVereadores = value),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          prefixIcon: Icon(Icons.people, color: Colors.blue[900]),
        ),
        style: TextStyle(color: Colors.blue[900]),
        dropdownColor: Colors.white,
        hint: Text("Selecione a quantidade",
            style: TextStyle(color: Colors.blueGrey)),
      ),
    );
  }

  Future<void> _salvarDados() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Usuário não autenticado.",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red[600],
        ),
      );
      return;
    }
    try {
      final dataToSave = {
        "estruturaPublicaMunicipal": {
          "qtdVereadores": _qtdVereadores ?? "",
          "leiMunicipal": _leiMunicipalController.text.trim(),
        },
        "programasAcoesSaneamento": _programasSaneamento,
      };
      await FirebaseFirestore.instance
          .collection('formInfoMunicipio')
          .doc(uid)
          .collection('caracterizacoes')
          .doc('caracterizacaoMunicipio')
          .set(dataToSave, SetOptions(merge: true));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Dados da Tela 1 salvos com sucesso!",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green[600],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao salvar dados: $e",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red[600],
        ),
      );
    }
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
                mainAxisAlignment:
                    MainAxisAlignment.center, // Centralização principal
                children: [
                  // Logo centralizado
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

                  // Título centralizado verticalmente
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estrutura e',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        'Saneamento',
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
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      Text("Câmara Municipal",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900])),
                      SizedBox(height: 15),
                      Text("Quantidade de vereadores:",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue[900])),
                      SizedBox(height: 8),
                      _buildDropdownVereadores(),
                      SizedBox(height: 15),
                      Text("Lei Municipal:",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue[900])),
                      SizedBox(height: 8),
                      TextField(
                        controller: _leiMunicipalController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Ex.: Lei nº 123/2021",
                          prefixIcon:
                              Icon(Icons.gavel, color: Colors.blue[900]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
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
                      Text("Programas Municipais",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900])),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _programaSaneamentoController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                hintText: "Programa",
                                prefixIcon: Icon(Icons.assignment,
                                    color: Colors.blue[900]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 12),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _secretariaSaneamentoController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                hintText: "Secretaria Responsável",
                                prefixIcon: Icon(Icons.account_balance,
                                    color: Colors.blue[900]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 12),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton.icon(
                            icon: Icon(Icons.add, size: 20),
                            label: Text("Adicionar"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[800],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _addProgramaSaneamento,
                          )
                        ],
                      ),
                      SizedBox(height: 15),
                      _programasSaneamento.isEmpty
                          ? Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Text("Nenhum programa adicionado",
                                  style: TextStyle(color: Colors.blueGrey)),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _programasSaneamento.length,
                              itemBuilder: (ctx, i) {
                                final item = _programasSaneamento[i];
                                return Card(
                                  elevation: 2,
                                  margin: EdgeInsets.symmetric(vertical: 5),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 8),
                                    title: Text(item['programa'] ?? "",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.blue[900])),
                                    subtitle: Text(
                                        "Secretaria: ${item['secretaria']}",
                                        style:
                                            TextStyle(color: Colors.blueGrey)),
                                    trailing: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red[50],
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.red[700]),
                                        onPressed: () =>
                                            _removeProgramaSaneamento(i),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 25),
              Center(
                child: ElevatedButton(
                  onPressed: _salvarDados,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    elevation: 3,
                  ),
                  child: Text("Salvar Dados",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _leiMunicipalController.dispose();
    _programaSaneamentoController.dispose();
    _secretariaSaneamentoController.dispose();
    super.dispose();
  }
}
