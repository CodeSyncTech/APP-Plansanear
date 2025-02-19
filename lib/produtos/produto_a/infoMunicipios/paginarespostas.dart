import 'dart:io';

import 'package:Redeplansanea/produtos/produto_a/produto_a.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

/// ------------------------------------------------------------
/// Funções de integração com Firebase Auth e Firestore
/// ------------------------------------------------------------

/// Obtém o UID do usuário logado
String getUserUID() {
  return FirebaseAuth.instance.currentUser?.uid ?? "defaultUser";
}

/// Carrega as respostas salvas (todas mescladas num único documento)
Future<Map<String, dynamic>> carregarRespostas() async {
  String uid = getUserUID();
  DocumentSnapshot doc = await FirebaseFirestore.instance
      .collection("formInfoMunicipio")
      .doc(uid)
      .get();

  if (doc.exists) {
    return doc.data() as Map<String, dynamic>;
  } else {
    return {};
  }
}

/// Salva (ou atualiza) as respostas no Firestore
Future<void> salvarRespostas(Map<String, dynamic> respostas) async {
  String uid = getUserUID();
  await FirebaseFirestore.instance
      .collection("formInfoMunicipio")
      .doc(uid)
      .set(respostas, SetOptions(merge: true));
}

/// ------------------------------------------------------------
/// Modelo para perguntas de resposta única (usado em Acesso e Saneamento)
/// ------------------------------------------------------------

class UniqueQuestion {
  final String id;
  final String question;
  final List<String> options;
  String? selected;
  String? extra; // ex.: Número da Lei Orgânica

  UniqueQuestion({
    required this.id,
    required this.question,
    required this.options,
    this.selected,
    this.extra,
  });
}

/// Widget para exibir uma pergunta com dropdown e (se necessário) um campo extra
class DropdownQuestionWidget extends StatelessWidget {
  final UniqueQuestion question;
  final ValueChanged<String?> onChanged;
  final ValueChanged<String>? onExtraChanged;

  /// Quando a opção selecionada for igual a [requiredExtraOption], exibe o campo extra.
  final String? requiredExtraOption;

  /// Rótulo para o campo extra (ex.: "Número da Lei Orgânica")
  final String? extraLabel;

  const DropdownQuestionWidget({
    Key? key,
    required this.question,
    required this.onChanged,
    this.onExtraChanged,
    this.requiredExtraOption,
    this.extraLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.question,
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          style: GoogleFonts.roboto(color: Colors.grey.shade800),
          dropdownColor: Colors.white,
          value: question.selected,
          items: question.options
              .map((option) => DropdownMenuItem<String>(
                    child: Text(
                      option,
                      style: GoogleFonts.roboto(fontSize: 16),
                    ),
                    value: option,
                  ))
              .toList(),
          onChanged: onChanged,
          validator: (value) =>
              value == null || value.isEmpty ? "Selecione uma opção" : null,
        ),
        if (requiredExtraOption != null &&
            question.selected == requiredExtraOption &&
            onExtraChanged != null &&
            extraLabel != null) ...[
          SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: extraLabel,
              labelStyle: GoogleFonts.roboto(color: Colors.grey.shade600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            style: GoogleFonts.roboto(color: Colors.grey.shade800),
            initialValue: question.extra,
            onChanged: onExtraChanged,
            validator: (value) {
              if (question.selected == requiredExtraOption &&
                  (value == null || value.trim().isEmpty)) {
                return "Informe o $extraLabel";
              }
              return null;
            },
          ),
        ],
        SizedBox(height: 24),
      ],
    );
  }
}

/// ------------------------------------------------------------
/// Tela 1 – Acesso ao Município
/// ------------------------------------------------------------

class AcessoMunicipioScreen extends StatefulWidget {
  @override
  _AcessoMunicipioScreenState createState() => _AcessoMunicipioScreenState();
}

class _AcessoMunicipioScreenState extends State<AcessoMunicipioScreen> {
  final _formKey = GlobalKey<FormState>();

