import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/auth_controller.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Controllers para TODOS os campos
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _telController = TextEditingController();
  final TextEditingController _estadoController = TextEditingController();
  final TextEditingController _municipioController = TextEditingController();
  final TextEditingController _cargoController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();

  final TextEditingController _nivelContaController = TextEditingController();

  late int _selectedNivelConta = 1;

  final List<int> _opcoesNivel = [1, 2, 3, 4];

  final AuthController _authController = AuthController();

  bool _isLogin = true;

  //(FirebaseAuth.instance.currentUser != null);
  bool _passwordVisible = false;

  void _toggleFormType() {
    setState(() {
      _isLogin = !_isLogin;
      _formKey.currentState?.reset();
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      try {
        UserCredential userCredential;
        // Se for Login, chamamos handleSignIn com email/senha.
        // Se for Registro, chamamos handleSignUp com todos os campos.
        if (_isLogin) {
          userCredential = await _authController.handleSignIn(
            _emailController.text,
            _passController.text,
          );
        } else {
          userCredential = await _authController.handleSignUp(
            name: _nameController.text,
            email: _emailController.text,
            tel: _telController.text,
            password: _passController.text,
            municipio: _municipioController.text,
            estado: _estadoController.text,
            cargo: _cargoController.text,
            cpf: _cpfController.text,
            nivelConta: _selectedNivelConta, // Agora seguro
          );
        }

        // Após login ou registro, navegue para a HomeScreen
        if (_isLogin) {
          context.go('/home'); // Use o caminho da sua tela inicial
        } else {
          print(
              "Conta atual: ${userCredential.user?.displayName} - ${userCredential.user?.email}");
          Navigator.of(context).pop();
        }
      } on FirebaseAuthException catch (e) {
        final errorMessage = _getErrorMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Erro:  $errorMessage"),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
        return 'Credencial inválida. Por favor, tente novamente.';
      case 'user-disabled':
        return 'Este usuário foi desabilitado.';
      case 'user-not-found':
        return 'Usuário não encontrado. Verifique seu email.';
      case 'wrong-password':
        return 'Senha incorreta. Tente novamente.';
      case 'email-already-in-use':
        return 'Este email já está sendo usado por outra conta.';
      case 'operation-not-allowed':
        return 'Operação não permitida. Entre em contato com o suporte.';
      case 'weak-password':
        return 'Senha fraca. Por favor, escolha uma senha mais forte.';
      // Você pode adicionar mais casos conforme necessário.
      default:
        return 'Ocorreu um erro inesperado. Tente novamente mais tarde.';
    }
  }

  final String numeroWhatsapp =
      "https://wa.me/5587981385942"; // Substitua com o número correto

  Future<void> _abrirWhatsapp() async {
    if (await canLaunchUrl(Uri.parse(numeroWhatsapp))) {
      await launchUrl(Uri.parse(numeroWhatsapp));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Erro: Nao foi possível abrir o WhatsApp"),
        backgroundColor: Colors.red,
      ));
    }
  }

  bool _isLoading = false;
  AnimationController? _buttonController;
  AnimationController? _borderAnimationController;

