import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

// 1. Configuração do Firestore Service

import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';

class FirestoreServiceComite {
  final FirebaseFirestore _firestoreComite = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid(); // Instância do UUID

  /// Gera um ID único usando UUID v4
  Future<String> generateFormId() async {
    return _uuid
        .v4(); // Exemplo de saída: "3fa85f64-5717-4562-b3fc-2c963f66afa6"
  }

  /// Cria um novo formulário no Firestore com um ID aleatório
  Future<void> createFormComite(Map<String, dynamic> formData) async {
    DateTime now = DateTime.now();
    formData['dataCriacao'] = "${now.day}/${now.month}/${now.year}";
    formData['horaCriacao'] =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

    await _firestoreComite
        .collection('formulariosComite')
        .doc(formData['idFormulario'])
        .set(formData);
  }

  /// Envia uma resposta para um formulário específico com data e hora separadas
  Future<void> submitResponseComite(Map<String, dynamic> responseData) async {
    DateTime now = DateTime.now();
    responseData['dataResposta'] = "${now.day}/${now.month}/${now.year}";
    responseData['horaResposta'] =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

    await _firestoreComite.collection('respostasComite').add(responseData);
  }
}

// 2. Tela de Criação de Formulárioimport 'package:flutter/material.dart';

class CriarFormularioScreenComite extends StatefulWidget {
  const CriarFormularioScreenComite({super.key});

  @override
  _CriarFormularioScreenComiteState createState() =>
      _CriarFormularioScreenComiteState();
}

