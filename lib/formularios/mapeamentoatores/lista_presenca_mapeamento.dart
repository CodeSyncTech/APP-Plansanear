import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

// 1. Configuração do Firestore Service

import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';

class FirestoreServiceMapeamento {
  final FirebaseFirestore _firestoreMapeamento = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid(); // Instância do UUID

  /// Gera um ID único usando UUID v4
  Future<String> generateFormId() async {
    return _uuid
        .v4(); // Exemplo de saída: "3fa85f64-5717-4562-b3fc-2c963f66afa6"
  }

  /// Cria um novo formulário no Firestore com um ID aleatório
  Future<void> createFormMapeamento(Map<String, dynamic> formData) async {
    DateTime now = DateTime.now();
    formData['dataCriacao'] = "${now.day}/${now.month}/${now.year}";
    formData['horaCriacao'] =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

    await _firestoreMapeamento
        .collection('formulariosMapeamento')
        .doc(formData['idFormulario'])
        .set(formData);
  }

  /// Envia uma resposta para um formulário específico com data e hora separadas
  Future<void> submitResponseMapeamento(
      Map<String, dynamic> responseData) async {
    DateTime now = DateTime.now();
    responseData['dataResposta'] = "${now.day}/${now.month}/${now.year}";
    responseData['horaResposta'] =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

    await _firestoreMapeamento
        .collection('respostasMapeamento')
        .add(responseData);
  }
}

// 2. Tela de Criação de Formulárioimport 'package:flutter/material.dart';

class CriarFormularioScreenMapeamento extends StatefulWidget {
  const CriarFormularioScreenMapeamento({super.key});

  @override
  _CriarFormularioScreenMapeamentoState createState() =>
      _CriarFormularioScreenMapeamentoState();
}