// Inicialize os controladores no initState
  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _borderAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _buttonController?.dispose();
    _borderAnimationController?.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF00B3CC),
                  Color(0xFF004466),
                ],
                stops: [0.2, 0.8],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: AnimatedBuilder(
                        animation: _borderAnimationController!,
                        builder: (context, child) {
                          return Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: SweepGradient(
                                colors: [
                                  const Color(0xFF00B3CC).withOpacity(0.5),
                                  Colors.white.withOpacity(0.2),
                                  const Color(0xFF004466).withOpacity(0.5),
                                ],
                                stops: const [0.2, 0.5, 0.8],
                                transform: GradientRotation(
                                  _borderAnimationController!.value * 6.2832,
                                ),
                              ),
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.97),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 25,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: child,
                            ),
                          );
                        },
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 400),
                                child: _isLogin
                                    ? Hero(
                                        tag: 'logo',
                                        child: Image.asset(
                                            'assets/redeplanrmbg.png',
                                            height: 250),
                                      )
                                    : Transform.rotate(
                                        angle: 0.02,
                                        child: Hero(
                                          tag: 'logo',
                                          child: Image.asset(
                                              'assets/redeplanrmbg.png',
                                              height: 250),
                                        ),
                                      ),
                              ),

                              if (!_isLogin) ...[
                                _buildTextField(
                                  controller: _nameController,
                                  label: "Nome",
                                  icon: Icons.person_outline,
                                  iconColor: const Color(0xFF00B3CC),
                                  validator: (value) =>
                                      value!.isEmpty ? "Insira seu nome" : null,
                                ),
                                const SizedBox(height: 15),
                              ],
                              // Campo de Email
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(color: Colors.grey[800]),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelText: "Email",
                                  labelStyle: TextStyle(
                                      color: Colors.grey[600], fontSize: 15),
                                  prefixIcon: Icon(Icons.email_outlined,
                                      color: const Color(0xFF00B3CC)),
                                  border: _inputBorder(),
                                  enabledBorder: _inputBorder(),
                                  focusedBorder: _inputBorder(
                                      color: const Color(0xFF00B3CC), width: 2),
                                ),
                                validator: (value) => value!.contains('@')
                                    ? null
                                    : "Email inválido",
                              ),
                              const SizedBox(height: 15),
                              // Campo de Senha
                              TextFormField(
                                controller: _passController,
                                obscureText: !_passwordVisible,
                                style: TextStyle(color: Colors.grey[800]),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelText: "Senha",
                                  labelStyle: TextStyle(
                                      color: Colors.grey[600], fontSize: 15),
                                  prefixIcon: Icon(Icons.lock_outline,
                                      color: const Color(0xFF00B3CC)),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _passwordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.grey[600],
                                    ),
                                    onPressed: () => setState(() =>
                                        _passwordVisible = !_passwordVisible),
                                  ),
                                  border: _inputBorder(),
                                  enabledBorder: _inputBorder(),
                                  focusedBorder: _inputBorder(
                                      color: const Color(0xFF00B3CC), width: 2),
                                ),
                              ),
                              const SizedBox(height: 30),
                              // Botão Principal
                              ScaleTransition(
                                scale: Tween(begin: 1.0, end: 0.95).animate(
                                  CurvedAnimation(
                                    parent: _buttonController!,
                                    curve: Curves.easeOut,
                                  ),
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  height: 52,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      colors: [
                                        _isLoading
                                            ? const Color(0xFF007799)
                                            : const Color(0xFF00B3CC),
                                        const Color(0xFF007799)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: _isLoading
                                        ? []
                                        : [
                                            BoxShadow(
                                              color: const Color(0xFF00B3CC)
                                                  .withOpacity(0.3),
                                              blurRadius: 12,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: _isLoading
                                        ? null
                                        : () {
                                            _buttonController!.forward().then(
                                                (_) => _buttonController!
                                                    .reverse());
                                            _submit();
                                          },
                                    child: AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            )
                                          : Text(
                                              _isLogin
                                                  ? "ACESSAR PLATAFORMA"
                                                  : "CRIAR CONTA AGORA",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.8,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Link de Ajuda
                              TextButton(
                                onPressed: _abrirWhatsapp,
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF004466),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      color: const Color(0xFF004466),
                                      fontSize: 13,
                                    ),
                                    children: [
                                      const TextSpan(
                                          text: "Esqueceu a senha? "),
                                      const TextSpan(
                                        text: "fale conosco",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
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
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color.fromARGB(138, 255, 255, 255),
                  ),
                  child: Image.asset(
                    'assets/barradelogo.png',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// Função auxiliar para bordas dos inputs
  InputBorder _inputBorder({Color color = Colors.grey, double width = 1.5}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: color.withOpacity(0.4),
        width: width,
      ),
    );
  }

// Widget reutilizável para campos de texto
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color iconColor,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.grey[800]),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 15),
        prefixIcon: Icon(icon, color: iconColor),
        border: _inputBorder(),
        enabledBorder: _inputBorder(),
        focusedBorder: _inputBorder(color: iconColor),
      ),
      validator: validator,
    );
  }
}

