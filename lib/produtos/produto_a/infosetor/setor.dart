import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SetoresScreen(),
  ));
}

class SetoresScreen extends StatefulWidget {
  @override
  _SetoresScreenState createState() => _SetoresScreenState();
}

class _SetoresScreenState extends State<SetoresScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  final TextEditingController _nomeController = TextEditingController();

  void _addSetor() async {
    if (_nomeController.text.isNotEmpty && uid != null) {
      await _firestore
          .collection('formInfoMunicipio')
          .doc(uid)
          .collection('setores')
          .add({'nome': _nomeController.text});
      _nomeController.clear();
      setState(() {});
    }
  }

  void _navigateToForm(BuildContext context, String setorId) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SetorFormScreen(setorId: setorId)),
    ).then((_) => setState(() {}));
  }

  void _deleteSetor(String setorId) async {
    if (uid != null) {
      await _firestore
          .collection('formInfoMunicipio')
          .doc(uid)
          .collection('setores')
          .doc(setorId)
          .delete();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Setores")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nomeController,
                    decoration:
                        const InputDecoration(labelText: "Nome do Setor"),
                  ),
                ),
                IconButton(icon: const Icon(Icons.add), onPressed: _addSetor),
              ],
            ),
          ),
          Expanded(
            child: uid == null
                ? const Center(child: Text("Usuário não autenticado"))
                : StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('formInfoMunicipio')
                        .doc(uid)
                        .collection('setores')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Text("Nenhum setor cadastrado"));
                      }

                      final setores = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: setores.length,
                        itemBuilder: (context, index) {
                          var setor = setores[index];
                          return ListTile(
                            title: Text(setor['nome']),
                            subtitle: const Text("Clique para preencher"),
                            onTap: () => _navigateToForm(context, setor.id),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteSetor(setor.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class SetorFormScreen extends StatefulWidget {
  final String setorId;
  const SetorFormScreen({Key? key, required this.setorId}) : super(key: key);

  @override
  _SetorFormScreenState createState() => _SetorFormScreenState();
}

class _SetorFormScreenState extends State<SetorFormScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  final _formKey = GlobalKey<FormState>();

  // Controladores
  late TextEditingController _localController;
  late TextEditingController _capacidadeController;
  late TextEditingController _distanciaController;
  late TextEditingController _bairrosController;
  late TextEditingController _localidadesRuraisController;
  late TextEditingController _outraFonteUrbanaController;
  late TextEditingController _outraFonteRuralController;
  late TextEditingController _outroResponsavelUrbanoController;
  late TextEditingController _outroResponsavelRuralController;
  late TextEditingController _outroResponsavelEsgotoController;
  late TextEditingController _responsavelResiduosUrbanoController;
  late TextEditingController _responsavelResiduosRuralController;
  late TextEditingController _justificativaUrbanaController;
  late TextEditingController _justificativaRuralController;

  // Estados
  String? _energiaEletrica;
  String? _banheiros;
  String? _aguaPotavel;
  String? _areaSetor;
  List<String> _fontesAbastecimentoUrbana = [];
  List<String> _fontesAbastecimentoRural = [];
  List<String> _responsaveisAguaUrbana = [];
  List<String> _responsaveisAguaRural = [];
  String? _coletaEsgotoUrbana;
  String? _tratamentoEsgoto;
  String? _responsavelEsgoto;
  String? _coletaResiduosUrbana;
  String? _coletaResiduosRural;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadSetorData();
  }

  void _initializeControllers() {
    _localController = TextEditingController();
    _capacidadeController = TextEditingController();
    _distanciaController = TextEditingController();
    _bairrosController = TextEditingController();
    _localidadesRuraisController = TextEditingController();
    _outraFonteUrbanaController = TextEditingController();
    _outraFonteRuralController = TextEditingController();
    _outroResponsavelUrbanoController = TextEditingController();
    _outroResponsavelRuralController = TextEditingController();
    _outroResponsavelEsgotoController = TextEditingController();
    _responsavelResiduosUrbanoController = TextEditingController();
    _responsavelResiduosRuralController = TextEditingController();
    _justificativaUrbanaController = TextEditingController();
    _justificativaRuralController = TextEditingController();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildQuestion(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDropdown(String question, String? value, List<String> options,
      Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuestion(question),
        DropdownButtonFormField<String>(
          value: value,
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
          ),
          validator: (value) => value == null ? 'Selecione uma opção' : null,
        ),
        if (value == "Outro")
          TextFormField(
            controller: _getControllerForOtherField(question),
            decoration: const InputDecoration(
              labelText: "Especifique:",
              border: OutlineInputBorder(),
            ),
            validator: (value) => value!.isEmpty ? "Campo obrigatório" : null,
          ),
      ],
    );
  }

  TextEditingController _getControllerForOtherField(String question) {
    if (question.contains("responsável")) {
      if (question.contains("urbano")) return _outroResponsavelUrbanoController;
      if (question.contains("rural")) return _outroResponsavelRuralController;
      if (question.contains("esgoto")) return _outroResponsavelEsgotoController;
    }
    if (question.contains("fonte")) {
      if (question.contains("urbana")) return _outraFonteUrbanaController;
      if (question.contains("rural")) return _outraFonteRuralController;
    }
    return TextEditingController();
  }

  Widget _buildMultiSelectWithJustification({
    required String question,
    required List<String> selected,
    required List<String> options,
    required Function(List<String>) onChanged,
    required TextEditingController justificationController,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuestion(question),
        Column(
          children: options.map((option) {
            return CheckboxListTile(
              title: Text(option),
              value: selected.contains(option),
              onChanged: (bool? value) {
                List<String> newList = List.from(selected);
                value! ? newList.add(option) : newList.remove(option);
                onChanged(newList);
              },
            );
          }).toList(),
        ),
        if (selected.contains("Outro"))
          TextFormField(
            controller: _getControllerForOtherField(question),
            decoration: const InputDecoration(
              labelText: "Especifique:",
              border: OutlineInputBorder(),
            ),
            validator: (value) => selected.contains("Outro") && value!.isEmpty
                ? "Campo obrigatório"
                : null,
          ),
        if (selected.length > 1)
          TextFormField(
            controller: justificationController,
            decoration: const InputDecoration(
              labelText: "Justifique a seleção múltipla:",
              border: OutlineInputBorder(),
            ),
            validator: (value) => selected.length > 1 && value!.isEmpty
                ? "Justificativa obrigatória"
                : null,
          ),
      ],
    );
  }

  Widget _buildMultiSelect({
    required String question,
    required List<String> selected,
    required List<String> options,
    required Function(List<String>) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuestion(question),
        Column(
          children: options.map((option) {
            return CheckboxListTile(
              title: Text(option),
              value: selected.contains(option),
              onChanged: (bool? value) {
                List<String> newList = List.from(selected);
                value! ? newList.add(option) : newList.remove(option);
                onChanged(newList);
              },
            );
          }).toList(),
        ),
        if (selected.contains("Outro"))
          TextFormField(
            controller: _getControllerForOtherField(question),
            decoration: const InputDecoration(
              labelText: "Especifique:",
              border: OutlineInputBorder(),
            ),
            validator: (value) => selected.contains("Outro") && value!.isEmpty
                ? "Campo obrigatório"
                : null,
          ),
      ],
    );
  }

  void _loadSetorData() async {
    if (uid != null) {
      DocumentSnapshot doc = await _firestore
          .collection('formInfoMunicipio')
          .doc(uid)
          .collection('setores')
          .doc(widget.setorId)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          _localController.text = data['local'] ?? '';
          _capacidadeController.text = data['capacidade']?.toString() ?? '';
          _distanciaController.text = data['distancia']?.toString() ?? '';
          _energiaEletrica = data['energia_eletrica'];
          _banheiros = data['banheiros'];
          _aguaPotavel = data['agua_potavel'];
          _areaSetor = data['area_setor'];
          _fontesAbastecimentoUrbana =
              List<String>.from(data['fontes_agua_urbana'] ?? []);
          _fontesAbastecimentoRural =
              List<String>.from(data['fontes_agua_rural'] ?? []);
          _responsaveisAguaUrbana =
              List<String>.from(data['responsaveis_agua_urbana'] ?? []);
          _responsaveisAguaRural =
              List<String>.from(data['responsaveis_agua_rural'] ?? []);
          _coletaEsgotoUrbana = data['coleta_esgoto_urbana'];
          _tratamentoEsgoto = data['tratamento_esgoto'];
          _responsavelEsgoto = data['responsavel_esgoto'];
          _coletaResiduosUrbana = data['coleta_residuos_urbana'];
          _coletaResiduosRural = data['coleta_residuos_rural'];
          _bairrosController.text = data['bairros'] ?? '';
          _localidadesRuraisController.text = data['localidades_rurais'] ?? '';
          _outraFonteUrbanaController.text = data['outra_fonte_urbana'] ?? '';
          _outraFonteRuralController.text = data['outra_fonte_rural'] ?? '';
          _outroResponsavelUrbanoController.text =
              data['outro_responsavel_urbano'] ?? '';
          _outroResponsavelRuralController.text =
              data['outro_responsavel_rural'] ?? '';
          _outroResponsavelEsgotoController.text =
              data['outro_responsavel_esgoto'] ?? '';
          _responsavelResiduosUrbanoController.text =
              data['responsavel_residuos_urbano'] ?? '';
          _responsavelResiduosRuralController.text =
              data['responsavel_residuos_rural'] ?? '';
          _justificativaUrbanaController.text =
              data['justificativa_urbana'] ?? '';
          _justificativaRuralController.text =
              data['justificativa_rural'] ?? '';
        });
      }
    }
    setState(() => _isLoading = false);
  }

  void _saveSetor() async {
    if (_formKey.currentState!.validate() && uid != null) {
      Map<String, dynamic> setorData = {
        'local': _localController.text,
        'capacidade': int.tryParse(_capacidadeController.text),
        'distancia': int.tryParse(_distanciaController.text),
        'energia_eletrica': _energiaEletrica,
        'banheiros': _banheiros,
        'agua_potavel': _aguaPotavel,
        'area_setor': _areaSetor,
        'fontes_agua_urbana': _fontesAbastecimentoUrbana,
        'fontes_agua_rural': _fontesAbastecimentoRural,
        'responsaveis_agua_urbana': _responsaveisAguaUrbana,
        'responsaveis_agua_rural': _responsaveisAguaRural,
        'coleta_esgoto_urbana': _coletaEsgotoUrbana,
        'tratamento_esgoto': _tratamentoEsgoto,
        'responsavel_esgoto': _responsavelEsgoto,
        'coleta_residuos_urbana': _coletaResiduosUrbana,
        'coleta_residuos_rural': _coletaResiduosRural,
        'bairros': _bairrosController.text,
        'localidades_rurais': _localidadesRuraisController.text,
        'outra_fonte_urbana': _outraFonteUrbanaController.text,
        'outra_fonte_rural': _outraFonteRuralController.text,
        'outro_responsavel_urbano': _outroResponsavelUrbanoController.text,
        'outro_responsavel_rural': _outroResponsavelRuralController.text,
        'outro_responsavel_esgoto': _outroResponsavelEsgotoController.text,
        'responsavel_residuos_urbano':
            _responsavelResiduosUrbanoController.text,
        'responsavel_residuos_rural': _responsavelResiduosRuralController.text,
        'justificativa_urbana': _justificativaUrbanaController.text,
        'justificativa_rural': _justificativaRuralController.text,
      };

      await _firestore
          .collection('formInfoMunicipio')
          .doc(uid)
          .collection('setores')
          .doc(widget.setorId)
          .set(setorData, SetOptions(merge: true));

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Questionário Completo"),
        elevation: 4,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Informações Básicas"),
                    _buildQuestion(
                        "1. Indique um local para realização de eventos:"),
                    TextFormField(
                      controller: _localController,
                      decoration: const InputDecoration(
                        hintText: "Ex: Escola Municipal, Centro Comunitário...",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Campo obrigatório" : null,
                    ),
                    const SizedBox(height: 20),
                    _buildQuestion("2. Capacidade máxima do local:"),
                    TextFormField(
                      controller: _capacidadeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        suffixText: "pessoas",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Campo obrigatório" : null,
                    ),
                    const SizedBox(height: 20),
                    _buildQuestion("3. Distância até a Sede do Município:"),
                    TextFormField(
                      controller: _distanciaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        suffixText: "quilômetros",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Campo obrigatório" : null,
                    ),
                    _buildSectionTitle("Infraestrutura"),
                    _buildDropdown(
                      "4. O local possui energia elétrica?",
                      _energiaEletrica,
                      ["Sim", "Não"],
                      (value) => setState(() => _energiaEletrica = value),
                    ),
                    _buildDropdown(
                      "5. O local possui banheiros?",
                      _banheiros,
                      ["Sim", "Não"],
                      (value) => setState(() => _banheiros = value),
                    ),
                    _buildDropdown(
                      "6. O local possui água potável?",
                      _aguaPotavel,
                      ["Sim", "Não"],
                      (value) => setState(() => _aguaPotavel = value),
                    ),
                    _buildSectionTitle("Características do Setor"),
                    _buildDropdown(
                      "7. Área predominante:",
                      _areaSetor,
                      ["Área urbana", "Área rural", "Área urbana e rural"],
                      (value) => setState(() => _areaSetor = value),
                    ),
                    if (_areaSetor != null && _areaSetor!.contains("urbana"))
                      Column(
                        children: [
                          _buildQuestion("8. Bairros existentes:"),
                          TextFormField(
                            controller: _bairrosController,
                            decoration: const InputDecoration(
                              hintText: "Separar por vírgula",
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => (value!.isEmpty &&
                                    _areaSetor!.contains("urbana"))
                                ? "Campo obrigatório"
                                : null,
                          ),
                        ],
                      ),
                    if (_areaSetor != null && _areaSetor!.contains("rural"))
                      Column(
                        children: [
                          _buildQuestion("9. Localidades rurais:"),
                          TextFormField(
                            controller: _localidadesRuraisController,
                            decoration: const InputDecoration(
                              hintText: "Separar por vírgula",
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => (value!.isEmpty &&
                                    _areaSetor!.contains("rural"))
                                ? "Campo obrigatório"
                                : null,
                          ),
                        ],
                      ),
                    _buildSectionTitle("Abastecimento de Água"),
                    _buildMultiSelect(
                      question: "10. Fontes na área urbana:",
                      selected: _fontesAbastecimentoUrbana,
                      options: [
                        "Rio",
                        "Riacho",
                        "Cisterna/Água da Chuva",
                        "Cisterna/Pipa",
                        "Poço comunitário",
                        "Poço próprio",
                        "Outra"
                      ],
                      onChanged: (value) =>
                          setState(() => _fontesAbastecimentoUrbana = value),
                    ),
                    _buildMultiSelect(
                      question: "11. Fontes na área rural:",
                      selected: _fontesAbastecimentoRural,
                      options: [
                        "Rio",
                        "Riacho",
                        "Cisterna/Água da Chuva",
                        "Cisterna/Pipa",
                        "Poço comunitário",
                        "Poço próprio",
                        "Outra"
                      ],
                      onChanged: (value) =>
                          setState(() => _fontesAbastecimentoRural = value),
                    ),
                    _buildSectionTitle("Responsáveis pelo Abastecimento"),
                    _buildMultiSelectWithJustification(
                      question: "12. Responsáveis urbanos:",
                      selected: _responsaveisAguaUrbana,
                      options: [
                        "Prefeitura (secretaria)",
                        "SAAE",
                        "Exército",
                        "Outro"
                      ],
                      onChanged: (value) =>
                          setState(() => _responsaveisAguaUrbana = value),
                      justificationController: _justificativaUrbanaController,
                    ),
                    _buildMultiSelectWithJustification(
                      question: "13. Responsáveis rurais:",
                      selected: _responsaveisAguaRural,
                      options: [
                        "Prefeitura (secretaria)",
                        "SAAE",
                        "Exército",
                        "Outro"
                      ],
                      onChanged: (value) =>
                          setState(() => _responsaveisAguaRural = value),
                      justificationController: _justificativaRuralController,
                    ),
                    _buildSectionTitle("Gestão de Esgoto"),
                    _buildDropdown(
                      "14. Coleta de esgoto urbano:",
                      _coletaEsgotoUrbana,
                      ["Sim", "Não"],
                      (value) => setState(() => _coletaEsgotoUrbana = value),
                    ),
                    if (_coletaEsgotoUrbana == "Sim") ...[
                      _buildDropdown(
                        "15. Tratamento de esgoto:",
                        _tratamentoEsgoto,
                        ["Sim", "Não"],
                        (value) => setState(() => _tratamentoEsgoto = value),
                      ),
                      _buildDropdown(
                        "16. Responsável pelo tratamento:",
                        _responsavelEsgoto,
                        ["Morador", "Prefeitura", "Outro"],
                        (value) => setState(() => _responsavelEsgoto = value),
                      ),
                      if (_responsavelEsgoto == "Outro")
                        TextFormField(
                          controller: _outroResponsavelEsgotoController,
                          decoration: const InputDecoration(
                            labelText: "Especificar responsável:",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              (_responsavelEsgoto == "Outro" && value!.isEmpty)
                                  ? "Campo obrigatório"
                                  : null,
                        ),
                    ],
                    _buildSectionTitle("Gestão de Resíduos"),
                    _buildDropdown(
                      "17. Coleta de resíduos urbanos:",
                      _coletaResiduosUrbana,
                      ["Sim", "Não"],
                      (value) => setState(() => _coletaResiduosUrbana = value),
                    ),
                    if (_coletaResiduosUrbana == "Sim")
                      TextFormField(
                        controller: _responsavelResiduosUrbanoController,
                        decoration: const InputDecoration(
                          labelText: "Responsável urbano:",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            (_coletaResiduosUrbana == "Sim" && value!.isEmpty)
                                ? "Campo obrigatório"
                                : null,
                      ),
                    _buildDropdown(
                      "18. Coleta de resíduos rurais:",
                      _coletaResiduosRural,
                      ["Sim", "Não"],
                      (value) => setState(() => _coletaResiduosRural = value),
                    ),
                    if (_coletaResiduosRural == "Sim")
                      TextFormField(
                        controller: _responsavelResiduosRuralController,
                        decoration: const InputDecoration(
                          labelText: "Responsável rural:",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            (_coletaResiduosRural == "Sim" && value!.isEmpty)
                                ? "Campo obrigatório"
                                : null,
                      ),
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: _saveSetor,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "SALVAR QUESTIONÁRIO",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
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
    _localController.dispose();
    _capacidadeController.dispose();
    _distanciaController.dispose();
    _bairrosController.dispose();
    _localidadesRuraisController.dispose();
    _outraFonteUrbanaController.dispose();
    _outraFonteRuralController.dispose();
    _outroResponsavelUrbanoController.dispose();
    _outroResponsavelRuralController.dispose();
    _outroResponsavelEsgotoController.dispose();
    _responsavelResiduosUrbanoController.dispose();
    _responsavelResiduosRuralController.dispose();
    _justificativaUrbanaController.dispose();
    _justificativaRuralController.dispose();
    super.dispose();
  }
}
