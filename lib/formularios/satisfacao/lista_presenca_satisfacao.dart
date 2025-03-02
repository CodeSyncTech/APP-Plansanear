import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Serviço para lidar com o Firestore (criação de formulários e envio de respostas)
class FirestoreServiceSatisfacao {
  final FirebaseFirestore _firestoreSatisfacao = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid(); // Instância do UUID

  /// Gera um ID único usando UUID v4
  Future<String> generateFormId() async {
    return _uuid.v4();
  }

  /// Cria um novo formulário no Firestore com um ID aleatório
  Future<void> createFormSatisfacao(Map<String, dynamic> formData) async {
    DateTime now = DateTime.now();
    formData['dataCriacao'] = "${now.day}/${now.month}/${now.year}";
    formData['horaCriacao'] =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

    await _firestoreSatisfacao
        .collection('formulariosSatisfacao')
        .doc(formData['idFormulario'])
        .set(formData);
  }

  /// Envia uma resposta para um formulário específico, incluindo data e hora
  Future<void> submitResponseSatisfacao(
      BuildContext context, Map<String, dynamic> responseData) async {
    DateTime now = DateTime.now();
    responseData['dataResposta'] = "${now.day}/${now.month}/${now.year}";
    responseData['horaResposta'] =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

    await _firestoreSatisfacao
        .collection('respostasSatisfacao')
        .add(responseData);
    GoRouter.of(context).go('/forms/respondido');
  }
}

/// Tela para criar um novo formulário de satisfação
class CriarFormularioScreenSatisfacao extends StatefulWidget {
  const CriarFormularioScreenSatisfacao({super.key});

  @override
  _CriarFormularioScreenSatisfacaoState createState() =>
      _CriarFormularioScreenSatisfacaoState();
}