class AdminCreateAccountScreen extends StatefulWidget {
  const AdminCreateAccountScreen({super.key});

  @override
  State<AdminCreateAccountScreen> createState() =>
      _AdminCreateAccountScreenState();
}

class _AdminCreateAccountScreenState extends State<AdminCreateAccountScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthController _authController = AuthController();

  // Todos os controllers necessários
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _telController = TextEditingController();
  final TextEditingController _municipioController = TextEditingController();
  final TextEditingController _estadoController = TextEditingController();
  final TextEditingController _cargoController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();

  // Listas para os Dropdowns
  final List<String> _estados = ["Rio de Janeiro", "Pernambuco", "Bahia"];
  final Map<String, List<String>> _municipios = {
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
      "Petrolina",
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

  // Variáveis para armazenar as seleções
  String? _selectedEstado;
  String? _selectedMunicipio;

  int _selectedNivelConta = 2;
  final List<int> _opcoesNivel = [0, 1, 2, 3, 4]; // Níveis administrativos
  bool _passwordVisible = false;

  Future<void> _submit() async {
    // Retorna imediatamente se o formulário não for válido
    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      await _authController.handleSignUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        tel: _telController.text.trim(),
        password: _passController.text,
        municipio: _selectedMunicipio ?? '',
        estado: _selectedEstado ?? '',
        cargo: _cargoController.text.trim(),
        cpf: _cpfController.text.trim(),
        nivelConta: _selectedNivelConta,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conta administrativa criada com sucesso!'),
        ),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      // Tratamento apenas dos erros mais relevantes para cadastro
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Senha muito fraca';
          break;
        case 'email-already-in-use':
          errorMessage = 'Email já está em uso';
          break;
        case 'invalid-email':
          errorMessage = 'Email inválido';
          break;
        default:
          errorMessage = 'Erro: ${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color.fromARGB(255, 0, 75, 136); // Nova cor primária
    const gradientColor = LinearGradient(
      colors: [Colors.blueAccent, Colors.blue],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: AppBar(
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
                              'Sistema de',
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Criação de contas',
                              style: GoogleFonts.roboto(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: const Color.fromARGB(255, 230, 242, 255),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Campo Nome
              _buildInputField(
                controller: _nameController,
                label: 'Nome Completo',
                hint: 'João da Silva',
                icon: Icons.person_outline,
                primaryColor: primaryColor,
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 28),

              // Campo Email
              _buildInputField(
                controller: _emailController,
                label: 'Email',
                hint: 'exemplo@dominio.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                primaryColor: primaryColor,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Email obrigatório';
                  if (!value.contains('@')) return 'Email inválido';
                  return null;
                },
              ),
              const SizedBox(height: 28),

              // Campo Senha
              TextFormField(
                controller: _passController,
                obscureText: !_passwordVisible,
                style: TextStyle(color: primaryColor),
                decoration: InputDecoration(
                  labelText: 'Senha',
                  labelStyle: TextStyle(color: primaryColor),
                  hintText: 'Mínimo 6 caracteres',
                  hintStyle: TextStyle(color: Colors.blueGrey[300]),
                  border: _inputBorder(primaryColor),
                  enabledBorder: _inputBorder(primaryColor.withOpacity(0.5)),
                  focusedBorder: _inputBorder(primaryColor),
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: primaryColor.withOpacity(0.7),
                    ),
                    onPressed: () =>
                        setState(() => _passwordVisible = !_passwordVisible),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Senha obrigatória';
                  if (value.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 28),

              // Dropdown Estado
              _buildDropdown(
                value: _selectedEstado,
                label: 'Estado',
                icon: Icons.place_outlined,
                items: _estados,
                onChanged: (value) => setState(() {
                  _selectedEstado = value;
                  _selectedMunicipio = null;
                }),
                primaryColor: primaryColor,
              ),
              const SizedBox(height: 28),

              // Dropdown Município
              _buildDropdown(
                value: _selectedMunicipio,
                label: 'Município',
                icon: Icons.location_city_outlined,
                items: _selectedEstado == null
                    ? []
                    : _municipios[_selectedEstado]!,
                onChanged: (value) =>
                    setState(() => _selectedMunicipio = value),
                primaryColor: primaryColor,
              ),
              const SizedBox(height: 28),

              // Campo Cargo
              _buildInputField(
                controller: _cargoController,
                label: 'Cargo',
                hint: 'Gerente Regional',
                icon: Icons.work_outline,
                primaryColor: primaryColor,
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 28),

              // Campo CPF
              _buildInputField(
                controller: _cpfController,
                label: 'CPF',
                hint: '000.000.000-00',
                icon: Icons.badge_outlined,
                primaryColor: primaryColor,
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 28),

              // Campo Telefone
              IntlPhoneField(
                decoration: InputDecoration(
                  labelText: 'Telefone',
                  labelStyle: TextStyle(color: primaryColor),
                  border: _inputBorder(primaryColor),
                  enabledBorder: _inputBorder(primaryColor.withOpacity(0.5)),
                  focusedBorder: _inputBorder(primaryColor),
                  filled: true,
                  fillColor: Colors.blue.shade50,
                ),
                initialCountryCode: 'BR',
                style: TextStyle(color: primaryColor),
                dropdownIcon: Icon(Icons.arrow_drop_down, color: primaryColor),
                onChanged: (phone) =>
                    _telController.text = phone.completeNumber,
              ),
              const SizedBox(height: 28),

              // Dropdown Nível Acesso
              _buildDropdown<int>(
                value: _selectedNivelConta,
                label: 'Nível de Acesso',
                icon: Icons.admin_panel_settings_outlined,
                items: _opcoesNivel,
                onChanged: (value) =>
                    setState(() => _selectedNivelConta = value!),
                primaryColor: primaryColor,
                displayItem: (value) => _getNivelDescricao(value),
              ),
              const SizedBox(height: 36),

              // Botão de Submissão
              Container(
                decoration: BoxDecoration(
                  gradient: gradientColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 3, 61, 108)
                          .withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: const Color.fromARGB(251, 70, 103, 222),
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _submit,
                  child: const Text('CRIAR CONTA ADMINISTRATIVA',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Métodos auxiliares para reutilização
  InputBorder _inputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color, width: 1.5),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color primaryColor,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: primaryColor),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: primaryColor),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.blueGrey[300]),
        border: _inputBorder(primaryColor),
        enabledBorder: _inputBorder(primaryColor.withOpacity(0.5)),
        focusedBorder: _inputBorder(primaryColor),
        filled: true,
        fillColor: Colors.blue.shade50,
        prefixIcon: Icon(icon, color: primaryColor),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String label,
    required IconData icon,
    required List<T> items,
    required Function(T?) onChanged,
    required Color primaryColor,
    String Function(T)? displayItem,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: primaryColor),
        border: _inputBorder(primaryColor),
        enabledBorder: _inputBorder(primaryColor.withOpacity(0.5)),
        focusedBorder: _inputBorder(primaryColor),
        filled: true,
        fillColor: Colors.blue.shade50,
        prefixIcon: Icon(icon, color: primaryColor),
      ),
      dropdownColor: Colors.blue.shade50,
      icon: Icon(Icons.arrow_drop_down_circle_outlined, color: primaryColor),
      style: TextStyle(color: primaryColor),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            displayItem != null ? displayItem(item) : item.toString(),
            style: TextStyle(fontSize: 15),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Campo obrigatório' : null,
    );
  }

  String _getNivelDescricao(int nivel) {
    switch (nivel) {
      case 0:
        return 'Visualizador Administrativo';
      case 1:
        return 'Adminstrador Plansanear';
      case 2:
        return 'Gestor 1';
      case 3:
        return 'Gestor 2';
      case 4:
        return 'Gestor 3';
      default:
        return '';
    }
  }
}
