import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Tela4 extends StatefulWidget {
  const Tela4({Key? key}) : super(key: key);

  @override
  _Tela4State createState() => _Tela4State();
}

class _Tela4State extends State<Tela4> {
  bool? _existePopulacoesTrad;
  List<Map<String, dynamic>> _populacoesTrad = [];
  final TextEditingController _tipoPopTradController = TextEditingController();
  String? _setorPopTrad;

  // Nova variável para a pergunta de políticas específicas
  bool? _possuiPoliticasTrad;
  final TextEditingController _politicasEspecificasController =
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
        if (data != null && data.containsKey('populacoesTradicionais')) {
          final popTrad = data['populacoesTradicionais'];
          setState(() {
            _existePopulacoesTrad = popTrad['existe'];
            _populacoesTrad = (popTrad['lista'] as List<dynamic>).map((item) {
              return {
                "tipo": item['tipo'] ?? "",
                "setor": item['setor'] ?? "",
              };
            }).toList();
            _possuiPoliticasTrad = popTrad['possuiPoliticasTrad'];
            _politicasEspecificasController.text =
                popTrad['politicasEspecificas'] ?? "";
          });
        }
      }
    } catch (e) {
      print("Erro ao carregar dados na Tela 4: $e");
    }
  }

  // Dropdown genérico para sim/não
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

  // Atualização: Dropdown que carrega os setores do Firestore
  Widget _buildDropdownSetorPopTrad() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('formInfoMunicipio')
          .doc(uid)
          .collection('setores')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        final setoresDocs = snapshot.data!.docs;
        if (setoresDocs.isEmpty) {
          return Text("Nenhum setor cadastrado.",
              style: TextStyle(color: Colors.blueGrey));
        }
        return DropdownButtonFormField<String>(
          value: _setorPopTrad,
          items: setoresDocs.map((doc) {
            final nome = doc['nome'] ?? "";
            return DropdownMenuItem<String>(
              value: nome,
              child: Text(nome, style: TextStyle(color: Colors.blue[900])),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              _setorPopTrad = val;
            });
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          ),
          hint: Text("Selecione um setor"),
        );
      },
    );
  }

  void _addPopTrad() {
    final tipo = _tipoPopTradController.text.trim();
    final setor = _setorPopTrad;
    if (tipo.isEmpty || setor == null || setor.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Informe o tipo de população e o setor.")),
      );
      return;
    }
    setState(() {
      _populacoesTrad.add({"tipo": tipo, "setor": setor});
      _tipoPopTradController.clear();
      _setorPopTrad = null;
    });
  }

  void _removePopTrad(int index) {
    setState(() {
      _populacoesTrad.removeAt(index);
    });
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
        "populacoesTradicionais": {
          "existe": _existePopulacoesTrad ?? false,
          "lista": _populacoesTrad,
          "possuiPoliticasTrad": _possuiPoliticasTrad ?? false,
          "politicasEspecificas": _possuiPoliticasTrad == true
              ? _politicasEspecificasController.text.trim()
              : "",
        },
      };
      await FirebaseFirestore.instance
          .collection('formInfoMunicipio')
          .doc(uid)
          .collection('caracterizacoes')
          .doc('caracterizacaoMunicipio')
          .set(dataToSave, SetOptions(merge: true));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Dados da Tela 4 salvos com sucesso!")),
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
        title: Text("Tela 4 – Populações Tradicionais"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildYesNoDropdown(
              label: "Existem populações tradicionais no Município?",
              value: _existePopulacoesTrad,
              onChanged: (val) {
                setState(() {
                  _existePopulacoesTrad = val;
                });
              },
            ),
            SizedBox(height: 8),
            Text(
              "Populações Tradicionais:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              "Ex.: Quilombolas, Indígenas, Ribeirinhos, Pescadores, etc.",
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tipoPopTradController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Tipo de População",
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(child: _buildDropdownSetorPopTrad()),
                IconButton(
                  icon: Icon(Icons.add, color: Colors.blue),
                  onPressed: _addPopTrad,
                ),
              ],
            ),
            _populacoesTrad.isEmpty
                ? Text("Nenhuma população adicionada.")
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _populacoesTrad.length,
                    itemBuilder: (ctx, i) {
                      final item = _populacoesTrad[i];
                      return ListTile(
                        title: Text(item['tipo'] ?? ""),
                        subtitle: Text("Setor: ${item['setor']}"),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removePopTrad(i),
                        ),
                      );
                    },
                  ),
            SizedBox(height: 8),
            // Pergunta sim/não para políticas específicas
            _buildYesNoDropdown(
              label:
                  "O Município possui políticas específicas voltadas para os povos tradicionais?",
              value: _possuiPoliticasTrad,
              onChanged: (val) {
                setState(() {
                  _possuiPoliticasTrad = val;
                });
              },
            ),
            if (_possuiPoliticasTrad == true) ...[
              SizedBox(height: 8),
              TextField(
                controller: _politicasEspecificasController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Descreva as políticas e como são implementadas",
                ),
                maxLines: 3,
              ),
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
    );
  }

  @override
  void dispose() {
    _tipoPopTradController.dispose();
    _politicasEspecificasController.dispose();
    super.dispose();
  }
}
