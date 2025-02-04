import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
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
      "https://wa.me/5587998114541"; // Substitua com o número correto

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
      body: Container(
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
        child: Center(
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
                                child: Image.asset('assets/ze_planinho2.png',
                                    height: 150),
                              )
                            : Transform.rotate(
                                angle: 0.02,
                                child: Hero(
                                  tag: 'logo',
                                  child: Image.asset('assets/ze_planinho2.png',
                                      height: 150),
                                ),
                              ),
                      ),
                      const SizedBox(height: 30),
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
                          labelStyle:
                              TextStyle(color: Colors.grey[600], fontSize: 15),
                          prefixIcon: Icon(Icons.email_outlined,
                              color: const Color(0xFF00B3CC)),
                          border: _inputBorder(),
                          enabledBorder: _inputBorder(),
                          focusedBorder: _inputBorder(
                              color: const Color(0xFF00B3CC), width: 2),
                        ),
                        validator: (value) =>
                            value!.contains('@') ? null : "Email inválido",
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
                          labelStyle:
                              TextStyle(color: Colors.grey[600], fontSize: 15),
                          prefixIcon: Icon(Icons.lock_outline,
                              color: const Color(0xFF00B3CC)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey[600],
                            ),
                            onPressed: () => setState(
                                () => _passwordVisible = !_passwordVisible),
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
                                        (_) => _buttonController!.reverse());
                                    _submit();
                                  },
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
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
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: const Color(0xFF004466),
                              fontSize: 13,
                            ),
                            children: const [
                              TextSpan(text: "Esqueceu a senha? "),
                              TextSpan(
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

  int _selectedNivelConta = 3;
  final List<int> _opcoesNivel = [1, 2, 3]; // Níveis administrativos
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
        municipio: _municipioController.text.trim(),
        estado: _estadoController.text.trim(),
        cargo: _cargoController.text.trim(),
        cpf: _cpfController.text.trim(),
        nivelConta: _selectedNivelConta,
        // Removido currentUser por não ser necessário no cadastro
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta Administrativa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um email';
                  }
                  if (!value.contains('@')) {
                    return 'Email inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passController,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_passwordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira uma senha';
                  }
                  if (value.length < 6) {
                    return 'Senha deve ter pelo menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _municipioController,
                decoration: const InputDecoration(
                  labelText: 'Município',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _estadoController,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city_rounded),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _cargoController,
                decoration: const InputDecoration(
                  labelText: 'Cargo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _cpfController,
                decoration: const InputDecoration(
                  labelText: 'CPF',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.credit_card),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  // Adicione validação de CPF aqui se necessário
                  return null;
                },
              ),
              const SizedBox(height: 20),
              IntlPhoneField(
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  border: OutlineInputBorder(),
                ),
                initialCountryCode: 'BR',
                onChanged: (phone) {
                  _telController.text = phone.completeNumber;
                },
                validator: (value) =>
                    value == null ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                value: _selectedNivelConta,
                decoration: const InputDecoration(
                  labelText: 'Nível de Acesso',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.security),
                ),
                items: _opcoesNivel
                    .map((level) => DropdownMenuItem(
                          value: level,
                          child:
                              Text('Nível $level ${_getNivelDescricao(level)}'),
                        ))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedNivelConta = value!),
                validator: (value) =>
                    value == null ? 'Selecione um nível' : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                onPressed: _submit,
                child: const Text('Criar Conta Administrativa'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getNivelDescricao(int nivel) {
    switch (nivel) {
      case 1:
        return '(Adminstrador Plansanear)';
      case 2:
        return '(Gestor 1)';
      case 3:
        return '(Gestor 2)';
      default:
        return '';
    }
  }
}
