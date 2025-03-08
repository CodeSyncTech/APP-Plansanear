import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class VisualizacaoProgramaCampanha extends StatefulWidget {
  final String userId; // UUID do usuário que será usado para buscar os dados

  const VisualizacaoProgramaCampanha({Key? key, required this.userId})
      : super(key: key);

  @override
  _VisualizacaoProgramaCampanhaState createState() =>
      _VisualizacaoProgramaCampanhaState();
}

class _VisualizacaoProgramaCampanhaState
    extends State<VisualizacaoProgramaCampanha> {
  List<Map<String, dynamic>> _programasSaude = [];
  List<Map<String, dynamic>> _programasAssistencia = [];
  List<Map<String, dynamic>> _festejosFeriados = [];
  List<Map<String, dynamic>> _outrasAgendas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDados();
  }

  Future<void> _loadDados() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('formInfoMunicipio')
          .doc(widget.userId) // Utiliza o UUID passado via parâmetro
          .collection('caracterizacoes')
          .doc('caracterizacaoMunicipio')
          .get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          // Carrega programas de saúde
          if (data.containsKey('programasSaude')) {
            final List<dynamic> list = data['programasSaude'];
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
          }
          // Carrega programas de assistência social
          if (data.containsKey('programasAssistencia')) {
            final List<dynamic> list = data['programasAssistencia'];
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
          }
          // Carrega festejos e feriados
          if (data.containsKey('festejosFeriados')) {
            final List<dynamic> list = data['festejosFeriados'];
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
          }
          // Carrega outras agendas
          if (data.containsKey('outrasAgendas')) {
            final List<dynamic> list = data['outrasAgendas'];
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
          }
        }
      }
    } catch (e) {
      print("Erro ao carregar dados na Tela 2: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Widget para exibir cada lista de itens de forma somente leitura.
  Widget _buildReadOnlyList(String title, List<Map<String, dynamic>> list) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900])),
            const SizedBox(height: 10),
            list.isEmpty
                ? Text("Nenhum item cadastrado.",
                    style: TextStyle(color: Colors.blueGrey))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: list.length,
                    itemBuilder: (ctx, index) {
                      final item = list[index];
                      String dataInfo = "Sem data definida";
                      if (item['dataInicio'] != null &&
                          item['dataFim'] != null) {
                        final start =
                            DateFormat('dd/MM/yyyy').format(item['dataInicio']);
                        final end =
                            DateFormat('dd/MM/yyyy').format(item['dataFim']);
                        dataInfo =
                            start == end ? start : "Início: $start | Fim: $end";
                      }
                      return ListTile(
                        title: Text(item['nome'] ?? ""),
                        subtitle: Text(dataInfo),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Visualização - Saúde, Assistência e Eventos"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReadOnlyList(
                      "Programas, Campanhas e Ações na Política de Saúde:",
                      _programasSaude),
                  _buildReadOnlyList(
                      "Programas, Campanhas e Ações na Política de Assistência Social:",
                      _programasAssistencia),
                  _buildReadOnlyList(
                      "Datas Relevantes, Festejos e Feriados Municipais:",
                      _festejosFeriados),
                  _buildReadOnlyList(
                      "Outras Agendas (Reuniões e Eventos da Câmara):",
                      _outrasAgendas),
                ],
              ),
            ),
    );
  }
}