class _CriarFormularioScreenComiteState
    extends State<CriarFormularioScreenComite> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreServiceComite _firestoreService = FirestoreServiceComite();

  final estados = ["Rio de Janeiro", "Pernambuco", "Bahia"];
  final municipios = {
    "Bahia": [
      "Araci",
      "Andaraí",
      "Barra do Choça",
      "Barra da Estiva",
      "Botuporã",
      "Brejões",
      "Caatiba",
      "Cachoeira",
      "Cafarnaum",
      "Canudos",
      "Cardeal da Silva",
      "Catu",
      "Cícero Dantas",
      "Cipó",
      "Entre Rios",
      "Coronel João Sá",
      "Ibipeba",
      "Ibirataia",
      "Iaçu",
      "Iguaí",
      "Itagi",
      "Muqúem de São Francisco",
      "Itagimirim",
      "Itanagra",
      "Nova Itarana",
      "Ituaçu",
      "Iuiu",
      "Rio Real",
      "Jaguaquara",
      "Maracás",
      "Mirangaba",
      "Muritiba",
      "Nordestina",
      "Potiraguá",
      "Quixabeira",
      "Ruy Barbosa",
      "Retirolândia",
      "São Domingos",
      "Sapeaçu",
      "Saúde",
      "Sebastião Laranjeiras",
      "Sento Sé",
      "Ubatã",
      "Várzea da Roça"
    ],
    "Pernambuco": [
      "Belém do São Francisco",
      "Agrestina",
      "Amaraji",
      "Betânia",
      "Barreiros",
      "Brejinho",
      "Cabrobó",
      "Calumbi",
      "Camocim de São Félix",
      "Carnaubeira da Penha",
      "Canhotinho",
      "Carnaíba",
      "Lajedo",
      "Cedro",
      "Cupira",
      "Petrolândia",
      "Custódia",
      "Ferreiros",
      "Quixaba",
      "Granito",
      "Ipubi",
      "São José do Belmonte",
      "Jaqueira",
      "Jataúba",
      "Serrita",
      "Joaquim Nabuco",
      "Laoa do Ouro",
      "Trindade",
      "Maraial",
      "Mirandiba",
      "Passira",
      "Santa Cruz",
      "Santa Cruz da Baixa Verde",
      "São Bento do Una",
      "São José do Egito",
      "Solidão",
      "Triunfo",
      "Verdejante"
    ],
    "Rio de Janeiro": [
      "Bom Jardim",
      "Cardoso Moreira",
      "Bom Jesus do Itabapoana",
      "Casimiro de Abreu",
      "Conceição de Macabu",
      "Duas Barras",
      "Engenheiro Paulo de Frontín",
      "Itaocara",
      "São Fidélis",
      "São Francisco de Itabapoana",
      "Trajano de Moraes"
    ]
  };

  String _estadoSelecionado = "Bahia";
  String? _municipioSelecionado;

  String _generateLink(String idFormulario) {
    return 'https://plansanear.com.br/redeplansanea/v10/#/comite/$idFormulario';
  }

  Future<void> _submitFormComite() async {
    if (_formKey.currentState!.validate() && _municipioSelecionado != null) {
      final user = _auth.currentUser!;
      final id = await _firestoreService.generateFormId();
      final link = _generateLink(id);

      await _firestoreService.createFormComite({
        'idFormulario': id,
        'autor': user.displayName ?? user.email!,
        'link': link,
        'municipio': _municipioSelecionado,
        'estado': _estadoSelecionado,
      });

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Formulário Criado!',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text('Link: $link'),
                    const SizedBox(height: 16),
                    QrImageView(
                      data: link,
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: link));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Link copiado para a área de transferência'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.content_copy),
                      label: const Text('Copiar Link'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Share.share(link, subject: 'Formulário Criado!');
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Compartilhar'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildDecoratedDropdownComite(String label, Widget child) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.8), fontSize: 12)),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 2,
            )
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          const Icon(Icons.assignment_add,
                              size: 50, color: Color(0xFF2575FC)),
                          const SizedBox(height: 10),
                          Text('Criar Novo Formulário',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                      color: const Color(0xFF2C3E50),
                                      fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.grey[600]),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDecoratedDropdownComite(
                        'Estado',
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: _estadoSelecionado,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: EdgeInsets.all(9),
                          ),
                          items: estados.map((String estado) {
                            return DropdownMenuItem<String>(
                              value: estado,
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/bandeiras/bandeira_${estado.toLowerCase().replaceAll(" ", "_")}.png',
                                    width: 40,
                                    height: 25,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 40,
                                        height: 25,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Icon(Icons.flag, size: 20),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 15),
                                  Text(estado,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF34495E))),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _estadoSelecionado = value!;
                              _municipioSelecionado = null;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildDecoratedDropdownComite(
                        'Município',
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: _municipioSelecionado,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: EdgeInsets.all(9),
                            hintText: 'Selecione um município',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          items:
                              municipios[_estadoSelecionado]!.map((municipio) {
                            return DropdownMenuItem(
                              value: municipio,
                              child: Text(municipio,
                                  style: const TextStyle(
                                      fontSize: 16, color: Color(0xFF34495E))),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _municipioSelecionado = value);
                          },
                          validator: (value) =>
                              value == null ? 'Selecione um município' : null,
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _submitFormComite();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2575FC),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.create, color: Colors.white),
                          label: const Text('GERAR FORMULÁRIO',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// ... (mantido igual o original)

// 3. Tela de Resposta do Formulário (Adicionada)
class ResponderFormularioScreenComite extends StatefulWidget {
  final String idFormulario;

  const ResponderFormularioScreenComite({
    super.key,
    required this.idFormulario,
  });

  @override
  _ResponderFormularioScreenComiteState createState() =>
      _ResponderFormularioScreenComiteState();
}

class _ResponderFormularioScreenComiteState
    extends State<ResponderFormularioScreenComite> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreServiceComite _firestoreService = FirestoreServiceComite();

  // Controladores para os campos de entrada
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _vinculoController = TextEditingController();

  String _telefoneCompleto = ''; // Para armazenar o telefone formatado

  final List<String> comites = ["Coordenação", "Executivo"];
  String? _comiteSelecionado;

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _vinculoController.dispose();
    super.dispose();
  }

  Future<void> _submitResponseComite() async {
    if (_formKey.currentState!.validate()) {
      await _firestoreService.submitResponseComite({
        'idFormulario': widget.idFormulario,
        'nomeCompleto': _nomeController.text,
        'telefone': _telefoneCompleto,
        'vinculo': _vinculoController.text,
        'comite': _comiteSelecionado,
      });

      GoRouter.of(context).go('/forms/respondido');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('formulariosComite') //carregar formulario do firebase
              .doc(widget.idFormulario)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white70),
                    ),
                  ),
                  SizedBox(width: 12),
                ],
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Row(
                children: [
                  Icon(Icons.error_outline, size: 20),
                  SizedBox(width: 8),
                  Text('Formulário não encontrado',
                      style: TextStyle(fontSize: 16)),
                ],
              );
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final municipio = data['municipio'] ?? 'Desconhecido';
            final estado = data['estado'] ?? 'Desconhecido';
            final dataCriacao = data['dataCriacao'] as String;

            return AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$municipio - $estado\n',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '📋 Lista de Presença 🗓️ $dataCriacao ',
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade700,
                const Color.fromARGB(255, 188, 213, 255)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            Center(
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(maxWidth: 800), // Largura máxima para web
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildFormHeader(isMobile),
                        SizedBox(height: isMobile ? 16 : 24),
                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                            child: Form(
                              key: _formKey,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return Wrap(
                                    spacing: 20,
                                    runSpacing: 20,
                                    children: [
                                      SizedBox(
                                        width: constraints.maxWidth > 500
                                            ? 500
                                            : constraints.maxWidth,
                                        child: Column(
                                          children: [
                                            _buildCustomTextField(
                                              controller: _nomeController,
                                              label: 'Nome Completo',
                                              icon: Icons.person_outline,
                                              isMobile: isMobile,
                                            ),
                                            SizedBox(
                                                height: isMobile ? 12 : 20),
                                            IntlPhoneField(
                                              controller: _telefoneController,
                                              decoration: InputDecoration(
                                                labelText: 'Telefone',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                fillColor: Colors.blue.shade50,
                                                filled: true,
                                              ),
                                              initialCountryCode:
                                                  'BR', // Define o Brasil como padrão (+55)
                                              onChanged: (phone) {
                                                setState(() {
                                                  _telefoneCompleto = phone
                                                      .completeNumber; // Captura o telefone formatado
                                                });
                                              },
                                              validator: (value) {
                                                if (value == null ||
                                                    value.number.isEmpty) {
                                                  return 'Informe um número de telefone válido';
                                                }
                                                return null;
                                              },
                                            ),
                                            SizedBox(
                                                height: isMobile ? 12 : 20),
                                            _buildCustomTextField(
                                              controller: _vinculoController,
                                              label:
                                                  'Vínculo (Órgão/Instituição/Setor/)',
                                              icon: Icons.link_outlined,
                                              isMobile: isMobile,
                                            ),
                                            SizedBox(
                                                height: isMobile ? 16 : 30),
                                            DropdownButtonFormField<String>(
                                              isExpanded: true,
                                              value: _comiteSelecionado,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                fillColor: Colors.blue.shade50,
                                                filled: true,
                                                contentPadding:
                                                    const EdgeInsets.all(9),
                                                hintText: 'Selecione um comitê',
                                              ),
                                              items:
                                                  comites.map((String comite) {
                                                return DropdownMenuItem<String>(
                                                  value: comite,
                                                  child: Text(comite,
                                                      style: const TextStyle(
                                                          fontSize: 16)),
                                                );
                                              }).toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  _comiteSelecionado = value;
                                                });
                                              },
                                              validator: (value) =>
                                                  value == null
                                                      ? 'Selecione um comitê'
                                                      : null,
                                            ),
                                            SizedBox(
                                                height: isMobile ? 16 : 30),
                                            AnimatedContainer(
                                              duration:
                                                  Duration(milliseconds: 300),
                                              width: constraints.maxWidth > 400
                                                  ? 400
                                                  : double.infinity,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.blue.shade600,
                                                    Colors.blueAccent.shade400,
                                                  ],
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.blue
                                                        .withOpacity(0.3),
                                                    blurRadius: 10,
                                                    offset: Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: ElevatedButton(
                                                onPressed:
                                                    _submitResponseComite,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  shadowColor:
                                                      Colors.transparent,
                                                  padding: EdgeInsets.symmetric(
                                                    vertical:
                                                        isMobile ? 14 : 16,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ),
                                                ),
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.send_to_mobile,
                                                        size:
                                                            isMobile ? 20 : 24,
                                                        color: Colors.white,
                                                      ),
                                                      SizedBox(
                                                          width: isMobile
                                                              ? 8
                                                              : 12),
                                                      Text(
                                                        'ENVIAR RESPOSTA',
                                                        style: TextStyle(
                                                          fontSize: isMobile
                                                              ? 14
                                                              : 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          letterSpacing: 1.2,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color.fromARGB(138, 255, 255, 255),
                          ),
                          child: Image.asset(
                            'assets/barradelogo.png',
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormHeader(bool isMobile) {
    return Column(
      children: [
        Icon(Icons.how_to_reg_rounded,
            size: isMobile ? 40 : 50, color: Colors.blue.shade800),
        SizedBox(height: isMobile ? 8 : 10),
        Text(
          'Registro de Participação',
          style: TextStyle(
            fontSize: isMobile ? 20 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade900,
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(height: isMobile ? 4 : 8),
        Text(
          'Preencha todos os campos abaixo para confirmar sua presença',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isMobile ? 12 : 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isMobile = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade600),
        floatingLabelStyle: TextStyle(
          color: Colors.blue.shade800,
          fontSize: isMobile ? 14 : 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.blue.shade600,
            width: isMobile ? 1.5 : 2,
          ),
        ),
        filled: true,
        fillColor: Colors.blue.shade50,
        contentPadding: EdgeInsets.symmetric(
          vertical: isMobile ? 14 : 18,
          horizontal: isMobile ? 12 : 16,
        ),
      ),
      style: TextStyle(fontSize: isMobile ? 14 : 16),
      validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
    );
  }
}
