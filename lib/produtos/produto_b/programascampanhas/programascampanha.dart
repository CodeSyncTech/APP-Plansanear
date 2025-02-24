import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class Tela2 extends StatefulWidget {
  const Tela2({Key? key}) : super(key: key);

  @override
  _Tela2State createState() => _Tela2State();
}

class _Tela2State extends State<Tela2> {
  List<Map<String, dynamic>> _programasSaude = [];
  final TextEditingController _nomeSaudeController = TextEditingController();

  List<Map<String, dynamic>> _programasAssistencia = [];
  final TextEditingController _nomeAssistenciaController =
      TextEditingController();

  List<Map<String, dynamic>> _festejosFeriados = [];
  final TextEditingController _nomeFestejoController = TextEditingController();

  List<Map<String, dynamic>> _outrasAgendas = [];
  final TextEditingController _nomeAgendaController = TextEditingController();

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
          // Carrega programas de saúde
          if (data.containsKey('programasSaude')) {
            final List<dynamic> list = data['programasSaude'];
            setState(() {
              _programasSaude = list.map((item) {
                DateTime? dataInicio;
                DateTime? dataFim;
                if (item['dataInicio'] != null) {
                  dataInicio = (item['dataInicio'] as Timestamp).toDate();
                }
                if (item['dataFim'] != null) {
                  dataFim = (item['dataFim'] as Timestamp).toDate();
                }
                return {
                  "nome": item['nome'] ?? "",
                  "dataInicio": dataInicio,
                  "dataFim": dataFim,
                };
              }).toList();
            });
          }
          // Carrega programas de assistência social
          if (data.containsKey('programasAssistencia')) {
            final List<dynamic> list = data['programasAssistencia'];
            setState(() {
              _programasAssistencia = list.map((item) {
                DateTime? dataInicio;
                DateTime? dataFim;
                if (item['dataInicio'] != null) {
                  dataInicio = (item['dataInicio'] as Timestamp).toDate();
                }
                if (item['dataFim'] != null) {
                  dataFim = (item['dataFim'] as Timestamp).toDate();
                }
                return {
                  "nome": item['nome'] ?? "",
                  "dataInicio": dataInicio,
                  "dataFim": dataFim,
                };
              }).toList();
            });
          }
          // Carrega festejos e feriados
          if (data.containsKey('festejosFeriados')) {
            final List<dynamic> list = data['festejosFeriados'];
            setState(() {
              _festejosFeriados = list.map((item) {
                DateTime? dataInicio;
                DateTime? dataFim;
                if (item['dataInicio'] != null) {
                  dataInicio = (item['dataInicio'] as Timestamp).toDate();
                }
                if (item['dataFim'] != null) {
                  dataFim = (item['dataFim'] as Timestamp).toDate();
                }
                return {
                  "nome": item['nome'] ?? "",
                  "dataInicio": dataInicio,
                  "dataFim": dataFim,
                };
              }).toList();
            });
          }
          // Carrega outras agendas
          if (data.containsKey('outrasAgendas')) {
            final List<dynamic> list = data['outrasAgendas'];
            setState(() {
              _outrasAgendas = list.map((item) {
                DateTime? dataInicio;
                DateTime? dataFim;
                if (item['dataInicio'] != null) {
                  dataInicio = (item['dataInicio'] as Timestamp).toDate();
                }
                if (item['dataFim'] != null) {
                  dataFim = (item['dataFim'] as Timestamp).toDate();
                }
                return {
                  "nome": item['nome'] ?? "",
                  "dataInicio": dataInicio,
                  "dataFim": dataFim,
                };
              }).toList();
            });
          }
        }
      }
    } catch (e) {
      print("Erro ao carregar dados na Tela 2: $e");
    }
  }

  Future<void> _pickDateOrRange({
    required int index,
    required List<Map<String, dynamic>> list,
  }) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Escolher Data ou Intervalo"),
        content: Text("Como deseja selecionar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, "unica"),
            child: Text("Data Única"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, "intervalo"),
            child: Text("Intervalo de Datas"),
          ),
        ],
      ),
    );
    if (choice == null) return;

    if (choice == "unica") {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        setState(() {
          list[index]['dataInicio'] = picked;
          list[index]['dataFim'] = picked;
        });
      }
    } else {
      final pickedRange = await showDateRangePicker(
        context: context,
        initialDateRange: DateTimeRange(
          start: DateTime.now(),
          end: DateTime.now().add(Duration(days: 1)),
        ),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (pickedRange != null) {
        setState(() {
          list[index]['dataInicio'] = pickedRange.start;
          list[index]['dataFim'] = pickedRange.end;
        });
      }
    }
  }

  void _addProgramaSaude() {
    final nome = _nomeSaudeController.text.trim();
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Informe o programa/ação de saúde.")),
      );
      return;
    }
    setState(() {
      _programasSaude.add({"nome": nome, "dataInicio": null, "dataFim": null});
      _nomeSaudeController.clear();
    });
  }

  void _removeProgramaSaude(int index) {
    setState(() {
      _programasSaude.removeAt(index);
    });
  }

  void _addProgramaAssistencia() {
    final nome = _nomeAssistenciaController.text.trim();
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Informe o programa/ação de assistência social.")),
      );
      return;
    }
    setState(() {
      _programasAssistencia
          .add({"nome": nome, "dataInicio": null, "dataFim": null});
      _nomeAssistenciaController.clear();
    });
  }

  void _removeProgramaAssistencia(int index) {
    setState(() {
      _programasAssistencia.removeAt(index);
    });
  }

  void _addFestejo() {
    final nome = _nomeFestejoController.text.trim();
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Informe o nome do festejo/evento.")),
      );
      return;
    }
    setState(() {
      _festejosFeriados
          .add({"nome": nome, "dataInicio": null, "dataFim": null});
      _nomeFestejoController.clear();
    });
  }

  void _removeFestejo(int index) {
    setState(() {
      _festejosFeriados.removeAt(index);
    });
  }

  void _addOutraAgenda() {
    final nome = _nomeAgendaController.text.trim();
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Informe o nome da agenda/evento.")),
      );
      return;
    }
    setState(() {
      _outrasAgendas.add({"nome": nome, "dataInicio": null, "dataFim": null});
      _nomeAgendaController.clear();
    });
  }

  void _removeOutraAgenda(int index) {
    setState(() {
      _outrasAgendas.removeAt(index);
    });
  }

  Widget _buildListWithDates({
    required List<Map<String, dynamic>> list,
    required Function(int) removeItem,
    required Function(int) pickDates,
  }) {
    if (list.isEmpty) return Text("Nenhum item adicionado.");
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (ctx, index) {
        final item = list[index];
        String dataInfo = "Sem data definida";
        if (item['dataInicio'] != null && item['dataFim'] != null) {
          final start = DateFormat('dd/MM/yyyy').format(item['dataInicio']);
          final end = DateFormat('dd/MM/yyyy').format(item['dataFim']);
          dataInfo = start == end ? start : "Início: $start | Fim: $end";
        }
        return ListTile(
          title: Text(item['nome'] ?? ""),
          subtitle: Text(dataInfo),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.calendar_today, color: Colors.green),
                onPressed: () => pickDates(index),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => removeItem(index),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _salvarDados() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Usuário não autenticado.")),
      );
      return;
    }
    try {
      final dataToSave = {
        "programasSaude": _programasSaude,
        "programasAssistencia": _programasAssistencia,
        "festejosFeriados": _festejosFeriados,
        "outrasAgendas": _outrasAgendas,
      };
      await FirebaseFirestore.instance
          .collection('formInfoMunicipio')
          .doc(uid)
          .collection('caracterizacoes')
          .doc('caracterizacaoMunicipio')
          .set(dataToSave, SetOptions(merge: true));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Dados da Tela 2 salvos com sucesso!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao salvar dados: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tela 2 – Saúde, Assistência e Eventos"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Programas e Ações na Saúde
            Text(
              "Programas, Campanhas e Ações na Política de Saúde:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nomeSaudeController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Programa/Ação (Saúde)",
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: Colors.blue),
                  onPressed: _addProgramaSaude,
                ),
              ],
            ),
            _buildListWithDates(
              list: _programasSaude,
              removeItem: _removeProgramaSaude,
              pickDates: (index) =>
                  _pickDateOrRange(index: index, list: _programasSaude),
            ),
            SizedBox(height: 20),
            // Programas e Ações na Assistência Social
            Text(
              "Programas, Campanhas e Ações na Política de Assistência Social:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nomeAssistenciaController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Programa/Ação (Assistência)",
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: Colors.blue),
                  onPressed: _addProgramaAssistencia,
                ),
              ],
            ),
            _buildListWithDates(
              list: _programasAssistencia,
              removeItem: _removeProgramaAssistencia,
              pickDates: (index) =>
                  _pickDateOrRange(index: index, list: _programasAssistencia),
            ),
            SizedBox(height: 20),
            // Festejos e Feriados
            Text(
              "Datas Relevantes, Festejos e Feriados Municipais:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nomeFestejoController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Festejo/Evento",
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: Colors.blue),
                  onPressed: _addFestejo,
                ),
              ],
            ),
            _buildListWithDates(
              list: _festejosFeriados,
              removeItem: _removeFestejo,
              pickDates: (index) =>
                  _pickDateOrRange(index: index, list: _festejosFeriados),
            ),
            SizedBox(height: 20),
            // Outras Agendas
            Text(
              "Outras Agendas (Reuniões e Eventos da Câmara):",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nomeAgendaController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Agenda/Evento",
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: Colors.blue),
                  onPressed: _addOutraAgenda,
                ),
              ],
            ),
            _buildListWithDates(
              list: _outrasAgendas,
              removeItem: _removeOutraAgenda,
              pickDates: (index) =>
                  _pickDateOrRange(index: index, list: _outrasAgendas),
            ),
            SizedBox(height: 20),
            // Botão de salvar
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
    _nomeSaudeController.dispose();
    _nomeAssistenciaController.dispose();
    _nomeFestejoController.dispose();
    _nomeAgendaController.dispose();
    super.dispose();
  }
}
