import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VisualizacaoPopulacoesTradicionais extends StatefulWidget {
  final String userId; // UUID do usuário passado via parâmetro

  const VisualizacaoPopulacoesTradicionais({Key? key, required this.userId})
      : super(key: key);

  @override
  _VisualizacaoPopulacoesTradicionaisState createState() =>
      _VisualizacaoPopulacoesTradicionaisState();
}

class _VisualizacaoPopulacoesTradicionaisState
    extends State<VisualizacaoPopulacoesTradicionais> {
  bool? _existePopulacoesTrad;
  List<Map<String, dynamic>> _populacoesTrad = [];
  bool? _possuiPoliticasTrad;
  String? _politicasEspecificasText;
  bool _isLoading = true;
  bool _hasData = false; // Define se há dados relevantes para exibir

  @override
  void initState() {
    super.initState();
    _loadDados();
  }

  Future<void> _loadDados() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('formInfoMunicipio')
          .doc(widget.userId)
          .collection('caracterizacoes')
          .doc('caracterizacaoMunicipio')
          .get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data.containsKey('populacoesTradicionais')) {
          final popTrad = data['populacoesTradicionais'];
          // Recupera os valores dos campos e define se há dados relevantes
          bool existe = popTrad['existe'] ?? false;
          List<dynamic> lista = popTrad['lista'] ?? [];
          bool possuiPoliticasTrad = popTrad['possuiPoliticasTrad'] ?? false;
          String politicasEspecificas = popTrad['politicasEspecificas'] ?? "";
          bool dataAvailable = (existe == true) ||
              (lista.isNotEmpty) ||
              (possuiPoliticasTrad == true) ||
              (politicasEspecificas.isNotEmpty);

          if (dataAvailable) {
            setState(() {
              _hasData = true;
              _existePopulacoesTrad = existe;
              _populacoesTrad = lista.map((item) {
                return {
                  "tipo": item['tipo'] ?? "",
                  "setor": item['setor'] ?? "",
                };
              }).toList();
              _possuiPoliticasTrad = possuiPoliticasTrad;
              _politicasEspecificasText = politicasEspecificas;
            });
          }
        }
      }
    } catch (e) {
      print("Erro ao carregar dados na Tela 4: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Widget que exibe a mensagem de estado vazio quando não há registros.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, color: Colors.blueAccent, size: 48),
          const SizedBox(height: 16),
          const Text(
            "Nenhuma informação disponível",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Exibe a resposta (Sim/Não) de forma somente leitura.
  Widget _buildReadOnlyYesNo(String label, bool? value) {
    String resposta;
    if (value == null) {
      resposta = "Não informado";
    } else {
      resposta = value ? "Sim" : "Não";
    }
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
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
            Text(
              resposta,
              style: TextStyle(
                fontSize: 16,
                color: value == true ? Colors.green[800] : Colors.red[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Exibe os registros de populações tradicionais cadastradas.
  Widget _buildPopulacoesTradCard() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Cadastro de Populações Tradicionais",
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue[800],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Ex.: Quilombolas, Indígenas, Ribeirinhos, etc.",
              style: TextStyle(
                color: Colors.blueGrey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            _populacoesTrad.isEmpty
                ? Text(
                    "Nenhuma população tradicional cadastrada.",
                    style: TextStyle(color: Colors.blueGrey),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _populacoesTrad.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = _populacoesTrad[index];
                      return Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          title: Text(
                            item['tipo'],
                            style: TextStyle(
                              color: Colors.blueGrey[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            "Setor: ${item['setor']}",
                            style: TextStyle(color: Colors.blueGrey[600]),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  /// Exibe as políticas específicas para povos tradicionais, se houver.
  Widget _buildPoliticasTradCard() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _possuiPoliticasTrad == true
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Políticas específicas para povos tradicionais:",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue[800],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _politicasEspecificasText != null &&
                            _politicasEspecificasText!.isNotEmpty
                        ? _politicasEspecificasText!
                        : "Não informado",
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              )
            : Text(
                "O Município não possui políticas específicas para povos tradicionais.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blueGrey[800],
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Visualização - Populações Tradicionais"),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        elevation: 5,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _hasData
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildReadOnlyYesNo(
                            "Existem populações tradicionais no Município?",
                            _existePopulacoesTrad,
                          ),
                          const SizedBox(height: 20),
                          _buildPopulacoesTradCard(),
                          const SizedBox(height: 20),
                          _buildReadOnlyYesNo(
                            "O Município possui políticas específicas para povos tradicionais?",
                            _possuiPoliticasTrad,
                          ),
                          if (_possuiPoliticasTrad == true) ...[
                            const SizedBox(height: 20),
                            _buildPoliticasTradCard(),
                          ],
                        ],
                      ),
                    ),
                  )
                : _buildEmptyState(),
      ),
    );
  }
}
