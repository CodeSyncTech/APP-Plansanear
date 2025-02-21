import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class OrganizacaoMunicipioScreen extends StatefulWidget {
  @override
  _OrganizacaoMunicipioScreenState createState() =>
      _OrganizacaoMunicipioScreenState();
}

class _OrganizacaoMunicipioScreenState
    extends State<OrganizacaoMunicipioScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, TextEditingController>> _fields = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    DocumentSnapshot doc =
        await _firestore.collection("organizacaoMunicipio").doc(user.uid).get();

    setState(() {
      _fields.clear();
      if (doc.exists && doc.data() != null) {
        List<dynamic> dados =
            (doc.data() as Map<String, dynamic>)["dados"] ?? [];
        for (var item in dados) {
          _fields.add({
            "conselhos": TextEditingController(text: item["conselho"]),
            "leiDecreto": TextEditingController(text: item["leiDecreto"]),
          });
        }
      }
      if (_fields.isEmpty) _addNewField();
      _isLoading = false;
    });
  }

  void _addNewField() {
    setState(() {
      _fields.add({
        "conselhos": TextEditingController(),
        "leiDecreto": TextEditingController(),
      });
    });
  }

  void _removeField(int index) {
    setState(() {
      _fields[index]["conselhos"]!.dispose();
      _fields[index]["leiDecreto"]!.dispose();
      _fields.removeAt(index);
    });
  }

  Future<void> _saveData() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    List<Map<String, String>> listaConselhos = [];
    for (var field in _fields) {
      String conselho = field["conselhos"]!.text.trim();
      String leiDecreto = field["leiDecreto"]!.text.trim();

      if (conselho.isEmpty || leiDecreto.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Preencha todos os campos!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      listaConselhos.add({"conselho": conselho, "leiDecreto": leiDecreto});
    }

    await _firestore.collection("organizacaoMunicipio").doc(user.uid).set({
      "dados": listaConselhos,
      "timestamp": FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dados salvos com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).pop();
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueGrey.shade100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildActionButton(
      String text, IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.9), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 20, color: Colors.white),
        label: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                              'Organização Social',
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              'do Município',
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
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                strokeWidth: 2.5,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      'Conselhos Municipais',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.blue.shade800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _fields.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return Material(
                          elevation: 1.5,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade100,
                                width: 1.5,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  _buildTextField(_fields[index]["conselhos"]!,
                                      "Conselhos Municipais existentes"),
                                  SizedBox(height: 16),
                                  _buildTextField(_fields[index]["leiDecreto"]!,
                                      "Base Legal (Lei/Decreto)"),
                                  if (_fields.length > 1)
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: IconButton(
                                        icon: Icon(Icons.delete_rounded,
                                            color: Colors.red.shade500,
                                            size: 22),
                                        onPressed: () => _removeField(index),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          'Novo Registro',
                          Icons.add_circle_outline,
                          Colors.blue.shade600,
                          _addNewField,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          'Salvar Tudo',
                          Icons.save_rounded,
                          Colors.green.shade600,
                          _saveData,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
