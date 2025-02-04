import 'package:Plansanear/produtos/produto_a/models/formacao_comite_model.dart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/formacao_comite_controller.dart';

import 'package:uuid/uuid.dart';

class FormacaoComiteForm extends StatefulWidget {
  @override
  _FormacaoComiteFormState createState() => _FormacaoComiteFormState();
}

class _FormacaoComiteFormState extends State<FormacaoComiteForm> {
  final _controller = FormacaoComiteController();
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _profissaoController = TextEditingController();
  final _funcaoController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();

  String _cargoSelecionado = "Coordenador";
  String? _formId;
  Map<String, String> _statusCargos = {};
  bool _carregandoStatus = true; // Estado para exibir animação de carregamento

  @override
  void initState() {
    super.initState();
    _carregarStatusCargos();
  }

  // Função que busca os status dos cargos
  void _carregarStatusCargos() async {
    setState(() {
      _carregandoStatus = true; // Inicia o carregamento
    });

    List<String> cargos = [
      "Coordenador",
      "Suplente Coordenador",
      "Engenheiro",
      "Suplente Engenheiro",
      "Profissional Ciências Sociais",
      "Suplente Profissional Ciências Sociais",
      "Estagiário Engenharia",
      "Suplente Estagiário Engenharia",
      "Téc. Informática",
      "Suplente Téc. Informática",
      "Secretário Comitê Executivo",
      "Suplente Secretário Comitê Executivo",
      "Téc. Municipal Saneamento",
      "Suplente Téc. Municipal Saneamento",
      "Representante Téc. Prestador Serviço",
      "Conselheiro Municipal",
      "Suplente Conselheiro Municipal",
      "Profissional Órgão Adm",
      "Suplente Profissional Órgão Adm"
    ];

    Map<String, String> status = {};
    for (var cargo in cargos) {
      status[cargo] = await _controller.verificarStatusCargo(cargo);
    }

    setState(() {
      _statusCargos = status;
      _carregandoStatus = false; // Finaliza o carregamento
    });
  }

  void _carregarDadosDoFormulario() async {
    setState(() {
      _formId = null;
      _nomeController.clear();
      _cpfController.clear();
      _profissaoController.clear();
      _funcaoController.clear();
      _telefoneController.clear();
      _emailController.clear();
    });

    FormacaoComiteProdutoA? form =
        await _controller.buscarFormularioPorCargo(_cargoSelecionado);
    if (form != null) {
      setState(() {
        _formId = form.formId;
        _nomeController.text = form.nomeCompleto;
        _cpfController.text = form.cpf;
        _profissaoController.text = form.profissao;
        _funcaoController.text = form.funcao;
        _telefoneController.text = form.telefone;
        _emailController.text = form.email;
      });
    }
  }

  IconData _iconeStatus(String status) {
    switch (status) {
      case "completo":
        return Icons.check_circle;
      case "parcial":
        return Icons.warning;
      default:
        return Icons.circle;
    }
  }

