import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

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
                              'Gerenciamento de',
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              'Setores',
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
        child: Column(
          children: [
            _buildInputSection(),
            _buildSetoresList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 243, 135, 33).withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 3,
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nomeController,
                  decoration: InputDecoration(
                    labelText: "Insira o nome do novo Setor",
                    labelStyle: TextStyle(color: Colors.blue.shade800),
                    border: InputBorder.none,
                    hintText: "Digite o nome do setor...",
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                  ),
                  style: TextStyle(color: Colors.blue.shade900),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.blue.shade400],
                  ),
                ),
                child: IconButton(
                  icon: Icon(Icons.add, color: Colors.white),
                  onPressed: _addSetor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSetoresList() {
    return Expanded(
      child: uid == null
          ? _buildErrorWidget("Usuário não autenticado")
          : StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('formInfoMunicipio')
                  .doc(uid)
                  .collection('setores')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoading();
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                final setores = snapshot.data!.docs;
                return ListView.builder(
                  padding: EdgeInsets.only(bottom: 20),
                  itemCount: setores.length,
                  itemBuilder: (context, index) {
                    var setor = setores[index];
                    return _buildSetorCard(setor);
                  },
                );
              },
            ),
    );
  }

  Widget _buildSetorCard(QueryDocumentSnapshot setor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          leading: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.people_alt_outlined, color: Colors.blue.shade800),
          ),
          title: Text(setor['nome'],
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade900)),
          subtitle: Text("Toque para editar",
              style: TextStyle(color: Colors.grey.shade600)),
          trailing: IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
            onPressed: () => _deleteSetor(setor.id),
          ),
          onTap: () => _navigateToForm(context, setor.id),
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() => Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade800),
        ),
      );

  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.blue.shade200),
            SizedBox(height: 20),
            Text("Nenhum setor cadastrado",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue.shade400,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );

  Widget _buildErrorWidget(String message) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red.shade400),
            SizedBox(height: 20),
            Text(message,
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );
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

  List<String> bairrosList = [];
  List<String> localidadesRuraisList = [];

  // Controladores
  late TextEditingController _localController;
  late TextEditingController _capacidadeController;
  late TextEditingController _distanciaController;

  final TextEditingController _bairroInputController = TextEditingController();
  final TextEditingController _localidadeInputController =
      TextEditingController();

  late TextEditingController _outraFonteUrbanaController;
  late TextEditingController _outraFonteRuralController;
  late TextEditingController _outroResponsavelUrbanoController;
  late TextEditingController _outroResponsavelRuralController;
  late TextEditingController _outroResponsavelEsgotoController;
  late TextEditingController _outroResponsavelEsgotoRuralController;
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

  String? _coletaEsgotoRural;
  String? _tratamentoEsgotoRural;
  String? _responsavelEsgotoRural;
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

    _outraFonteUrbanaController = TextEditingController();
    _outraFonteRuralController = TextEditingController();
    _outroResponsavelUrbanoController = TextEditingController();
    _outroResponsavelRuralController = TextEditingController();
    _outroResponsavelEsgotoController = TextEditingController();
    _responsavelResiduosUrbanoController = TextEditingController();
    _responsavelResiduosRuralController = TextEditingController();
    _justificativaUrbanaController = TextEditingController();
    _justificativaRuralController = TextEditingController();

    _outroResponsavelEsgotoRuralController = TextEditingController();
  }

  _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Row(
        children: [
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue.shade800),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
        ],
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
          dropdownColor: Colors.white,
          style: TextStyle(color: Colors.blue.shade900),
          value: value,
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.blue.shade200),
            ),
            filled: true,
            fillColor: Colors.white,
            isDense: true,
          ),
          validator: (value) => value == null ? 'Selecione uma opção' : null,
        ),
      ],
    );
  }

  TextEditingController _getControllerForOtherField(String question) {
    String q = question.toLowerCase();
    if (q.contains("responsável")) {
      if (q.contains("urbano")) return _outroResponsavelUrbanoController;
      if (q.contains("rural")) return _outroResponsavelRuralController;
      if (q.contains("esgoto")) return _outroResponsavelEsgotoController;
    }
    if (q.contains("fonte")) {
      if (q.contains("urbana")) return _outraFonteUrbanaController;
      if (q.contains("rural")) return _outraFonteRuralController;
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
              activeColor: Colors.blue.shade800,
              checkColor: Colors.white,
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
            decoration: InputDecoration(
              labelText: "Especifique:",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.blue.shade200),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) => selected.contains("Outro") && value!.isEmpty
                ? "Campo obrigatório"
                : null,
          ),
        if (selected.length > 1)
          TextFormField(
            controller: justificationController,
            decoration: InputDecoration(
              labelText: "Justifique a seleção múltipla:",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.blue.shade200),
              ),
              filled: true,
              fillColor: Colors.white,
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
            decoration: InputDecoration(
              labelText: "Especifique:",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.blue.shade200),
              ),
              filled: true,
              fillColor: Colors.white,
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

          _coletaEsgotoRural = data['coleta_esgoto_rural'];
          _tratamentoEsgotoRural = data['tratamento_esgoto_rural'];
          _responsavelEsgotoRural = data['responsavel_esgoto_rural'];
          _outroResponsavelEsgotoRuralController.text =
              data['outro_responsavel_esgoto_rural'] ?? '';

          _coletaResiduosUrbana = data['coleta_residuos_urbana'];
          _coletaResiduosRural = data['coleta_residuos_rural'];
          bairrosList = List<String>.from(data['bairros'] ?? []);
          localidadesRuraisList =
              List<String>.from(data['localidades_rurais'] ?? []);
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
        'coleta_esgoto_rural': _coletaEsgotoRural,
        'tratamento_esgoto_rural': _tratamentoEsgotoRural,
        'responsavel_esgoto_rural': _responsavelEsgotoRural,
        'outro_responsavel_esgoto_rural':
            _outroResponsavelEsgotoRuralController.text,
        'coleta_residuos_urbana': _coletaResiduosUrbana,
        'coleta_residuos_rural': _coletaResiduosRural,
        'bairros': bairrosList,
        'localidades_rurais': localidadesRuraisList,
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
                              'Questionário',
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              'Completo',
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
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue.shade50, Colors.white],
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("Informações Básicas"),
                      _buildQuestion(
                          "Indique um local para realização de eventos nesse Setor de Mobilização. "),
                      TextFormField(
                        controller: _localController,
                        decoration: InputDecoration(
                          hintText:
                              "Ex: Escola, Auditório, Câmara, Teatro, etc.)",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.blue.shade200),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "Campo obrigatório" : null,
                      ),
                      const SizedBox(height: 20),
                      _buildQuestion(
                          "O local indicado possui capacidade para comportar quantas pessoas?"),
                      TextFormField(
                        controller: _capacidadeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          suffixText: "pessoas",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.blue.shade200),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "Campo obrigatório" : null,
                      ),
                      const SizedBox(height: 20),
                      _buildQuestion(
                          "Qual a distância do local indicado para a Sede do Município?"),
                      TextFormField(
                        controller: _distanciaController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          suffixText: "quilômetros",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.blue.shade200),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "Campo obrigatório" : null,
                      ),
                      _buildSectionTitle("Infraestrutura"),
                      _buildDropdown(
                        "O local indicado dispõe de energia elétrica?",
                        _energiaEletrica,
                        ["Sim", "Não"],
                        (value) => setState(() => _energiaEletrica = value),
                      ),
                      _buildDropdown(
                        "O local indicado dispõe de banheiros?",
                        _banheiros,
                        ["Sim", "Não"],
                        (value) => setState(() => _banheiros = value),
                      ),
                      _buildDropdown(
                        "O local indicado dispõe de água potável?",
                        _aguaPotavel,
                        ["Sim", "Não"],
                        (value) => setState(() => _aguaPotavel = value),
                      ),
                      _buildSectionTitle("Características do Setor"),
                      _buildDropdown(
                        "Esse setor possui:",
                        _areaSetor,
                        ["Área urbana", "Área rural", "Área urbana e rural"],
                        (value) => setState(() => _areaSetor = value),
                      ),
                      if (_areaSetor != null && _areaSetor!.contains("urbana"))
                        _buildMultiItemField(
                          label: "Bairros existentes:",
                          items: bairrosList,
                          inputController: _bairroInputController,
                          hintText: "Digite um bairro e clique +",
                          isRequired: true,
                        ),
                      SizedBox(height: 15),
                      if (_areaSetor != null && _areaSetor!.contains("rural"))
                        _buildMultiItemField(
                          label: "Localidades rurais existentes:",
                          items: localidadesRuraisList,
                          inputController: _localidadeInputController,
                          hintText: "Digite uma localidade e clique +",
                          isRequired: true,
                        ),
                      SizedBox(height: 15),
                      _buildSectionTitle("Abastecimento de Água"),
                      if (_areaSetor != null && _areaSetor!.contains("urbana"))
                        _buildMultiSelect(
                          question:
                              "Quais são as fontes de abastecimento de água existentes na área urbana?",
                          selected: _fontesAbastecimentoUrbana,
                          options: [
                            "Rio",
                            "Riacho",
                            "Cisterna/Água da Chuva",
                            "Cisterna/Pipa",
                            "Poço comunitário",
                            "Poço próprio",
                            "Outro"
                          ],
                          onChanged: (value) => setState(
                              () => _fontesAbastecimentoUrbana = value),
                        ),
                      if (_areaSetor != null && _areaSetor!.contains("rural"))
                        _buildMultiSelect(
                          question:
                              "Quais são as fontes de abastecimento de água existentes na área rural?",
                          selected: _fontesAbastecimentoRural,
                          options: [
                            "Rio",
                            "Riacho",
                            "Cisterna/Água da Chuva",
                            "Cisterna/Pipa",
                            "Poço comunitário",
                            "Poço próprio",
                            "Outro"
                          ],
                          onChanged: (value) =>
                              setState(() => _fontesAbastecimentoRural = value),
                        ),
                      _buildSectionTitle("Responsáveis pelo Abastecimento"),
                      if (_areaSetor != null && _areaSetor!.contains("urbana"))
                        _buildMultiSelectWithJustification(
                          question:
                              "Quem é o responsável pelo abastecimento de água na área urbana?",
                          selected: _responsaveisAguaUrbana,
                          options: [
                            "Prefeitura (secretaria)",
                            "SAAE",
                            "Exército",
                            "Outro"
                          ],
                          onChanged: (value) =>
                              setState(() => _responsaveisAguaUrbana = value),
                          justificationController:
                              _justificativaUrbanaController,
                        ),
                      if (_areaSetor != null && _areaSetor!.contains("rural"))
                        _buildMultiSelectWithJustification(
                          question:
                              "Quem é o responsável pelo abastecimento de água na área rural?",
                          selected: _responsaveisAguaRural,
                          options: [
                            "Prefeitura (secretaria)",
                            "SAAE",
                            "Exército",
                            "Outro"
                          ],
                          onChanged: (value) =>
                              setState(() => _responsaveisAguaRural = value),
                          justificationController:
                              _justificativaRuralController,
                        ),
                      if (_areaSetor != null &&
                          _areaSetor!.contains("urbana")) ...[
                        _buildSectionTitle("Gestão de Esgoto (Urbano)"),
                        _buildDropdown(
                          "Há coleta de esgoto doméstico na área urbana?",
                          _coletaEsgotoUrbana,
                          ["Sim", "Não"],
                          (value) =>
                              setState(() => _coletaEsgotoUrbana = value),
                        ),
                        if (_coletaEsgotoUrbana == "Sim") ...[
                          _buildDropdown(
                            "O esgoto doméstico coletado na área urbana passa por algum tipo de tratamento?",
                            _tratamentoEsgoto,
                            ["Sim", "Não"],
                            (value) =>
                                setState(() => _tratamentoEsgoto = value),
                          ),
                          if (_tratamentoEsgoto == "Sim") ...[
                            _buildDropdown(
                              "Quem é o responsável pelos sistemas de esgotos domésticos?",
                              _responsavelEsgoto,
                              ["Morador", "Prefeitura", "Outro"],
                              (value) =>
                                  setState(() => _responsavelEsgoto = value),
                            ),
                            const SizedBox(height: 10),
                            if (_responsavelEsgoto == "Outro")
                              TextFormField(
                                controller: _outroResponsavelEsgotoController,
                                decoration: InputDecoration(
                                  labelText: "Especificar responsável:",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: Colors.blue.shade200),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                validator: (value) =>
                                    (_responsavelEsgoto == "Outro" &&
                                            value!.isEmpty)
                                        ? "Campo obrigatório"
                                        : null,
                              ),
                          ],
                        ],
                      ],
                      if (_areaSetor != null &&
                          _areaSetor!.contains("rural")) ...[
                        _buildSectionTitle("Gestão de Esgoto (Rural)"),
                        _buildDropdown(
                          "Há coleta de esgoto doméstico na área rural?",
                          _coletaEsgotoRural,
                          ["Sim", "Não"],
                          (value) => setState(() => _coletaEsgotoRural = value),
                        ),
                        if (_coletaEsgotoRural == "Sim") ...[
                          _buildDropdown(
                            "O esgoto doméstico coletado na área rural passa por algum tipo de tratamento?",
                            _tratamentoEsgotoRural,
                            ["Sim", "Não"],
                            (value) =>
                                setState(() => _tratamentoEsgotoRural = value),
                          ),
                          if (_tratamentoEsgotoRural == "Sim") ...[
                            _buildDropdown(
                              "Quem é o responsável pelos sistemas de esgotos domésticos?",
                              _responsavelEsgotoRural,
                              ["Morador", "Prefeitura", "Outro"],
                              (value) => setState(
                                  () => _responsavelEsgotoRural = value),
                            ),
                            const SizedBox(height: 10),
                            if (_responsavelEsgotoRural == "Outro")
                              TextFormField(
                                controller:
                                    _outroResponsavelEsgotoRuralController,
                                decoration: InputDecoration(
                                  labelText: "Especificar responsável:",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: Colors.blue.shade200),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                validator: (value) =>
                                    (_responsavelEsgotoRural == "Outro" &&
                                            value!.isEmpty)
                                        ? "Campo obrigatório"
                                        : null,
                              ),
                          ],
                        ],
                      ],
                      _buildSectionTitle("Gestão de Resíduos"),
                      if (_areaSetor != null &&
                          _areaSetor!.contains("urbana")) ...[
                        _buildDropdown(
                          "Há coleta de resíduos sólidos na área urbana?",
                          _coletaResiduosUrbana,
                          ["Sim", "Não"],
                          (value) =>
                              setState(() => _coletaResiduosUrbana = value),
                        ),
                        if (_coletaResiduosUrbana == "Sim")
                          TextFormField(
                            controller: _responsavelResiduosUrbanoController,
                            decoration: InputDecoration(
                              labelText:
                                  "Quem é o responsável pela coleta de resíduos sólidos?",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Colors.blue.shade200),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) =>
                                (_coletaResiduosUrbana == "Sim" &&
                                        value!.isEmpty)
                                    ? "Campo obrigatório"
                                    : null,
                          ),
                      ],
                      if (_areaSetor != null &&
                          _areaSetor!.contains("rural")) ...[
                        _buildDropdown(
                          "Há coleta de resíduos sólidos na área rural?",
                          _coletaResiduosRural,
                          ["Sim", "Não"],
                          (value) =>
                              setState(() => _coletaResiduosRural = value),
                        ),
                        if (_coletaResiduosRural == "Sim")
                          TextFormField(
                            controller: _responsavelResiduosRuralController,
                            decoration: InputDecoration(
                              labelText:
                                  "Quem é o responsável pela coleta de resíduos sólidos?",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Colors.blue.shade200),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) =>
                                (_coletaResiduosRural == "Sim" &&
                                        value!.isEmpty)
                                    ? "Campo obrigatório"
                                    : null,
                          ),
                      ],
                      const SizedBox(height: 30),
                      Center(
                        child: ElevatedButton(
                          onPressed: _saveSetor,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade800,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
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
            ),
    );
  }

  @override
  void dispose() {
    _localController.dispose();
    _capacidadeController.dispose();
    _distanciaController.dispose();
    _bairroInputController.dispose();
    _localidadeInputController.dispose();
    _outraFonteUrbanaController.dispose();
    _outraFonteRuralController.dispose();
    _outroResponsavelUrbanoController.dispose();
    _outroResponsavelRuralController.dispose();
    _outroResponsavelEsgotoController.dispose();
    _outroResponsavelEsgotoRuralController.dispose();
    _responsavelResiduosUrbanoController.dispose();
    _responsavelResiduosRuralController.dispose();
    _justificativaUrbanaController.dispose();
    _justificativaRuralController.dispose();
    super.dispose();
  }

  Widget _buildMultiItemField({
    required String label,
    required List<String> items,
    required TextEditingController inputController,
    required String hintText,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuestion(label),
        // Exibe os itens adicionados (como chips, com opção de remoção)
        Wrap(
          spacing: 8,
          children: items
              .map(
                (item) => Chip(
                  backgroundColor: Colors.blue.shade50,
                  deleteIconColor: Colors.blue.shade800,
                  labelStyle: TextStyle(color: Colors.blue.shade900),
                  label: Text(item),
                  onDeleted: () {
                    setState(() {
                      items.remove(item);
                    });
                  },
                ),
              )
              .toList(),
        ),
        SizedBox(height: 16),
        // Campo de entrada com botão "+"
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: inputController,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                if (inputController.text.trim().isNotEmpty) {
                  setState(() {
                    items.add(inputController.text.trim());
                    inputController.clear();
                  });
                }
              },
            ),
          ],
        ),

        if (isRequired && items.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "Campo obrigatório",
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }
}