class _CriarFormularioScreenMapeamentoState
    extends State<CriarFormularioScreenMapeamento> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreServiceMapeamento _firestoreService =
      FirestoreServiceMapeamento();

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
    return 'https://plansanear.com.br/redeplansanea/v10/#/mapeamento/$idFormulario';
  }

  Future<void> _submitFormMapeamento() async {
    if (_formKey.currentState!.validate() && _municipioSelecionado != null) {
      final user = _auth.currentUser!;

      // Verifica se já existe um formulário para essa cidade e estado
      final querySnapshot = await FirebaseFirestore.instance
          .collection('formulariosMapeamento')
          .where('municipio', isEqualTo: _municipioSelecionado)
          .where('estado', isEqualTo: _estadoSelecionado)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Se já existir um formulário, exibe um erro e interrompe a criação
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Já existe um formulário criado para $_municipioSelecionado - $_estadoSelecionado.',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return; // Sai da função sem criar um novo formulário
      }

      // Se não existir, continua com a criação do formulário
      final id = await _firestoreService.generateFormId();
      final link = _generateLink(id);

      await _firestoreService.createFormMapeamento({
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

  Widget _buildDecoratedDropdownMapeamento(String label, Widget child) {
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
                          Text('Criar Novo Mapeamento',
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
                      _buildDecoratedDropdownMapeamento(
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
                      _buildDecoratedDropdownMapeamento(
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
                            _submitFormMapeamento();
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

class ResponderFormularioScreenMapeamento extends StatefulWidget {
  final String idFormulario;

  const ResponderFormularioScreenMapeamento({
    super.key,
    required this.idFormulario,
  });

  @override
  _ResponderFormularioScreenMapeamentoState createState() =>
      _ResponderFormularioScreenMapeamentoState();
}

class _ResponderFormularioScreenMapeamentoState
    extends State<ResponderFormularioScreenMapeamento> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> categorias = [
    "Representantes do Poder Executivo",
    "Representantes dos Conselhos Municipais",
    "Representantes dos Segmentos Organizados Sociais",
    "Representantes da Sociedade Civil"
  ];

  Map<String, List<Map<String, String>>> representantes = {};

  // Mapas para armazenar os controllers de cada campo.
  Map<String, List<TextEditingController>> _nomeControllers = {};
  Map<String, List<TextEditingController>> _cargoControllers = {};
  Map<String, List<TextEditingController>> _telefoneControllers = {};

  @override
  void initState() {
    super.initState();
    _fetchFormularioInfo();
    for (var categoria in categorias) {
      representantes[categoria] = [];
      _nomeControllers[categoria] = [];
      _cargoControllers[categoria] = [];
      _telefoneControllers[categoria] = [];
    }
  }

  void _adicionarRepresentante(String categoria) {
    setState(() {
      representantes[categoria]?.add({
        'nome': '',
        'cargo': '',
        'telefone': '',
      });
      // Cria e armazena os controllers correspondentes.
      _nomeControllers[categoria]?.add(TextEditingController());
      _cargoControllers[categoria]?.add(TextEditingController());
      _telefoneControllers[categoria]?.add(TextEditingController());
    });
  }

  void _removerRepresentante(String categoria, int index) {
    setState(() {
      representantes[categoria]?.removeAt(index);
      // Dispose dos controllers antes de removê-los.
      _nomeControllers[categoria]?[index].dispose();
      _cargoControllers[categoria]?[index].dispose();
      _telefoneControllers[categoria]?[index].dispose();
      _nomeControllers[categoria]?.removeAt(index);
      _cargoControllers[categoria]?.removeAt(index);
      _telefoneControllers[categoria]?.removeAt(index);
    });
  }

  Future<void> _submitResponseMapeamento() async {
    if (_formKey.currentState!.validate()) {
      for (var categoria in categorias) {
        for (int i = 0; i < representantes[categoria]!.length; i++) {
          representantes[categoria]![i]['nome'] =
              _nomeControllers[categoria]![i].text;
          representantes[categoria]![i]['cargo'] =
              _cargoControllers[categoria]![i].text;
          representantes[categoria]![i]['telefone'] =
              _telefoneControllers[categoria]![i].text;
        }
      }
      // Estrutura correta para salvar no Firestore
      Map<String, dynamic> responseData = {
        'idFormulario': widget.idFormulario,
        'dataResposta': DateTime.now().toIso8601String(),
        'representantes': {},
      };

      // Adiciona representantes ao Firestore no formato correto
      representantes.forEach((categoria, lista) {
        if (lista.isNotEmpty) {
          responseData['representantes'][categoria] = lista;
        }
      });

      await _firestore.collection('respostasMapeamento').add(responseData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Resposta enviada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      GoRouter.of(context).go('/forms/respondido');
    }
  }

  String? _municipio;
  String? _estado;

  Future<void> _fetchFormularioInfo() async {
    DocumentSnapshot<Map<String, dynamic>> docSnapshot = await _firestore
        .collection('formulariosMapeamento')
        .doc(widget.idFormulario)
        .get();

    if (docSnapshot.exists) {
      setState(() {
        _municipio = docSnapshot.data()?['municipio'];
        _estado = docSnapshot.data()?['estado'];
      });
    }
  }

  @override
  void dispose() {
    // Dispose de todos os controllers.
    _nomeControllers.forEach((key, controllers) {
      for (var c in controllers) {
        c.dispose();
      }
    });
    _cargoControllers.forEach((key, controllers) {
      for (var c in controllers) {
        c.dispose();
      }
    });
    _telefoneControllers.forEach((key, controllers) {
      for (var c in controllers) {
        c.dispose();
      }
    });
    super.dispose();
  }

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
                mainAxisAlignment:
                    MainAxisAlignment.center, // Centralização principal
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
                        'Mapeamento',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        _municipio != null && _estado != null
                            ? '$_municipio - $_estado'
                            : 'Carregando...',
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Preencha os representantes para cada categoria desejada:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ...categorias.map((categoria) {
                return _buildCategoryCard(categoria);
              }).toList(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitResponseMapeamento,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  shadowColor: Colors.teal.shade300,
                ),
                child: Text(
                  'ENVIAR FORMULÁRIO',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.white,
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
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String categoria) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.only(bottom: 20),
      child: ExpansionTile(
        leading: Icon(Icons.group, color: Colors.teal.shade700),
        title: Text(
          categoria,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 15),
        expandedAlignment: Alignment.centerLeft,
        children: [
          ...List.generate(
            representantes[categoria]!.length,
            (index) => _buildRepresentanteFields(categoria, index),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.add_circle, color: Colors.white),
            label: const Text('Adicionar Representante',
                style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 0, 124, 110),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
            ),
            onPressed: () => _adicionarRepresentante(categoria),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // Modifique o _buildRepresentanteFields para atribuir os valores iniciais dos campos
  Widget _buildRepresentanteFields(String categoria, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Column(
        children: [
          TextFormField(
            controller: _nomeControllers[categoria]![index],
            decoration: InputDecoration(
              labelText: 'Nome Completo',
              prefixIcon: Icon(Icons.person, color: Colors.teal.shade700),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            style: TextStyle(color: Colors.teal.shade900),
            onChanged: (value) {
              representantes[categoria]?[index]['nome'] = value;
            },
            validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _cargoControllers[categoria]![index],
            decoration: InputDecoration(
              labelText: 'Cargo/Instituição',
              prefixIcon: Icon(Icons.work, color: Colors.teal.shade700),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            style: TextStyle(color: Colors.teal.shade900),
            onChanged: (value) {
              representantes[categoria]?[index]['cargo'] = value;
            },
            validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
          ),
          const SizedBox(height: 15),
          IntlPhoneField(
            controller: _telefoneControllers[categoria]![index],
            decoration: InputDecoration(
              labelText: 'Telefone',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(Icons.phone, color: Colors.teal.shade700),
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
            style: TextStyle(color: Colors.teal.shade900),
            dropdownTextStyle: TextStyle(color: Colors.teal.shade900),
            initialCountryCode: 'BR',
            onChanged: (phone) {
              representantes[categoria]?[index]['telefone'] =
                  phone.completeNumber;
            },
            validator: (phone) {
              if (phone == null || phone.number.isEmpty) {
                return 'Informe um número válido';
              }
              return null;
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () => _removerRepresentante(categoria, index),
            ),
          ),
        ],
      ),
    );
  }

// Adapte o _buildCustomTextField para aceitar um initialValue
  Widget _buildCustomTextField({
    required String label,
    required IconData icon,
    required Function(String) onChanged,
    String? initialValue,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.teal.shade700),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        style: TextStyle(color: Colors.teal.shade900),
        onChanged: onChanged,
        validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
      ),
    );
  }

  Widget _buildAddButton(String categoria) {
    return ElevatedButton.icon(
      icon: Icon(Icons.add_circle, color: Colors.white),
      label: Text('Adicionar Representante',
          style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 0, 124, 110),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
      ),
      onPressed: () => _adicionarRepresentante(categoria),
    );
  }
}