  Color _corStatus(String status) {
    switch (status) {
      case "completo":
        return Colors.green;
      case "parcial":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _salvarFormulario() async {
    if (_formKey.currentState!.validate()) {
      if (_nomeController.text.isEmpty ||
          _cpfController.text.isEmpty ||
          _profissaoController.text.isEmpty ||
          _funcaoController.text.isEmpty ||
          _telefoneController.text.isEmpty ||
          _emailController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Preencha todos os campos antes de salvar!"),
          backgroundColor: Colors.red,
        ));
        return;
      }

      String? userId = _controller.getUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Erro: Usuário não autenticado!"),
          backgroundColor: Colors.red,
        ));
        return;
      }

      final form = FormacaoComiteProdutoA(
        formId: _formId ?? Uuid().v4(),
        preenchidoPor: userId,
        nomeCompleto: _nomeController.text,
        cpf: _cpfController.text,
        profissao: _profissaoController.text,
        funcao: _funcaoController.text,
        telefone: _telefoneController.text,
        email: _emailController.text,
        cargo: _cargoSelecionado,
      );

      await _controller.salvarOuAtualizarFormulario(form);
      _carregarStatusCargos(); // Atualiza os status no dropdown

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Formulário salvo com sucesso!"),
        backgroundColor: Colors.green,
      ));
    }
  }

  final Map<String, String> _descricoesCargos = {
    "Coordenador": "Engenheiro (Ambiental, Civil ou Sanitarista)",
    "Suplente Coordenador":
        "Suplente - Engenheiro (Ambiental, Civil ou Sanitarista)",
    "Engenheiro":
        "Profissional com formação em Ciências Sociais e Humanas (Direito, História, Geografia, Ciências Sociais, Psicologia) com destaque para Sociólogo, Pedagogo e Assistente Social",
    "Suplente Engenheiro":
        "Suplente - Profissional com formação em Ciências Sociais e Humanas (Direito, História, Geografia, Ciências Sociais, Psicologia) com destaque para Sociólogo, Pedagogo e Assistente Social",
    "Profissional Ciências Sociais":
        "Estagiário em Sociologia, Pedagogia ou Ciências Humanas (Direito, História, Geografia, Psicologia, Ciências Sociais)",
    "Suplente Profissional Ciências Sociais":
        "Suplente - Estagiário em Sociologia, Pedagogia ou Ciências Humanas (Direito, História, Geografia, Psicologia, Ciências Sociais)",
    "Estagiário Engenharia":
        "Estagiário em Engenharia Ambiental, Civil ou Sanitária",
    "Suplente Estagiário Engenharia":
        "Suplente - Estagiário em Engenharia Ambiental, Civil ou Sanitária",
    "Téc. Informática": "Técnico em Informática",
    "Suplente Téc. Informática": "Suplente - Técnico em Informática",
    "Secretário Comitê Executivo": "Secretário(a) do Comitê Executivo",
    "Suplente Secretário Comitê Executivo":
        "Suplente - Secretário(a) do Comitê Executivo",
    "Téc. Municipal Saneamento":
        "Técnicos que atuam como profissionais dos órgãos e entidades municipais da área de saneamento básico e secretarias afins, preferencialmente servidores efetivos (Obras, Serviços Públicos, Urbanismo, Saúde, Planejamento, Desenvolvimento Econômico, Meio Ambiente, Assistência Social, Educação, entre outras da Prefeitura Municipal)",
    "Suplente Téc. Municipal Saneamento":
        "Suplente - Técnicos que atuam como profissionais dos órgãos e entidades municipais da área de saneamento básico e secretarias afins, preferencialmente servidores efetivos (Obras, Serviços Públicos, Urbanismo, Saúde, Planejamento, Desenvolvimento Econômico, Meio Ambiente, Assistência Social, Educação, entre outras da Prefeitura Municipal)",
    "Representante Téc. Prestador Serviço":
        "Representantes técnicos dos prestadores de serviços (autarquias municipais, concessionárias estaduais, operadores privados, entre outros, que prestam o serviço de manejo de resíduos sólidos, abastecimento de água, esgotamento sanitário, e drenagem e manejo de águas pluviais). Ex: COMPESA, SAAE, EMBASA, CEDAE",
    "Conselheiro Municipal":
        "Conselheiros Municipais que representam a sociedade civil nos Conselhos de Políticas Públicas (de Saúde, de Meio Ambiente, de Habitação, de Assistência Social, de Educação, de Habitação de Interesse Social, entre outros)",
    "Suplente Conselheiro Municipal":
        "Suplente - Conselheiros Municipais que representam a sociedade civil nos Conselhos de Políticas Públicas (de Saúde, de Meio Ambiente, de Habitação, de Assistência Social, de Educação, de Habitação de Interesse Social, entre outros)",
    "Profissional Órgão Adm":
        "Profissionais disponibilizados por órgãos da administração direta e indireta de outros entes da federação (Federal ou Estadual). Ex: MP; CODEVASF; TCU; FUNAI; IBGE; EMATER; CORREIOS; COMPESA; EMBASA; EMBRAPA; INEMA.",
    "Suplente Profissional Órgão Adm":
        "Suplente - Profissionais disponibilizados por órgãos da administração direta e indireta de outros entes da federação (Federal ou Estadual). Ex: MP; CODEVASF; TCU; FUNAI; IBGE; EMATER; CORREIOS; COMPESA; EMBASA; EMBRAPA; INEMA.",
  };

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
                          'assets/logo_plan.png',
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
                        'Cadastro do',
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
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dropdown estilizado no topo
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: _carregandoStatus
                    ? LinearProgressIndicator()
                    : DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _cargoSelecionado,
                          icon: Icon(Icons.arrow_drop_down,
                              color: Colors.blue[800]),
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          items: _statusCargos.keys.map((cargo) {
                            String status =
                                _statusCargos[cargo] ?? "não preenchido";
                            return DropdownMenuItem(
                              value: cargo,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  children: [
                                    Icon(_iconeStatus(status),
                                        color: _corStatus(status), size: 20),
                                    SizedBox(width: 12),
                                    Expanded(child: Text(cargo)),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _cargoSelecionado = value!;
                              _carregarDadosDoFormulario();
                            });
                          },
                        ),
                      ),
              ),

              SizedBox(height: 30),

              _carregandoStatus
                  ? SizedBox.shrink() // Mantém o espaço vazio enquanto carrega
                  : Column(
                      children: [
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                                color: Colors.blue.shade100, width: 1),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.info_outline,
                                        color: Colors.blue[800], size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      "Descrição do Cargo",
                                      style: GoogleFonts.roboto(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue[800],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text(
                                  _descricoesCargos[_cargoSelecionado] ??
                                      'Descrição não disponível',
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 25),
                      ],
                    ),

              // Campos do formulário
              _buildTextField(_nomeController, "Nome Completo", Icons.person),
              _buildTextField(_cpfController, "CPF", Icons.credit_card,
                  keyboardType: TextInputType.number),
              _buildTextField(_profissaoController, "Profissão", Icons.work),
              _buildTextField(_funcaoController, "Função", Icons.badge),
              _buildTextField(_telefoneController, "Telefone", Icons.phone,
                  keyboardType: TextInputType.phone),
              _buildTextField(_emailController, "Email", Icons.email,
                  keyboardType: TextInputType.emailAddress),

              SizedBox(height: 25),

              // Botão de Salvar
              Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[700]!, Colors.blue[900]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: _salvarFormulario,
                  child: Text(
                    "SALVAR FORMULÁRIO",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue[800]),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blue[800]!, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          labelStyle: TextStyle(color: Colors.grey[600]),
        ),
        style: TextStyle(color: Colors.blue[900], fontSize: 16),
      ),
    );
  }
}
