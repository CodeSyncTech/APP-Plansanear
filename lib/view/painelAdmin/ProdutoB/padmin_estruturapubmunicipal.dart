import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VisualizacaoEstruturapubMunicipal extends StatefulWidget {
  final String userId; // UUID do usuário passado por parâmetro

  const VisualizacaoEstruturapubMunicipal({Key? key, required this.userId})
      : super(key: key);

  @override
  _VisualizacaoEstruturapubMunicipalState createState() =>
      _VisualizacaoEstruturapubMunicipalState();
}

class _VisualizacaoEstruturapubMunicipalState
    extends State<VisualizacaoEstruturapubMunicipal> {
  String? _qtdVereadores;
  String? _leiMunicipal;
  List<Map<String, dynamic>> _programasSaneamento = [];
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
          .doc(widget.userId) // Usa o UUID passado via parâmetro
          .collection('caracterizacoes')
          .doc('caracterizacaoMunicipio')
          .get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          if (data.containsKey('estruturaPublicaMunicipal')) {
            final esp = data['estruturaPublicaMunicipal'];
            setState(() {
              _qtdVereadores = esp['qtdVereadores'] as String?;
              _leiMunicipal = esp['leiMunicipal'] as String?;
            });
          }
          if (data.containsKey('programasAcoesSaneamento')) {
            final List<dynamic> programas = data['programasAcoesSaneamento'];
            setState(() {
              _programasSaneamento = programas.map((item) {
                return {
                  "programa": item['programa'] ?? "",
                  "secretaria": item['secretaria'] ?? "",
                };
              }).toList();
            });
          }
        }
      }
    } catch (e) {
      print("Erro ao carregar dados na visualização: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildCamaraMunicipalCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Câmara Municipal",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900])),
            const SizedBox(height: 15),
            Text("Quantidade de vereadores:",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue[900])),
            const SizedBox(height: 8),
            Text(_qtdVereadores ?? "Não informado",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 15),
            Text("Lei Municipal:",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue[900])),
            const SizedBox(height: 8),
            Text(_leiMunicipal ?? "Não informado",
                style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramasMunicipaisCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Programas Municipais",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900])),
            const SizedBox(height: 15),
            _programasSaneamento.isEmpty
                ? Text("Nenhum programa adicionado",
                    style: TextStyle(color: Colors.blueGrey))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _programasSaneamento.length,
                    itemBuilder: (ctx, i) {
                      final item = _programasSaneamento[i];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 8),
                          title: Text(item['programa'] ?? "",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue[900])),
                          subtitle: Text("Secretaria: ${item['secretaria']}",
                              style: TextStyle(
                                  color: Colors.blueGrey, fontSize: 14)),
                        ),
                      );
                    },
                  )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text("Visualização - Estrutura e Saneamento",
            style: TextStyle(
                color: Colors.blue[900],
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade50, Colors.white],
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 2),
              )
            ],
          ),
        ),
        iconTheme: IconThemeData(color: Colors.blue[900]),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Container(
                height: double.infinity,
                width: double.infinity,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCamaraMunicipalCard(),
                      const SizedBox(height: 25),
                      _buildProgramasMunicipaisCard(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
