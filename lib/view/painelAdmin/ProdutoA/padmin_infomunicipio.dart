import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class InformacoesMunicipioScreen extends StatefulWidget {
  final String userId;

  const InformacoesMunicipioScreen({required this.userId});

  @override
  _InformacoesMunicipioScreenState createState() =>
      _InformacoesMunicipioScreenState();
}

class _InformacoesMunicipioScreenState
    extends State<InformacoesMunicipioScreen> {
  final Color _primaryColor = const Color(0xFF1A237E);
  final Color _accentColor = const Color(0xFF00BFA5);
  final double _cardRadius = 12.0;

  Future<Map<String, dynamic>>? _futureData;

  @override
  void initState() {
    super.initState();
    _futureData = _loadMunicipioData();
  }

  Future<Map<String, dynamic>> _loadMunicipioData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection("formInfoMunicipio")
        .doc(widget.userId)
        .get();
    return doc.exists ? doc.data() as Map<String, dynamic> : {};
  }

  Future<DocumentSnapshot> _fetchUser() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();
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
                        'Informações Municipio',
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
          Icon(Icons.info_outline, color: _accentColor, size: 48),
          const SizedBox(height: 16),
          Text("Nenhuma informação disponível",
              style:
                  GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSection(
            icon: Icons.location_on,
            title: "Vias de Acesso ao Município",
            content: _buildAccessRoutes(data["accessRoutes"]),
          ),
          _buildSection(
            icon: Icons.article,
            title: "Lei Orgânica do Município",
            content: _buildLawSection(data),
          ),
          _buildSection(
            icon: Icons.campaign,
            title: "Mobilização Popular e Comunicação",
            content: _buildMobilizacao(data),
          ),
          _buildSection(
            icon: Icons.water_drop,
            title: "Saneamento Básico",
            content: _buildSaneamento(data),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      {required IconData icon,
      required String title,
      required Widget content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: _primaryColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _primaryColor,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(_cardRadius),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_cardRadius),
              ),
              child: content,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessRoutes(List<dynamic>? routes) {
    if (routes == null || routes.isEmpty) {
      return _buildEmptyItem("Nenhuma via de acesso informada");
    }
    return Column(
      children:
          routes.map((route) => _buildListTile(route.toString())).toList(),
    );
  }

  Widget _buildLawSection(Map<String, dynamic> data) {
    final number = data["leiOrganicaNumber"] ?? "Não informado";
    final fileUrl = data["leiOrganicaFileUrl"];
    final fileName = data["leiOrganicaFileName"] ?? "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoItem("Número da Lei", number),
        const Divider(height: 24),
        if (fileUrl != null)
          _buildFileItem(fileName, fileUrl)
        else
          _buildEmptyItem("Nenhum arquivo anexado"),
      ],
    );
  }

  Widget _buildMobilizacao(Map<String, dynamic> data) {
    final comunicacao = data["comunicacao"] ?? {};
    final others = data["comunicacao_others"] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (comunicacao.isNotEmpty)
          ...comunicacao.entries.map((e) => _buildComunicacaoItem(e)),
        if (others.isNotEmpty) ...[
          const Divider(height: 24),
          Text("Canais Personalizados:",
              textAlign: TextAlign.left,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
          ...others.map((item) => _buildCustomChannel(item)),
        ],
        if (comunicacao.isEmpty && others.isEmpty)
          _buildEmptyItem("Nenhuma informação de mobilização"),
      ],
    );
  }

  Widget _buildSaneamento(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoItem(
          "Coleta seletiva de resíduos",
          data["coletaSeletiva"] ?? "Não informado",
        ),
        const Divider(height: 24),
        _buildInfoItem(
          "Sistema de drenagem de águas pluviais",
          data["drenagem"] ?? "Não informado",
        ),
      ],
    );
  }

  Widget _buildListTile(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.chevron_right, color: _accentColor, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: _contentTextStyle())),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _labelTextStyle()),
        const SizedBox(height: 4),
        Text(value, style: _contentTextStyle()),
      ],
    );
  }

  Widget _buildFileItem(String fileName, String fileUrl) {
    return InkWell(
      onTap: () async {
        if (await canLaunchUrlString(fileUrl)) {
          await launchUrlString(
            fileUrl,
            mode: LaunchMode.externalApplication,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Não foi possível abrir o arquivo")),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _accentColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.insert_drive_file, color: _accentColor),
            const SizedBox(width: 12),
            Expanded(child: Text(fileName, style: _contentTextStyle())),
            Icon(Icons.download, color: _accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildComunicacaoItem(MapEntry<String, dynamic> entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(entry.key, style: _labelTextStyle()),
        if (entry.value is List)
          ...entry.value.map<Widget>((v) => _buildListTile(v.toString())),
        // Se o valor for booleano (ativo), não exibe texto adicional
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildCustomChannel(dynamic item) {
    final channel = item["channel"] ?? "Canal desconhecido";
    final contact = item["contact"] ?? "Não informado";
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ", style: _contentTextStyle().copyWith(color: _accentColor)),
          Expanded(
            child: Text("$channel: $contact", style: _contentTextStyle()),
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
            style: _contentTextStyle().copyWith(color: Colors.grey[500])),
      ),
    );
  }

  TextStyle _labelTextStyle() {
    return GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: const Color.fromARGB(255, 51, 51, 51),
    );
  }

  TextStyle _contentTextStyle() {
    return GoogleFonts.poppins(
      fontSize: 15,
      color: Colors.grey[800],
      height: 1.4,
    );
  }
}
