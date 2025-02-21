import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class VisualizacaoOrganizacaoMunicipioScreen extends StatefulWidget {
  final String userId;

  const VisualizacaoOrganizacaoMunicipioScreen({required this.userId});

  @override
  _VisualizacaoOrganizacaoMunicipioScreenState createState() =>
      _VisualizacaoOrganizacaoMunicipioScreenState();
}

class _VisualizacaoOrganizacaoMunicipioScreenState
    extends State<VisualizacaoOrganizacaoMunicipioScreen> {
  Future<Map<String, dynamic>>? _futureData;

  @override
  void initState() {
    super.initState();
    _futureData = _loadData();
  }

  Future<Map<String, dynamic>> _loadData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection("organizacaoMunicipio")
        .doc(widget.userId)
        .get();
    return doc.exists ? doc.data() as Map<String, dynamic> : {};
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
            decoration: const BoxDecoration(color: Colors.white),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                  // Textos: título e nome do usuário
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Organização Social',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.userId)
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              snapshot.hasData) {
                            final userData =
                                snapshot.data!.data() as Map<String, dynamic>;
                            final name = userData["name"] ?? "Usuário";
                            return Text(
                              name,
                              style: GoogleFonts.roboto(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade800,
                              ),
                            );
                          } else {
                            return Text(
                              'Carregando...',
                              style: GoogleFonts.roboto(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade800,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }
          return _buildContent(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(strokeWidth: 2),
          const SizedBox(height: 16),
          Text("Carregando informações...",
              style: GoogleFonts.poppins(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red[400], size: 48),
            const SizedBox(height: 16),
            Text("Erro ao carregar dados:",
                style: GoogleFonts.poppins(fontSize: 16)),
            Text(error,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade800, size: 48),
          const SizedBox(height: 16),
          Text("Nenhuma informação disponível",
              style:
                  GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> data) {
    // 'dados' é esperado ser uma lista de objetos com "conselho" e "leiDecreto"
    List<dynamic> registros = data["dados"] ?? [];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Conselhos Municipais",
              style: GoogleFonts.roboto(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade800)),
          const SizedBox(height: 16),
          registros.isEmpty
              ? _buildEmptyItem("Nenhuma informação cadastrada.")
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: registros.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final registro = registros[index];
                    final conselho =
                        registro["conselho"]?.toString() ?? "Não informado";
                    final leiDecreto =
                        registro["leiDecreto"]?.toString() ?? "Não informado";
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Conselho:",
                                style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700])),
                            const SizedBox(height: 4),
                            Text(conselho,
                                style: GoogleFonts.roboto(
                                    fontSize: 16, color: Colors.grey[800])),
                            const SizedBox(height: 12),
                            Text("Lei/Decreto:",
                                style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700])),
                            const SizedBox(height: 4),
                            Text(leiDecreto,
                                style: GoogleFonts.roboto(
                                    fontSize: 16, color: Colors.grey[800])),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyItem(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(text,
            style: GoogleFonts.poppins(
                fontSize: 15, color: Colors.grey[500], height: 1.4)),
      ),
    );
  }
}
