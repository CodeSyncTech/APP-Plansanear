import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class VisualizacaoCaracterizacaoMunicipio extends StatefulWidget {
  final String userId; // UUID do usuário passado via parâmetro

  const VisualizacaoCaracterizacaoMunicipio({Key? key, required this.userId})
      : super(key: key);

  @override
  _VisualizacaoCaracterizacaoMunicipioState createState() =>
      _VisualizacaoCaracterizacaoMunicipioState();
}

class _VisualizacaoCaracterizacaoMunicipioState
    extends State<VisualizacaoCaracterizacaoMunicipio> {
  bool? _possuiPoliticaSaneamento;
  bool? _haConselhoSaneamento;
  bool? _possuiPlanoDiretor;

  // Variáveis para armazenar os dados dos arquivos
  String? _politicaSaneamentoFileName;
  String? _politicaSaneamentoFileURL;

  String? _planoDiretorFileName;
  String? _planoDiretorFileURL;

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
          .doc(widget.userId)
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Widget para exibir informação de resposta (Sim/Não) de forma somente leitura.
  Widget _buildReadOnlyYesNo(String label, bool? value) {
    String resposta;
    if (value == null) {
      resposta = "Não informado";
    } else {
      resposta = value ? "Sim" : "Não";
    }
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
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

  /// Widget para exibir seção de arquivo com botão para baixar se houver arquivo.
  Widget _buildDownloadSection({
    required String title,
    required String? fileName,
    required String? fileURL,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 8),
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
            fileName != null &&
                    fileName.isNotEmpty &&
                    fileURL != null &&
                    fileURL.isNotEmpty
                ? Row(
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: Colors.green[600], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          fileName,
                          style: TextStyle(
                            color: Colors.blueGrey[800],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _downloadFile(fileURL),
                        icon: const Icon(Icons.download_rounded, size: 20),
                        label: const Text(
                          "Baixar",
                          style: TextStyle(fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.blue[800],
                          backgroundColor: Colors.blue[50],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  )
                : Text("Nenhum arquivo anexado.",
                    style: TextStyle(color: Colors.blueGrey[400])),
          ],
        ),
      ),
    );
  }

  /// Função que utiliza o url_launcher para abrir o link do arquivo
  Future<void> _downloadFile(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Não foi possível abrir o arquivo.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Visualização - Produto B"),
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
            : Padding(
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
                      // Exibe se o município possui Política de Saneamento
                      _buildReadOnlyYesNo(
                        "O Município possui Política de Saneamento?",
                        _possuiPoliticaSaneamento,
                      ),
                      // Se possui, exibe o documento para download
                      if (_possuiPoliticaSaneamento == true)
                        _buildDownloadSection(
                          title: "Documento para Política de Saneamento:",
                          fileName: _politicaSaneamentoFileName,
                          fileURL: _politicaSaneamentoFileURL,
                        ),
                      // Exibe se há Conselho Municipal de Saneamento Básico
                      _buildReadOnlyYesNo(
                        "Há Conselho Municipal de Saneamento Básico?",
                        _haConselhoSaneamento,
                      ),
                      // Exibe se o município possui Plano Diretor
                      _buildReadOnlyYesNo(
                        "O Município possui Plano Diretor?",
                        _possuiPlanoDiretor,
                      ),
                      // Se possui, exibe o documento para download
                      if (_possuiPlanoDiretor == true)
                        _buildDownloadSection(
                          title: "Documento para Plano Diretor:",
                          fileName: _planoDiretorFileName,
                          fileURL: _planoDiretorFileURL,
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