class _CriarFormularioScreenSatisfacaoState
    extends State<CriarFormularioScreenSatisfacao> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreServiceSatisfacao _firestoreService =
      FirestoreServiceSatisfacao();

  // Lista de estados e municípios
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
      "Lagoa do Ouro",
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

  // Lista de tipos de evento
  final List<String> tiposEvento = ["Comitê", "Evento Público"];

  String _estadoSelecionado = "Bahia";
  String? _municipioSelecionado;
  String? _tipoEventoSelecionado;

  String _generateLink(String idFormulario) {
    return 'https://plansanear.com.br/redeplansanea/v10/#/pesquisasatisfacao/$idFormulario';
  }

  Future<void> _submitFormSatisfacao() async {
    // Verifica se o formulário é válido e se os campos obrigatórios foram selecionados
    if (_formKey.currentState!.validate() &&
        _municipioSelecionado != null &&
        _tipoEventoSelecionado != null) {
      final user = _auth.currentUser!;
      final id = await _firestoreService.generateFormId();
      final link = _generateLink(id);

      await _firestoreService.createFormSatisfacao({
        'idFormulario': id,
        'autor': user.displayName ?? user.email!,
        'link': link,
        'municipio': _municipioSelecionado,
        'estado': _estadoSelecionado,
        'tipoEvento': _tipoEventoSelecionado,
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

  Widget _buildDecoratedDropdownSatisfacao(String label, Widget child) {
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
                          Text('Criar Nova Pesquisa de Satisfação',
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
                      _buildDecoratedDropdownSatisfacao(
                        'Estado',
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: _estadoSelecionado,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.all(9),
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
                      _buildDecoratedDropdownSatisfacao(
                        'Município',
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: _municipioSelecionado,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.all(9),
                            hintText: 'Selecione um município',
                            hintStyle: const TextStyle(color: Colors.grey),
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
                      const SizedBox(height: 20),
                      _buildDecoratedDropdownSatisfacao(
                        'Tipo de Evento',
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: _tipoEventoSelecionado,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.all(9),
                            hintText: 'Selecione um tipo de evento',
                            hintStyle: const TextStyle(color: Colors.grey),
                          ),
                          items: tiposEvento.map((tipo) {
                            return DropdownMenuItem(
                              value: tipo,
                              child: Text(
                                tipo,
                                style: const TextStyle(
                                    fontSize: 16, color: Color(0xFF34495E)),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _tipoEventoSelecionado = value;
                            });
                          },
                          validator: (value) => value == null
                              ? 'Selecione um tipo de evento'
                              : null,
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _submitFormSatisfacao,
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

/// Tela de Resposta do Formulário de Satisfação
/// Agora, o id do formulário é passado para a tela para que os dados sejam carregados do Firestore.
class ResponderFormularioScreenSatisfacao extends StatefulWidget {
  final String idFormulario;

  const ResponderFormularioScreenSatisfacao({
    super.key,
    required this.idFormulario,
  });

  @override
  _ResponderFormularioScreenSatisfacaoState createState() =>
      _ResponderFormularioScreenSatisfacaoState();
}

class _ResponderFormularioScreenSatisfacaoState
    extends State<ResponderFormularioScreenSatisfacao> {
  final FirestoreServiceSatisfacao _firestoreService =
      FirestoreServiceSatisfacao();

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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo centralizado
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
                  // Título centralizado verticalmente
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pesquisa de',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        'Satisfação',
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
          ),
        ),
      ),
      // Passa o idFormulario para o formulário de pesquisa
      body: SatisfactionSurveyForm(idFormulario: widget.idFormulario),
    );
  }
}

/// Formulário de Pesquisa de Satisfação
/// Agora, este widget recebe o idFormulario para fazer a consulta no banco.
class SatisfactionSurveyForm extends StatefulWidget {
  final String idFormulario;
  const SatisfactionSurveyForm({super.key, required this.idFormulario});

  @override
  _SatisfactionSurveyFormState createState() => _SatisfactionSurveyFormState();
}

class _SatisfactionSurveyFormState extends State<SatisfactionSurveyForm>
    with SingleTickerProviderStateMixin {
  int _currentQuestionIndex = -1; // -1 para mostrar a tela de introdução
  String? _observations = '';
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final FirestoreServiceSatisfacao _firestoreService =
      FirestoreServiceSatisfacao();

  // Lista de perguntas e (para as não-texto) avaliações
  final List<Map<String, dynamic>> _questions = [
    {
      'question':
          'As informações apresentadas durante o encontro foram claras e compreensíveis para você?',
      'rating': null,
      'lowLabel': 'Muito insatisfeito',
      'highLabel': 'Muito satisfeito',
    },
    {
      'question':
          'Você acredita que as informações fornecidas no encontro serão úteis para o seu dia a dia?',
      'rating': null,
      'lowLabel': 'Pouco útil',
      'highLabel': 'Muito útil',
    },
    {
      'question':
          'Qual é a sua opinião sobre a qualidade geral do nosso encontro de saneamento básico?',
      'rating': null,
      'lowLabel': 'Muito insatisfeito',
      'highLabel': 'Muito satisfeito',
    },
    {
      'question':
          'Em uma escala de 1 a 5, qual é a probabilidade de você participar de outro encontro organizado por nós no futuro?',
      'rating': null,
      'lowLabel': 'Muito improvável',
      'highLabel': 'Muito provável',
    },
    {
      'question':
          'Como você avalia a sua experiência em nosso encontro sobre saneamento básico?',
      'rating': null,
      'lowLabel': 'Muito insatisfeito',
      'highLabel': 'Muito satisfeito',
    },
    {
      'question': 'Questionamentos/ Observações/ Dúvidas:',
      'isText': true,
    },
  ];

  // Lista para armazenar as respostas finais
  final List<String> respostaFinal = [];

  late Future<DocumentSnapshot> _formDataFuture;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    // Busca os dados do formulário criado no Firestore
    _formDataFuture = FirebaseFirestore.instance
        .collection('formulariosSatisfacao')
        .doc(widget.idFormulario)
        .get();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
      _controller.forward(from: 0);
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
      _controller.forward(from: 0);
    }
  }

  Future<void> _saveResponses() async {
    // Armazena as respostas das perguntas e observações na lista
    for (var i = 0; i < _questions.length - 1; i++) {
      respostaFinal.add(_questions[i]['rating'].toString());
    }
    respostaFinal.add(_observations ?? '');

    // Exibe o vetor de respostas no console (apenas para debug)
    print('Respostas: $respostaFinal');

    // Envia a resposta para o Firestore
    await _firestoreService.submitResponseSatisfacao(context, {
      'idFormulario': widget.idFormulario,
      'respostas': respostaFinal,
    });

    GoRouter.of(context).go('/forms/respondido');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;

    // Tela de introdução: faz a consulta ao banco e exibe os dados do formulário
    if (_currentQuestionIndex == -1) {
      return FutureBuilder<DocumentSnapshot>(
        future: _formDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return Center(child: Text("Erro ao carregar dados do formulário"));
          }
          // Obtem os dados do formulário a partir do documento
          Map<String, dynamic> formData =
              snapshot.data!.data() as Map<String, dynamic>;
          String tipoEvento = formData['tipoEvento'] ?? 'Evento';
          String municipio = formData['municipio'] ?? 'Município';
          String estado = formData['estado'] ?? 'Estado';

          // Ajusta o texto exibido de acordo com o tipo
          if (tipoEvento == 'Comitê') {
            tipoEvento = 'Comitê Executivo e de Coordenação';
          } else if (tipoEvento == 'Evento Público') {
            tipoEvento = 'Encontro Público';
          }

          return SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.indigo.shade700, Colors.purple.shade400],
                ),
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      constraints: BoxConstraints(
                          maxWidth: isWeb ? 800 : double.infinity),
                      padding: EdgeInsets.symmetric(
                        vertical: isWeb ? 40 : 16,
                        horizontal: isWeb ? 40 : 16,
                      ),
                      child: AnimatedOpacity(
                        opacity: 1.0,
                        duration: Duration(milliseconds: 500),
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(isWeb ? 40.0 : 20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TweenAnimationBuilder(
                                  tween: Tween<double>(begin: 0, end: 1),
                                  duration: Duration(milliseconds: 500),
                                  builder: (context, double value, child) {
                                    return Transform.scale(
                                      scale: value,
                                      child: child,
                                    );
                                  },
                                  child: Icon(
                                    Icons.assignment_outlined,
                                    size: isWeb ? 80 : 60,
                                    color: Colors.indigo,
                                  ),
                                ),
                                SizedBox(height: isWeb ? 30 : 20),
                                Text(
                                  'Pesquisa de Satisfação - $tipoEvento - $municipio $estado',
                                  style: TextStyle(
                                    fontSize: isWeb ? 26 : 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo.shade900,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: isWeb ? 30 : 20),
                                Flexible(
                                  child: SingleChildScrollView(
                                    child: Text(
                                      tipoEvento ==
                                              'Comitê Executivo e de Coordenação'
                                          ? 'Agradecemos sua participação nesta pesquisa de satisfação. Seu feedback é essencial para que possamos melhorar continuamente nossos processos e a eficácia do comitê executivo e de coordenação. Suas respostas serão tratadas com confidencialidade e utilizadas exclusivamente para fins de aprimoramento interno.'
                                          : 'Agradecemos por participar da nossa pesquisa de satisfação. Sua opinião é fundamental para melhorarmos nossos serviços. Por favor, responda às perguntas a seguir com sinceridade.',
                                      style: TextStyle(
                                        fontSize: isWeb ? 18 : 16,
                                        height: 1.5,
                                        color: Colors.grey.shade800,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                SizedBox(height: isWeb ? 25 : 15),
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: TweenAnimationBuilder(
                                    tween: Tween<double>(begin: 0, end: 1),
                                    duration: Duration(milliseconds: 500),
                                    builder: (context, double value, child) {
                                      return Transform.translate(
                                        offset: Offset(0, 20 * (1 - value)),
                                        child: Opacity(
                                          opacity: value,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: ElevatedButton(
                                      onPressed: _nextQuestion,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.indigo,
                                        padding: EdgeInsets.symmetric(
                                          vertical: isWeb ? 20 : 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        elevation: 5,
                                        shadowColor:
                                            Colors.indigo.withOpacity(0.3),
                                      ),
                                      child: AnimatedSwitcher(
                                        duration: Duration(milliseconds: 300),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Iniciar',
                                              style: TextStyle(
                                                fontSize: isWeb ? 20 : 18,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              size: isWeb ? 24 : 20,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
          );
        },
      );
    }

    // Caso já tenha iniciado a pesquisa (ou seja, _currentQuestionIndex >= 0)
    final currentQuestion = _questions[_currentQuestionIndex];
    final isAnswerSelected = currentQuestion['isText'] == true
        ? (_observations != null && _observations!.isNotEmpty)
        : currentQuestion['rating'] != null;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Cabeçalho com contador
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Pergunta ${_currentQuestionIndex + 1} de ${_questions.length}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.indigo[800],
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Card com a pergunta
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                      color: Colors.indigo.withOpacity(0.2), width: 1),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    currentQuestion['question'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[800],
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Campo de texto ou seleção de nota
              if (currentQuestion['isText'] == true)
                TextField(
                  onChanged: (value) => setState(() => _observations = value),
                  decoration: InputDecoration(
                    hintText: 'Escreva aqui suas observações...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.indigo, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  maxLines: 4,
                )
              else ...[
                // Rótulos da escala
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currentQuestion['lowLabel'] ?? "",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        currentQuestion['highLabel'] ?? "",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Seletor de avaliação
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (index) {
                      final ratingValue = index + 1;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _questions[_currentQuestionIndex]['rating'] =
                              ratingValue;
                        }),
                        child: Container(
                          width: 48,
                          height: 48,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: currentQuestion['rating'] == ratingValue
                                ? _getRatingColor(ratingValue)
                                : Colors.grey[100],
                            shape: BoxShape.circle,
                            border: currentQuestion['rating'] == ratingValue
                                ? Border.all(
                                    color: Colors.indigo.withOpacity(0.2),
                                    width: 2)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '$ratingValue',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: currentQuestion['rating'] == ratingValue
                                    ? Colors.white
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
              const SizedBox(height: 36),
              // Botões de navegação
              Row(
                mainAxisAlignment: _currentQuestionIndex > 0
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.end,
                children: [
                  if (_currentQuestionIndex > 0)
                    OutlinedButton(
                      onPressed: _previousQuestion,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 12),
                        side: BorderSide(color: Colors.indigo),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Voltar',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.indigo[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (_currentQuestionIndex < _questions.length - 1)
                    ElevatedButton(
                      onPressed: isAnswerSelected ? _nextQuestion : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'Próxima',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (_currentQuestionIndex == _questions.length - 1)
                    ElevatedButton(
                      onPressed: _saveResponses,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Enviar Respostas',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRatingColor(int rating) {
    final hues = [
      Colors.red[400]!,
      Colors.orange[400]!,
      Colors.yellow[600]!,
      Colors.lightGreen[400]!,
      Colors.green[400]!
    ];
    return hues[rating - 1];
  }
}
