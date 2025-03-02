import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import 'package:just_audio/just_audio.dart';

// 1. Configuração do Firestore Service

import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';

class FirestoreServiceVotacao {
  final FirebaseFirestore _firestoreVotacao = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid(); // Instância do UUID

  /// Gera um ID único usando UUID v4
  Future<String> generateFormId() async {
    return _uuid
        .v4(); // Exemplo de saída: "3fa85f64-5717-4562-b3fc-2c963f66afa6"
  }

  /// Cria um novo formulário no Firestore com um ID aleatório
  Future<void> createFormVotacao(Map<String, dynamic> formData) async {
    DateTime now = DateTime.now();
    formData['dataCriacao'] = "${now.day}/${now.month}/${now.year}";
    formData['horaCriacao'] =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

    await _firestoreVotacao
        .collection('formulariosVotacao')
        .doc(formData['idFormulario'])
        .set(formData);
  }

  /// Envia uma resposta para um formulário específico com data e hora separadas
  Future<void> submitResponseVotacao(Map<String, dynamic> responseData) async {
    DateTime now = DateTime.now();
    responseData['dataResposta'] = "${now.day}/${now.month}/${now.year}";
    responseData['horaResposta'] =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

    await _firestoreVotacao.collection('respostasVotacao').add(responseData);
  }
}

// 2. Tela de Criação de Formulárioimport 'package:flutter/material.dart';

class CriarFormularioScreenVotacao extends StatefulWidget {
  const CriarFormularioScreenVotacao({super.key});

  @override
  _CriarFormularioScreenVotacaoState createState() =>
      _CriarFormularioScreenVotacaoState();
}

