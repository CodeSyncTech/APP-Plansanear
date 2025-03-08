import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class Tela3 extends StatefulWidget {
  const Tela3({Key? key}) : super(key: key);

  @override
  _Tela3State createState() => _Tela3State();
}

class _Tela3State extends State<Tela3> {
  bool? _possuiPoliticaSaneamento;
  bool? _haConselhoSaneamento;
  bool? _possuiPlanoDiretor;

  // Variáveis para armazenar os dados dos arquivos
  String? _politicaSaneamentoFileName;
  String? _politicaSaneamentoFileURL;

  String? _planoDiretorFileName;
  String? _planoDiretorFileURL;

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
        if (data != null && data.containsKey('produtoB')) {
          final produtoB = data['produtoB'];
          setState(() {
            _possuiPoliticaSaneamento = produtoB['politicaSaneamento'];
            _haConselhoSaneamento = produtoB['conselhoSaneamento'];
            _possuiPlanoDiretor = produtoB['planoDiretor'];
            if (produtoB.containsKey('documentoPoliticaSaneamento')) {
              _politicaSaneamentoFileName =
                  produtoB['documentoPoliticaSaneamento']['nome'];
              _politicaSaneamentoFileURL =
                  produtoB['documentoPoliticaSaneamento']['url'];
            }
            if (produtoB.containsKey('documentoPlanoDiretor')) {
              _planoDiretorFileName = produtoB['documentoPlanoDiretor']['nome'];
              _planoDiretorFileURL = produtoB['documentoPlanoDiretor']['url'];
            }
          });
        }
      }
    } catch (e) {
      print("Erro ao carregar dados na Tela 3: $e");
    }
  }

  Widget _buildYesNoDropdown({
    required String label,
    required bool? value,
    required Function(bool?) onChanged,
  }) {
    String? dropdownValue;
    if (value != null) {
      dropdownValue = value ? "Sim" : "Não";
    }
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blueGrey[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade100),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: dropdownValue,
                  items: [
                    DropdownMenuItem<String>(
                      value: "Sim",
                      child: Text("Sim",
                          style: TextStyle(color: Colors.green[800])),
                    ),
                    DropdownMenuItem<String>(
                      value: "Não",
                      child:
                          Text("Não", style: TextStyle(color: Colors.red[800])),
                    ),
                  ],
                  hint: Text("Selecione",
                      style: TextStyle(color: Colors.blueGrey[400])),
                  onChanged: (val) {
                    if (val != null) {
                      onChanged(val == "Sim" ? true : false);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
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
                        'Caracterização do',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        'Município',
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    "Informações – Produto B",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.blueGrey,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                _buildYesNoDropdown(
                  label: "O Município possui Política de Saneamento?",
                  value: _possuiPoliticaSaneamento,
                  onChanged: (val) {
                    setState(() {
                      _possuiPoliticaSaneamento = val;
                    });
                  },
                ),
                const SizedBox(height: 12),
                if (_possuiPoliticaSaneamento == true) ...[
                  _buildFileUploadSection(
                    title: "Anexar documento para Política de Saneamento:",
                    fileName: _politicaSaneamentoFileName,
                    onPressed: () => _pickAndUploadFile("politicaSaneamento"),
                  ),
                  const SizedBox(height: 12),
                ],
                _buildYesNoDropdown(
                  label: "Há Conselho Municipal de Saneamento Básico?",
                  value: _haConselhoSaneamento,
                  onChanged: (val) {
                    setState(() {
                      _haConselhoSaneamento = val;
                    });
                  },
                ),
                const SizedBox(height: 12),
                _buildYesNoDropdown(
                  label: "O Município possui Plano Diretor?",
                  value: _possuiPlanoDiretor,
                  onChanged: (val) {
                    setState(() {
                      _possuiPlanoDiretor = val;
                    });
                  },
                ),
                const SizedBox(height: 12),
                if (_possuiPlanoDiretor == true) ...[
                  _buildFileUploadSection(
                    title: "Anexar documento para Plano Diretor:",
                    fileName: _planoDiretorFileName,
                    onPressed: () => _pickAndUploadFile("planoDiretor"),
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save_rounded, size: 22),
                    label: const Text("SALVAR DADOS",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5)),
                    onPressed: _salvarDados,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue[800],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFileUploadSection({
    required String title,
    required String? fileName,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blueGrey[700],
                  fontWeight: FontWeight.w500,
                )),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_rounded, size: 20),
              label: const Text("Selecionar Arquivo",
                  style: TextStyle(fontSize: 14)),
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blue[800],
                backgroundColor: Colors.blue[50],
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            if (fileName != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: Colors.green[600], size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(fileName,
                        style: TextStyle(
                          color: Colors.blueGrey[800],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadFile(String field) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null &&
        (result.files.single.path != null ||
            result.files.single.bytes != null)) {
      final fileName = result.files.single.name;
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('uploads')
            .child(uid)
            .child(field)
            .child(fileName);

        UploadTask uploadTask;
        if (result.files.single.bytes != null) {
          // Se os bytes estiverem disponíveis (ex.: em Web)
          uploadTask = storageRef.putData(result.files.single.bytes!);
        } else {
          // Se houver um caminho (mobile)
          File file = File(result.files.single.path!);
          uploadTask = storageRef.putFile(file);
        }

        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();
        setState(() {
          if (field == 'politicaSaneamento') {
            _politicaSaneamentoFileName = fileName;
            _politicaSaneamentoFileURL = downloadUrl;
          } else if (field == 'planoDiretor') {
            _planoDiretorFileName = fileName;
            _planoDiretorFileURL = downloadUrl;
          }
        });
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Erro no upload: $e")));
      }
    }
  }

  Future<void> _salvarDados() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Usuário não autenticado.")));
      return;
    }
    try {
      final dataToSave = {
        "produtoB": {
          "politicaSaneamento": _possuiPoliticaSaneamento ?? false,
          "conselhoSaneamento": _haConselhoSaneamento ?? false,
          "planoDiretor": _possuiPlanoDiretor ?? false,
          "documentoPoliticaSaneamento": _possuiPoliticaSaneamento == true
              ? {
                  "nome": _politicaSaneamentoFileName ?? "",
                  "url": _politicaSaneamentoFileURL ?? "",
                }
              : null,
          "documentoPlanoDiretor": _possuiPlanoDiretor == true
              ? {
                  "nome": _planoDiretorFileName ?? "",
                  "url": _planoDiretorFileURL ?? "",
                }
              : null,
        },
      };
      await FirebaseFirestore.instance
          .collection('formInfoMunicipio')
          .doc(uid)
          .collection('caracterizacoes')
          .doc('caracterizacaoMunicipio')
          .set(dataToSave, SetOptions(merge: true));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Dados da Tela 3 salvos com sucesso!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erro ao salvar dados: $e")));
    }
  }
}
