import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

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
    return Row(
      children: [
        Expanded(child: Text(label)),
        SizedBox(width: 16),
        DropdownButton<String>(
          value: dropdownValue,
          items: [
            DropdownMenuItem(value: "Sim", child: Text("Sim")),
            DropdownMenuItem(value: "Não", child: Text("Não")),
          ],
          hint: Text("Selecione"),
          onChanged: (val) {
            if (val != null) {
              onChanged(val == "Sim" ? true : false);
            }
          },
        ),
      ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tela 3 – Produto B"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Informações – Produto B:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              if (_possuiPoliticaSaneamento == true) ...[
                SizedBox(height: 8),
                Text("Anexar documento para Política de Saneamento:"),
                ElevatedButton(
                  onPressed: () => _pickAndUploadFile("politicaSaneamento"),
                  child: Text("Selecionar arquivo"),
                ),
                if (_politicaSaneamentoFileName != null)
                  Text("Arquivo: $_politicaSaneamentoFileName"),
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
              _buildYesNoDropdown(
                label: "O Município possui Plano Diretor?",
                value: _possuiPlanoDiretor,
                onChanged: (val) {
                  setState(() {
                    _possuiPlanoDiretor = val;
                  });
                },
              ),
              if (_possuiPlanoDiretor == true) ...[
                SizedBox(height: 8),
                Text("Anexar documento para Plano Diretor:"),
                ElevatedButton(
                  onPressed: () => _pickAndUploadFile("planoDiretor"),
                  child: Text("Selecionar arquivo"),
                ),
                if (_planoDiretorFileName != null)
                  Text("Arquivo: $_planoDiretorFileName"),
              ],
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  child: Text("Salvar"),
                  onPressed: _salvarDados,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