class _CriarFormularioScreenVotacaoState
    extends State<CriarFormularioScreenVotacao> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreServiceVotacao _firestoreService = FirestoreServiceVotacao();

  final List<TextEditingController> _candidatosControllers = [];
  // Novo controlador para quantidade total de votos
  final TextEditingController _totalVotosController = TextEditingController();

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

  String _estadoSelecionado = "Bahia";
  String? _municipioSelecionado;

  String _generateLink(String idFormulario) {
    return 'https://plansanear.com.br/redeplansanea/v10/#/Votacao/$idFormulario';
  }

  String _formIdGoTo(String idFormulario) {
    return idFormulario;
  }

  Future<void> _submitFormVotacao() async {
    if (_formKey.currentState!.validate() && _municipioSelecionado != null) {
      final user = _auth.currentUser!;
      final id = await _firestoreService.generateFormId();
      final link = _generateLink(id);
      final rotaVotacao = _formIdGoTo(id);

      // Extrai os nomes dos candidatos
      List<String> candidatos =
          _candidatosControllers.map((c) => c.text).toList();
      // Converte a quantidade total de votos para inteiro
      int totalVotos = int.tryParse(_totalVotosController.text) ?? 0;

      await _firestoreService.createFormVotacao({
        'idFormulario': id,
        'autor': user.displayName ?? user.email!,
        'link': link,
        'municipio': _municipioSelecionado,
        'estado': _estadoSelecionado,
        'candidatos': candidatos, // candidatos dinâmicos
        'totalVotos': totalVotos, // quantidade total de votos definida
      });
      Navigator.pop(context);

      /*   showModalBottomSheet(
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
                        GoRouter.of(context).go('/votacao/$rotaVotacao');
                      },
                      icon: const Icon(Icons.door_back_door),
                      label: const Text('Ir para votação'),
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
      );*/
    }
  }

  late AudioPlayer _player;

  @override
  void initState() {
    super.initState();

    _candidatosControllers.add(TextEditingController());
    _player = AudioPlayer();
  }

  @override
  void dispose() {
    _player.dispose();
    // Dispose dos controladores dos candidatos
    for (var controller in _candidatosControllers) {
      controller.dispose();
    }
    _totalVotosController.dispose();
    super.dispose();
  }

  Widget _buildDecoratedDropdownVotacao(String label, Widget child) {
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
                          Text('Criar Nova Votação',
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
                      _buildDecoratedDropdownVotacao(
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
                      _buildDecoratedDropdownVotacao(
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

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Candidatos',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _candidatosControllers.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: TextFormField(
                              controller: _candidatosControllers[index],
                              decoration: InputDecoration(
                                labelText: 'Nome do Candidato ${index + 1}',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Campo obrigatório';
                                }
                                return null;
                              },
                            ),
                          );
                        },
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.blue),
                          tooltip: 'Adicionar candidato',
                          onPressed: () {
                            setState(() {
                              _candidatosControllers
                                  .add(TextEditingController());
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Novo campo para a quantidade total de votos
                      TextFormField(
                        controller: _totalVotosController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Quantidade Total de Votos',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe a quantidade total de votos';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Informe um número válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _submitFormVotacao();
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

class ResponderFormularioScreenVotacao extends StatefulWidget {
  final String idFormulario;

  const ResponderFormularioScreenVotacao({
    Key? key,
    required this.idFormulario,
  }) : super(key: key);

  @override
  _ResponderFormularioScreenVotacaoState createState() =>
      _ResponderFormularioScreenVotacaoState();
}

class _ResponderFormularioScreenVotacaoState
    extends State<ResponderFormularioScreenVotacao> {
  String? _selectedOption;
  late Future<DocumentSnapshot> _formFuture;
  late AudioPlayer _player;
  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    // Armazena o future para que ele seja executado apenas uma vez
    _formFuture = FirebaseFirestore.instance
        .collection('formulariosVotacao')
        .doc(widget.idFormulario)
        .get();
  }

  // Função para submeter o voto (caso ainda seja possível votar)
  Future<void> _submitVote() async {
    if (_selectedOption == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Selecione uma opção")));
      return;
    }

    // 1. Buscar o formulário para obter o total de votos
    DocumentSnapshot formSnapshot = await FirebaseFirestore.instance
        .collection('formulariosVotacao')
        .doc(widget.idFormulario)
        .get();

    if (!formSnapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Formulário não encontrado")));
      return;
    }

    final formData = formSnapshot.data() as Map<String, dynamic>;
    final int totalVotos = formData['totalVotos'] is int
        ? formData['totalVotos']
        : int.tryParse(formData['totalVotos'].toString()) ?? 0;

    // 2. Buscar o documento de respostas para contar os votos já registrados
    final respostasDocRef = FirebaseFirestore.instance
        .collection('respostasVotacao')
        .doc(widget.idFormulario);
    DocumentSnapshot respostasSnapshot = await respostasDocRef.get();
    int currentVotes = 0;
    if (respostasSnapshot.exists) {
      final data = respostasSnapshot.data() as Map<String, dynamic>;
      if (data.containsKey('respostas')) {
        List<dynamic> respostasList = data['respostas'];
        currentVotes = respostasList.length;
      }
    }

    // 3. Verifica se o número máximo de votos já foi atingido
    if (currentVotes >= totalVotos) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Número máximo de votos atingido")));
      return;
    }

    // Dados do novo voto
    final voteData = {
      'voto': _selectedOption,
      'dataResposta':
          "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
      'horaResposta':
          "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}:${DateTime.now().second.toString().padLeft(2, '0')}",
    };

    // 4. Atualiza o documento de respostas adicionando o novo voto ao array
    await respostasDocRef.set({
      'respostas': FieldValue.arrayUnion([voteData]),
    }, SetOptions(merge: true));

    // toca uma música para indicar que o voto foi registrado

    _player.setAsset('assets/votacao/ok.mp3');
    _player.play();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Voto registrado!",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      ),
    );
    GoRouter.of(context).go('/forms/respondidoVotacao/${widget.idFormulario}');
  }

  @override
  Widget build(BuildContext context) {
    // Primeiro, carrega os dados do formulário (dados estáticos: candidatos, total de votos, etc.)
    return FutureBuilder<DocumentSnapshot>(
      future: _formFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text("Carregando formulário...")),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(title: const Text("Erro")),
            body: const Center(child: Text("Formulário não encontrado")),
          );
        }

        final formData = snapshot.data!.data() as Map<String, dynamic>;
        final int totalVotos = formData['totalVotos'] is int
            ? formData['totalVotos']
            : int.tryParse(formData['totalVotos'].toString()) ?? 0;
        final List<dynamic>? candidatosDynamic =
            formData['candidatos'] as List<dynamic>?;
        List<String> opcoes = [];
        if (candidatosDynamic != null) {
          opcoes = candidatosDynamic.map((e) => e.toString()).toList();
        }
        // Adiciona a opção "Abstenção"
        opcoes.add("Abstenção");

        // Agora, use um StreamBuilder para monitorar em tempo real as respostas e contar os votos
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('respostasVotacao')
              .doc(widget.idFormulario)
              .snapshots(),
          builder: (context, responseSnapshot) {
            int currentVotes = 0;
            if (responseSnapshot.hasData && responseSnapshot.data!.exists) {
              final data =
                  responseSnapshot.data!.data() as Map<String, dynamic>;
              if (data.containsKey('respostas')) {
                List<dynamic> respostasList = data['respostas'];
                currentVotes = respostasList.length;
              }
            }

            // Se o limite de votos foi atingido, exibe uma mensagem e desabilita a votação
            if (currentVotes >= totalVotos) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(
                    "${formData['municipio'] ?? 'Local não definido'} - ${formData['estado'] ?? ''}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  centerTitle: true,
                  backgroundColor: Colors.blue.shade700,
                ),
                body: Center(
                  child: Text(
                    "Número máximo de votos atingido.\nVotação encerrada.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }

            // Caso ainda seja possível votar, exibe a interface com as opções
            return Scaffold(
              /* appBar: AppBar(
                title: Text(
                  "${formData['municipio'] ?? 'Local não definido'}",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                centerTitle: true,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade800, Colors.indigo.shade900],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                elevation: 5,
              ),*/
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(100.0),
                child: AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                  elevation: 2,
                  shadowColor: Colors.blue.shade100,
                  flexibleSpace: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF00B3CC),
                          Color(0xFF004466),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        children: [
                          Expanded(
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
                                // Título
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${formData['municipio'] ?? 'Local não definido'} - ${formData['estado'] ?? ''}',
                                      style: GoogleFonts.roboto(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'Votação',
                                      style: GoogleFonts.roboto(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                        color: const Color.fromARGB(
                                            255, 230, 242, 255),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
                    colors: [Colors.grey.shade100, Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Informações

                      const SizedBox(height: 25),
                      Expanded(
                        child: ListView.separated(
                          itemCount: opcoes.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final option = opcoes[index];
                            final isAbstencao = option == "Abstenção";
                            final isSelected = _selectedOption == option;

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isAbstencao
                                        ? Colors.orange.shade50
                                        : Colors.blue.shade50)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: isSelected
                                      ? (isAbstencao
                                          ? Colors.orange.shade300
                                          : Colors.blue.shade300)
                                      : Colors.grey.shade200,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(isSelected ? 0.1 : 0.05),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                leading: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: isSelected
                                      ? Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: isAbstencao
                                                ? Colors.orange.shade100
                                                : Colors.blue.shade100,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.check_rounded,
                                            color: isAbstencao
                                                ? Colors.orange.shade800
                                                : Colors.blue.shade800,
                                          ),
                                        )
                                      : Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey.shade400,
                                              width: 2,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              (index + 1).toString(),
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                ),
                                title: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isAbstencao
                                        ? Colors.orange.shade800
                                        : Colors.grey.shade800,
                                  ),
                                ),
                                trailing: isAbstencao
                                    ? Icon(Icons.gpp_maybe_rounded,
                                        color: Colors.orange.shade600, size: 28)
                                    : Icon(Icons.person_rounded,
                                        color: Colors.blue.shade600, size: 28),
                                onTap: () =>
                                    setState(() => _selectedOption = option),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 25),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20, top: 10),
                        child: Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(15),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _selectedOption != null
                                    ? [
                                        Colors.blue.shade600,
                                        Colors.blue.shade800,
                                      ]
                                    : [
                                        Colors.grey.shade400,
                                        Colors.grey.shade600,
                                      ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.shade200.withOpacity(
                                      _selectedOption != null ? 0.5 : 0),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(15),
                              onTap:
                                  _selectedOption != null ? _submitVote : null,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 18, horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      child: _selectedOption != null
                                          ? const Icon(Icons.how_to_vote,
                                              color: Colors.white, size: 28)
                                          : const Icon(Icons.lock_rounded,
                                              color: Colors.white, size: 28),
                                    ),
                                    const SizedBox(width: 15),
                                    Text(
                                      _selectedOption != null
                                          ? "CONFIRMAR VOTO".toUpperCase()
                                          : "SELECIONE UMA OPÇÃO",
                                      style: GoogleFonts.robotoCondensed(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.5,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
