import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class SetorDetailScreen extends StatefulWidget {
  final String userId;
  final String setorId;

  const SetorDetailScreen(
      {required this.userId, required this.setorId, Key? key})
      : super(key: key);

  @override
  _SetorDetailScreenState createState() => _SetorDetailScreenState();
}

class _SetorDetailScreenState extends State<SetorDetailScreen> {
  Future<DocumentSnapshot>? _setorFuture;

  @override
  void initState() {
    super.initState();
    _setorFuture = FirebaseFirestore.instance
        .collection('formInfoMunicipio')
        .doc(widget.userId)
        .collection('setores')
        .doc(widget.setorId)
        .get();
  }

  String? _formattedResponse(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      return value.trim().isEmpty ? null : value.trim();
    }
    return value.toString();
  }

  String? _listToFormattedString(dynamic list) {
    if (list == null || !(list is List) || list.isEmpty) return null;
    String s = (list as List).map((e) => e.toString()).join(", ");
    return s.trim().isEmpty ? null : s;
  }

  Widget _buildDetailItem(String question, dynamic answer, IconData icon) {
    final formatted = _formattedResponse(answer);
    if (formatted == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue[700]),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[800],
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: "$question: ",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: formatted),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItemFromList(
      String question, dynamic list, IconData icon) {
    final formatted = _listToFormattedString(list);
    if (formatted == null) return const SizedBox.shrink();
    return _buildDetailItem(question, formatted, icon);
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.blue[900],
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
                        'Detalhes do setor',
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
      body: FutureBuilder<DocumentSnapshot>(
        future: _setorFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
            ));
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 50, color: Colors.red[700]),
                  const SizedBox(height: 16),
                  Text("Erro ao carregar dados",
                      style: GoogleFonts.poppins(
                          color: Colors.red[700], fontSize: 18)),
                ],
              ),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 50, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  Text("Setor não encontrado",
                      style: GoogleFonts.poppins(
                          color: Colors.grey[600], fontSize: 18)),
                ],
              ),
            );
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Informações Básicas"),
                    _buildDetailItem(
                        "Nome do Setor", data["nome"], Icons.place),
                    _buildDetailItem("Local", data["local"], Icons.location_on),
                    _buildDetailItem(
                        "Capacidade",
                        data["capacidade"] != null
                            ? "${data['capacidade']} pessoas"
                            : null,
                        Icons.people),
                    _buildDetailItem(
                        "Distância",
                        data["distancia"] != null
                            ? "${data['distancia']} km"
                            : null,
                        Icons.directions),
                    _buildSectionTitle("Infraestrutura"),
                    _buildDetailItem("Área predominante", data["area_setor"],
                        Icons.landscape),
                    _buildDetailItem("Energia Elétrica",
                        data["energia_eletrica"], Icons.power),
                    _buildDetailItem("Banheiros", data["banheiros"], Icons.wc),
                    _buildDetailItem(
                        "Água Potável", data["agua_potavel"], Icons.water_drop),
                    _buildSectionTitle("Localização"),
                    _buildDetailItemFromList(
                        "Bairros", data["bairros"], Icons.location_city),
                    _buildDetailItemFromList("Localidades Rurais",
                        data["localidades_rurais"], Icons.nature_people),
                    _buildSectionTitle("Recursos Hídricos"),
                    _buildDetailItemFromList("Fontes na área urbana",
                        data["fontes_agua_urbana"], Icons.water),
                    _buildDetailItemFromList("Fontes na área rural",
                        data["fontes_agua_rural"], Icons.water),
                    _buildDetailItemFromList("Responsáveis urbanos",
                        data["responsaveis_agua_urbana"], Icons.engineering),
                    _buildDetailItem("Justificativa responsáveis urbanos",
                        data["justificativa_urbana"], Icons.description),
                    _buildDetailItemFromList("Responsáveis rurais",
                        data["responsaveis_agua_rural"], Icons.engineering),
                    _buildDetailItem("Justificativa responsáveis rurais",
                        data["justificativa_rural"], Icons.description),
                    _buildSectionTitle("Gestão de Resíduos"),
                    _buildDetailItem("Coleta de esgoto urbano",
                        data["coleta_esgoto_urbana"], Icons.delete),
                    if (data["coleta_esgoto_urbana"] == "Sim") ...[
                      _buildDetailItem("Tratamento de esgoto",
                          data["tratamento_esgoto"], Icons.recycling),
                      _buildDetailItem("Responsável pelo tratamento",
                          data["responsavel_esgoto"], Icons.assignment_ind),
                      if (data["responsavel_esgoto"] == "Outro")
                        _buildDetailItem("Outro responsável pelo tratamento",
                            data["outro_responsavel_esgoto"], Icons.person),
                    ],
                    _buildDetailItem("Coleta de resíduos urbanos",
                        data["coleta_residuos_urbana"], Icons.delete_forever),
                    if (data["coleta_residuos_urbana"] == "Sim")
                      _buildDetailItem(
                          "Responsável resíduos urbanos",
                          data["responsavel_residuos_urbano"],
                          Icons.assignment_turned_in),
                    _buildDetailItem("Coleta de resíduos rurais",
                        data["coleta_residuos_rural"], Icons.delete_forever),
                    if (data["coleta_residuos_rural"] == "Sim")
                      _buildDetailItem(
                          "Responsável resíduos rurais",
                          data["responsavel_residuos_rural"],
                          Icons.assignment_turned_in),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ListaSetoresScreen extends StatefulWidget {
  final String userId;

  const ListaSetoresScreen({required this.userId, Key? key}) : super(key: key);

  @override
  _ListaSetoresScreenState createState() => _ListaSetoresScreenState();
}

class _ListaSetoresScreenState extends State<ListaSetoresScreen> {
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
                        'Setores',
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('formInfoMunicipio')
              .doc(widget.userId)
              .collection('setores')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.list_alt, size: 60, color: Colors.grey[500]),
                    const SizedBox(height: 20),
                    Text("Nenhum setor cadastrado",
                        style: GoogleFonts.poppins(
                            color: Colors.grey[600], fontSize: 18)),
                  ],
                ),
              );
            }
            final setores = snapshot.data!.docs;
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: setores.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final setor = setores[index];
                final setorData = setor.data() as Map<String, dynamic>;
                return Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.blue[50]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.map, color: Colors.blue[800]),
                      ),
                      title: Text(
                        setorData['nome'] ?? "Sem nome",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.blue[900]),
                      ),
                      subtitle: Text(
                        "Última atualização: ${DateTime.now().toString().substring(0, 10)}",
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.grey[600]),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios_rounded,
                          size: 18, color: Colors.blue[800]),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SetorDetailScreen(
                              userId: widget.userId,
                              setorId: setor.id,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