  // variaveis para receber URL e arquivo da lei organica
  PlatformFile? _selectedFile;
  String? _leiOrganicaFileUrl;
  String? _leiOrganicaFileName;
  String? _leiOrganicaNumber;

  TextEditingController _leiOrganicaNumberController = TextEditingController();

  // variavel bool para  controlar upload de arquivo

  bool _isUploading = false;

  //variaveis para controle de animação de envio de documentos para o firebase

  // Vias de acesso – seleção múltipla
  final List<String> accessRoutes = ["Rodovia", "Ferrovia", "Hidrovia"];
  List<String> selectedAccessRoutes = [];

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = result.files.first;
        // Se um novo arquivo for escolhido, limpa o URL anterior
        _leiOrganicaFileUrl = null;
      });
    }
  }

  Future<String?> uploadFile(PlatformFile file) async {
    final storageRef = FirebaseStorage.instance.ref();
    final fileRef =
        storageRef.child("lei_organica_files/${getUserUID()}_${file.name}");
    UploadTask uploadTask;

    if (kIsWeb) {
      // No Flutter Web, utilize os bytes do arquivo
      if (file.bytes == null) {
        throw Exception("Nenhum dado encontrado no arquivo selecionado.");
      }
      uploadTask = fileRef.putData(file.bytes!);
    } else {
      // Para dispositivos móveis/desktop, utilize o arquivo do sistema
      File localFile = File(file.path!);
      uploadTask = fileRef.putFile(localFile);
    }

    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  @override
  void initState() {
    super.initState();

    carregarRespostas().then((respostas) {
      setState(() {
        // Carrega as vias de acesso
        selectedAccessRoutes =
            List<String>.from(respostas["accessRoutes"] ?? []);

        // Carrega o número da lei (convertendo para String se necessário)
        _leiOrganicaNumber = respostas["leiOrganicaNumber"]?.toString() ?? '';

        // Atualiza o controlador do campo de texto
        _leiOrganicaNumberController.text = _leiOrganicaNumber!;

        // Carrega os dados do arquivo
        _leiOrganicaFileUrl = respostas["leiOrganicaFileUrl"] as String?;
        _leiOrganicaFileName = respostas["leiOrganicaFileName"] as String?;
      });
    });
  }

  void salvarEAvancar() async {
    if ((_formKey.currentState?.validate() ?? false) && !_isUploading) {
      setState(() => _isUploading = true);
      // Validação do número da lei
      if (_leiOrganicaNumber == null || _leiOrganicaNumber!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Informe o número da Lei Orgânica")),
        );
        setState(() => _isUploading = false); // Adicione esta linha
        return;
      }

// Validação do arquivo
      if (_leiOrganicaFileUrl == null && _selectedFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Anexe o arquivo da Lei Orgânica")),
        );
        setState(() => _isUploading = false); // Adicione esta linha
        return;
      }

      // Upload do arquivo se necessário
      if (_selectedFile != null) {
        try {
          String? fileUrl = await uploadFile(_selectedFile!);
          if (fileUrl == null) return;
          _leiOrganicaFileUrl = fileUrl;
          _leiOrganicaFileName = _selectedFile!.name;
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erro no upload: ${e.toString()}")),
          );
          setState(() => _isUploading = false);
          return;
        }
      }

      await salvarRespostas({
        "accessRoutes": selectedAccessRoutes,
        "leiOrganicaNumber": _leiOrganicaNumber,
        "leiOrganicaFileUrl": _leiOrganicaFileUrl,
        "leiOrganicaFileName": _leiOrganicaFileName,
      });

      setState(() => _isUploading = false); // Finaliza o loading
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ComunicacaoScreen()),
      );
    }
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
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  // Conteúdo centralizado
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
                              'Identificação do',
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              'Município',
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

                  // Botão de adicionar estilizado
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF5F9FF)],
            stops: [0.1, 0.9],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  title: "Quais são as vias de acesso ao Município?",
                  icon: Icons.location_city,
                ),
                SizedBox(height: 32),
                _buildAccessRoutesCard(),
                SizedBox(height: 32),
                _buildLawSectionCard(),
                SizedBox(height: 40),
                _buildNavigationButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required IconData icon}) {
    return Container(
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Color(0xFF1A237E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.people_alt, color: Colors.white, size: 22),
          ),
          SizedBox(width: 12),
          Flexible(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A237E),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessRoutesCard() {
    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(0x143A3A3A),
              blurRadius: 30,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: accessRoutes
                .map((route) => _buildCustomCheckbox(route))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomCheckbox(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Color(0xFFEAEFF5), width: 1.5),
        ),
        child: Theme(
          data: ThemeData(unselectedWidgetColor: Color(0xFF90A4AE)),
          child: CheckboxListTile(
            title: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Color(0xFF37474F),
                fontWeight: FontWeight.w500,
              ),
            ),
            value: selectedAccessRoutes.contains(title),
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  selectedAccessRoutes.add(title);
                } else {
                  selectedAccessRoutes.remove(title);
                }
              });
            },
            activeColor: Color(0xFF1A237E),
            checkColor: Colors.white,
            tileColor: Colors.transparent,
            dense: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildLawSectionCard() {
    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(0x143A3A3A),
              blurRadius: 30,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                "Anexe a Lei Orgânica do Município:",
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 18),
              TextFormField(
                controller: _leiOrganicaNumberController,
                decoration: InputDecoration(
                  labelText: "Número da Lei Orgânica",
                  hintText: "Digite o número completo da lei",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _leiOrganicaNumber = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Campo obrigatório";
                  }
                  return null;
                },
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 14),
                  _isUploading // Mostra o indicador durante o upload
                      ? _buildUploadProgress()
                      : _leiOrganicaFileUrl != null
                          ? Row(
                              children: [
                                Expanded(
                                  child: ListTile(
                                    leading: Icon(Icons.check_circle,
                                        color: Colors.green),
                                    title: Text("Arquivo anexado"),
                                    subtitle: Text(_selectedFile?.name ??
                                        _leiOrganicaFileName ??
                                        "Arquivo previamente enviado"),
                                  ),
                                ),
                                TextButton(
                                  onPressed: pickFile,
                                  child: Text("Alterar"),
                                ),
                              ],
                            )
                          : ElevatedButton.icon(
                              onPressed: pickFile,
                              icon: Icon(Icons.attach_file),
                              label: Text(_selectedFile != null
                                  ? "Arquivo selecionado: ${_selectedFile!.name}"
                                  : "Selecionar arquivo (.pdf, .doc, .docx)"),
                            ),
                  if (_leiOrganicaFileUrl == null && _selectedFile == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text("Nenhum arquivo selecionado",
                          style: TextStyle(color: Colors.red)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadProgress() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade800),
            strokeWidth: 3,
          ),
          SizedBox(height: 10),
          Text(
            "Enviando arquivo...",
            style: TextStyle(
              color: Colors.blue.shade800,
              fontSize: 14,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: _isUploading
                ? LinearGradient(colors: [Colors.grey, Colors.grey])
                : LinearGradient(
                    colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            boxShadow: [
              BoxShadow(
                color: Color(0x331A237E),
                blurRadius: 15,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _isUploading ? null : salvarEAvancar,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            child: _isUploading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    "Próximo",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

/// ------------------------------------------------------------
/// Modelo para as opções pré-definidas de comunicação
/// ------------------------------------------------------------

class CommunicationOption {
  String name;
  bool selected;
  List<TextEditingController> contactControllers;

  CommunicationOption({
    required this.name,
    this.selected = false,
    List<TextEditingController>? contactControllers,
  }) : contactControllers = contactControllers ?? [];
}

/// ------------------------------------------------------------
/// Modelo para as entradas de “Outros”
class OtherChannelEntry {
  TextEditingController channelController;
  TextEditingController contactController;

  OtherChannelEntry({String? channel, String? contact})
      : channelController = TextEditingController(text: channel),
        contactController = TextEditingController(text: contact);
}

/// ------------------------------------------------------------
/// Tela 2 – Meios de Comunicação (Dinâmica)
/// ------------------------------------------------------------

class ComunicacaoScreen extends StatefulWidget {
  @override
  _ComunicacaoScreenState createState() => _ComunicacaoScreenState();
}

class _ComunicacaoScreenState extends State<ComunicacaoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Opções pré-definidas (excluímos "Outros" daqui)
  late List<CommunicationOption> communicationOptions;

  // Lista para os canais customizados ("Outros")
  List<OtherChannelEntry> otherChannels = [];

  @override
  void initState() {
    super.initState();
    // Inicializa as opções pré-definidas
    communicationOptions = [
      CommunicationOption(name: "Rádio comunitária"),
      CommunicationOption(name: "Influenciadores digitais"),
      CommunicationOption(name: "Carro/moto som"),
      CommunicationOption(name: "Canais do youtube"),
      CommunicationOption(name: "Redes sociais da prefeitura"),
      CommunicationOption(name: "Cartaz/panfleto"),
      CommunicationOption(name: "TV local"),
      CommunicationOption(name: "Divulgação direta"),
      CommunicationOption(name: "Jornal Impresso"),
      CommunicationOption(name: "Blogs"),
    ];

    // Carrega dados salvos, se existirem
    carregarRespostas().then((respostas) {
      if (respostas["comunicacao"] != null &&
          respostas["comunicacao"] is Map<String, dynamic>) {
        Map<String, dynamic> savedCom = respostas["comunicacao"];
        setState(() {
          // Para as opções pré-definidas
          for (var option in communicationOptions) {
            if (savedCom.containsKey(option.name)) {
              option.selected = true;
              List<dynamic> contatos = savedCom[option.name];
              option.contactControllers = contatos
                  .map((contato) =>
                      TextEditingController(text: contato.toString()))
                  .toList();
            }
          }
          // Agora, carrega os "Outros" a partir do mapa "comunicacao"
          if (savedCom["comunicacao_others"] != null &&
              savedCom["comunicacao_others"] is List) {
            List<dynamic> outros = savedCom["comunicacao_others"];
            otherChannels = outros.map((item) {
              if (item is Map) {
                return OtherChannelEntry(
                  channel: item["channel"]?.toString(),
                  contact: item["contact"]?.toString(),
                );
              } else {
                return OtherChannelEntry();
              }
            }).toList();
          }
        });
      }
    });
  }

  /// Adiciona um novo campo de contato para uma opção pré-definida
  void adicionarContato(CommunicationOption option) {
    setState(() {
      option.contactControllers.add(TextEditingController());
    });
  }

  /// Adiciona uma nova entrada para "Outros"
  void adicionarOtherChannel() {
    setState(() {
      otherChannels.add(OtherChannelEntry());
    });
  }

  /// Valida os campos: para cada opção marcada deve haver ao menos um contato não vazio;
  /// para cada entrada de "Outros", os dois campos (nome e contato) são obrigatórios.
  bool validarContatos() {
    for (var option in communicationOptions) {
      if (option.selected) {
        if (option.contactControllers.isEmpty ||
            !option.contactControllers.any((c) => c.text.trim().isNotEmpty)) {
          return false;
        }
      }
    }
    for (var entry in otherChannels) {
      if (entry.channelController.text.trim().isEmpty ||
          entry.contactController.text.trim().isEmpty) {
        return false;
      }
    }
    return true;
  }

  void salvarEAvancar() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!validarContatos()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Preencha corretamente os contatos para cada opção e para os 'Outros'."),
          ),
        );
        return;
      }
      Map<String, dynamic> comunicacaoData = {};
      // Para cada opção pré-definida:
      for (var option in communicationOptions) {
        if (option.selected) {
          List<String> contatos = option.contactControllers
              .map((c) => c.text.trim())
              .where((s) => s.isNotEmpty)
              .toList();
          comunicacaoData[option.name] = contatos;
        } else {
          // Se não estiver selecionada, remove o registro do banco.
          comunicacaoData[option.name] = FieldValue.delete();
        }
      }
      // Para os "Outros":
      if (otherChannels.isNotEmpty) {
        List<Map<String, dynamic>> outrosList = otherChannels.map((entry) {
          return {
            "channel": entry.channelController.text.trim(),
            "contact": entry.contactController.text.trim(),
          };
        }).toList();
        comunicacaoData["comunicacao_others"] = outrosList;
      } else {
        comunicacaoData["comunicacao_others"] = FieldValue.delete();
      }
      await salvarRespostas({"comunicacao": comunicacaoData});
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SaneamentoScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100.0),
          child: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
              tooltip: 'Voltar',
            ),
            elevation: 2,
            shadowColor: Colors.blue.shade100,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    // Conteúdo centralizado
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
                                'Gestão de Formulários',
                                style: GoogleFonts.roboto(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                'Comitê',
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
                  ],
                ),
              ),
            ),
          ),
        ),
        /*AppBar(
          title: Text("Meios de Comunicação",
              style: TextStyle(fontWeight: FontWeight.w600)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Voltar',
          ),
          elevation: 2,
        ),*/

        body: Container(
          color: Colors.grey[100],
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(width: 8),
                      Flexible(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Color(0xFF1A237E),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.people_alt,
                                  color: Colors.white, size: 22),
                            ),
                            SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                "Qual a forma mais utilizada de mobilização popular para reuniões e/ou eventos sociais?",
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A237E),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Selecione os canais e informe os contatos correspondentes:",
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 24),

                  // Opções pré-definidas
                  ...communicationOptions.map((option) {
                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      elevation: 1,
                      color: option.selected
                          ? const Color.fromARGB(255, 241, 250, 255)
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                            color: const Color.fromARGB(255, 109, 189, 243)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            CheckboxListTile(
                              title: Text(option.name,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)),
                              value: option.selected,
                              onChanged: (val) {
                                setState(() {
                                  option.selected = val ?? false;
                                  if (option.selected) {
                                    // Se for selecionada e não houver contato, adiciona o primeiro automaticamente.
                                    if (option.contactControllers.isEmpty) {
                                      option.contactControllers
                                          .add(TextEditingController());
                                    }
                                  }
                                });
                              },
                              activeColor: Colors.deepPurple,
                              checkColor: Colors.white,
                              tileColor: Colors.white,
                              dense: true,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            if (option.selected) ...[
                              ...option.contactControllers
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                return _buildContactField(
                                    entry.key, entry.value, option);
                              }),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 16, bottom: 8),
                                child: _AddButton(
                                  onPressed: () => adicionarContato(option),
                                  label:
                                      "Adicionar contato para ${option.name}",
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                  // Seção Outros
                  SizedBox(height: 16),
                  Text(
                    "Canais personalizados",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.deepPurple[800],
                        ),
                  ),
                  SizedBox(height: 12),
                  ...otherChannels.asMap().entries.map((entry) {
                    return _buildOtherChannelField(entry.key, entry.value);
                  }),
                  _AddButton(
                    onPressed: adicionarOtherChannel,
                    label: "Adicionar canal personalizado",
                    icon: Icons.add_circle_outline,
                  ),

                  // Botões de navegação
                  SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 28, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text("Voltar",
                            style: TextStyle(color: Colors.grey[700])),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: salvarEAvancar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: EdgeInsets.symmetric(
                              horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                        child: Text("Continuar",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildContactField(
      int idx, TextEditingController controller, CommunicationOption option) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: "Contato ${idx + 1}",
          hintText: "Digite o ${option.name.toLowerCase()}...",
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          prefixIcon: _getContactIcon(option.name),
          suffixIcon: idx > 0
              ? IconButton(
                  icon: Icon(Icons.remove_circle, color: Colors.red[400]),
                  onPressed: () =>
                      setState(() => option.contactControllers.removeAt(idx)),
                )
              : null,
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        ),
        validator: (value) =>
            value?.trim().isEmpty ?? true ? "Campo obrigatório" : null,
      ),
    );
  }

  Widget _buildOtherChannelField(int idx, OtherChannelEntry other) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: other.channelController,
                decoration: InputDecoration(
                  labelText: "Nome do canal",
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: other.contactController,
                decoration: InputDecoration(
                  labelText: "Contato",
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red[400]),
              onPressed: () => setState(() => otherChannels.removeAt(idx)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData? icon;

  const _AddButton({required this.onPressed, required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.deepPurple,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon ?? Icons.add_link_rounded, size: 20),
          SizedBox(width: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

Icon _getContactIcon(String optionName) {
  switch (optionName.toLowerCase()) {
    case 'whatsapp':
      return Icon(Icons.telegram, color: Colors.green);
    case 'email':
      return Icon(Icons.email, color: Colors.blue);
    case 'sms':
      return Icon(Icons.sms, color: Colors.orange);
    default:
      return Icon(Icons.phone, color: Colors.grey);
  }
}

/// ------------------------------------------------------------
/// Tela 3 – Saneamento (Perguntas de resposta única)
/// ------------------------------------------------------------

class SaneamentoScreen extends StatefulWidget {
  @override
  _SaneamentoScreenState createState() => _SaneamentoScreenState();
}

class _SaneamentoScreenState extends State<SaneamentoScreen> {
  final _formKey = GlobalKey<FormState>();

  List<UniqueQuestion> questions = [
    UniqueQuestion(
      id: "coletaSeletiva",
      question: "O Município realiza coleta seletiva de resíduos?",
      options: ["Sim, realiza a coleta seletiva", "Não possui coleta seletiva"],
    ),
    UniqueQuestion(
      id: "drenagem",
      question: "O Município possui sistema de drenagem de águas pluviais?",
      options: [
        "Sim",
        "Sim, mas precisa de ampliação",
        "Não",
        "Em fase de implementação"
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    carregarRespostas().then((respostas) {
      setState(() {
        for (var question in questions) {
          if (respostas.containsKey(question.id)) {
            question.selected = respostas[question.id] as String?;
          }
        }
      });
    });
  }

  void salvar() async {
    if (_formKey.currentState?.validate() ?? false) {
      Map<String, dynamic> respostas = {};
      for (var question in questions) {
        respostas[question.id] = question.selected;
      }
      await salvarRespostas(respostas);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Respostas salvas com sucesso!")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProdutoA_menu()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color primaryColor = Colors.blue[600]!;
    final Color cardColor = Colors.white;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: AppBar(
          leading: IconButton(
            icon: Icon(Icons.chevron_left_rounded, size: 32),
            onPressed: () => Navigator.pop(context),
          ),
          elevation: 2,
          shadowColor: Colors.blue.shade100,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  // Conteúdo centralizado
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
                              'Gestão de Formulários',
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              'Comitê',
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

                  // Botão de adicionar estilizado
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.grey[100],
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Color(0xFF1A237E),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.people_alt,
                            color: Colors.white, size: 22),
                      ),
                      SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          "Informações sobre o saneamento básico no município",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A237E),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),
                ...questions.map((question) =>
                    _buildQuestionCard(question, cardColor, primaryColor)),
                SizedBox(height: 40),
                _buildActionButtons(primaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(
      UniqueQuestion question, Color cardColor, Color primaryColor) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.question,
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: question.selected,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 16, horizontal: 18),
              ),
              items: question.options
                  .map((option) => DropdownMenuItem(
                        value: option,
                        child: Text(
                          option,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 15,
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => question.selected = value),
              icon: Icon(Icons.expand_more_rounded, color: primaryColor),
              dropdownColor: cardColor,
              borderRadius: BorderRadius.circular(12),
              style: TextStyle(color: Colors.grey[800], fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.grey[700],
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Text("Voltar", style: TextStyle(fontWeight: FontWeight.w500)),
        ),
        SizedBox(width: 16),
        ElevatedButton(
          onPressed: salvar,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 1,
          ),
          child: Text("Salvar Dados",
              style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
