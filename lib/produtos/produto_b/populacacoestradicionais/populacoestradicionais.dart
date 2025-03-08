import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

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
                    DropdownMenuItem(
                      value: "Sim",
                      child: Text("Sim",
                          style: TextStyle(color: Colors.green[800])),
                    ),
                    DropdownMenuItem(
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
                        'Populações',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        'Tradicionais',
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
                _buildYesNoDropdown(
                  label: "Existem populações tradicionais no Município?",
                  value: _existePopulacoesTrad,
                  onChanged: (val) =>
                      setState(() => _existePopulacoesTrad = val),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Cadastro de Populações Tradicionais",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue[800],
                              fontWeight: FontWeight.w600,
                            )),
                        const SizedBox(height: 12),
                        Text("Ex.: Quilombolas, Indígenas, Ribeirinhos, etc.",
                            style: TextStyle(
                              color: Colors.blueGrey[600],
                              fontStyle: FontStyle.italic,
                            )),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _tipoPopTradController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.blue[50],
                                  hintText: "Tipo de População",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDropdownSetorPopTrad(),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blue[800],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: IconButton(
                                icon:
                                    const Icon(Icons.add, color: Colors.white),
                                onPressed: _addPopTrad,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_populacoesTrad.isNotEmpty)
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _populacoesTrad.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) => Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        title: Text(
                          _populacoesTrad[i]['tipo'],
                          style: TextStyle(
                            color: Colors.blueGrey[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          "Setor: ${_populacoesTrad[i]['setor']}",
                          style: TextStyle(color: Colors.blueGrey[600]),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline,
                              color: Colors.red[600]),
                          onPressed: () => _removePopTrad(i),
                        ),
                        tileColor: Colors.blue[50],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                _buildYesNoDropdown(
                  label:
                      "O Município possui políticas específicas para povos tradicionais?",
                  value: _possuiPoliticasTrad,
                  onChanged: (val) =>
                      setState(() => _possuiPoliticasTrad = val),
                ),
                if (_possuiPoliticasTrad == true) ...[
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _politicasEspecificasController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.blue[50],
                          hintText: "Descreva as políticas e implementação...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
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
          return CircularProgressIndicator(color: Colors.blue[800]);
        }
        final setoresDocs = snapshot.data!.docs;
        if (setoresDocs.isEmpty) {
          return Text("Nenhum setor cadastrado.",
              style: TextStyle(color: Colors.blueGrey));
        }
        return Container(
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonFormField<String>(
            value: _setorPopTrad,
            items: setoresDocs.map((doc) {
              final nome = doc['nome'] ?? "";
              return DropdownMenuItem<String>(
                value: nome,
                child: Text(nome, style: TextStyle(color: Colors.blue[900])),
              );
            }).toList(),
            onChanged: (val) => setState(() => _setorPopTrad = val),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
              border: InputBorder.none,
              hintText: "Selecione o setor",
            ),
            dropdownColor: Colors.blue[50],
          ),
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
  void dispose() {
    _tipoPopTradController.dispose();
    _politicasEspecificasController.dispose();
    super.dispose();
  }
}
