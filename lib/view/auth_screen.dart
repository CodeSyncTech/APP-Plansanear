import 'package:Plansanear/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:url_launcher/url_launcher.dart';
import '../view/home.dart';
import '../controller/auth_controller.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Controllers para TODOS os campos
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _telController = TextEditingController();
  final TextEditingController _municipioController = TextEditingController();
  final TextEditingController _cargoController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();

  final TextEditingController _nivelContaController = TextEditingController();

  late int _selectedNivelConta = 1;
  final List<int> _opcoesNivel = [1, 2, 3, 4];

  final AuthController _authController = AuthController();

  bool _isLogin = true;
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
            cargo: _cargoController.text,
            cpf: _cpfController.text,
            nivelConta: _selectedNivelConta, // Agora seguro
          );
        }

        // Após login ou registro, navegue para a HomeScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => BottomNavBar(),
          ),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Erro: ${e.message}"),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  final String numeroWhatsapp =
      "https://wa.me/5587998114541"; // Substitua com o número correto

  Future<void> _abrirWhatsapp() async {
    if (await canLaunchUrl(Uri.parse(numeroWhatsapp))) {
      await launchUrl(Uri.parse(numeroWhatsapp));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Erro: Nao foi poss vel abrir o WhatsApp"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Para exemplificar, você pode colocar imagens diferentes
                  // dependendo se é login ou registro

                  _isLogin
                      ? Image.asset('assets/ze_planinho2.png', height: 150)
                      : Image.asset('assets/ze_planinho2.png', height: 150),

                  const SizedBox(height: 20),

                  /// Caso seja registro, exibimos os campos adicionais
                  if (!_isLogin) ...[
                    // Campo para nome
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Nome",
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Por favor, insira seu nome";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Campo para município
                    TextFormField(
                      controller: _municipioController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Município",
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Por favor, insira seu município";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Campo para cargo
                    TextFormField(
                      controller: _cargoController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Cargo",
                        prefixIcon: Icon(Icons.work),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Por favor, insira seu cargo";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Campo para CPF
                    TextFormField(
                      controller: _cpfController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "CPF",
                        prefixIcon: Icon(Icons.account_box),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Por favor, insira seu CPF";
                        }
                        // Aqui você pode colocar validação de CPF, se desejar
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Campo para nível da conta
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Nível da Conta",
                        prefixIcon: Icon(Icons.stars),
                      ),
                      value: _selectedNivelConta, // valor inicial
                      items: _opcoesNivel.map((int valor) {
                        return DropdownMenuItem<int>(
                          value: valor,
                          child: Text(valor.toString()),
                        );
                      }).toList(),
                      onChanged: (novoValor) {
                        setState(() {
                          _selectedNivelConta = novoValor!;
                          print("$_selectedNivelConta");
                        });
                      },
                      // Validação (opcional):
                      validator: (valor) {
                        if (valor == null) {
                          return "Por favor, selecione o nível da conta";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),
                    IntlPhoneField(
                      decoration: const InputDecoration(
                        labelText: 'Telefone',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(),
                        ),
                      ),
                      initialCountryCode: 'BR',
                      onChanged: (phone) {
                        _telController.text = phone.completeNumber;
                      },
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Campo para telefone (IntlPhoneField)

                  // Campo para email (sempre exibido, seja login ou registro)
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Por favor, insira seu email";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Campo para senha (sempre exibido, seja login ou registro)
                  TextFormField(
                    controller: _passController,
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: "Senha",
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Por favor, insira sua senha";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // Botão de enviar (Login ou Registrar)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.deepPurple,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: _submit,
                    child: Text(_isLogin ? "Login" : "Registrar"),
                  ),

                  const SizedBox(height: 20),

                  // Botão de trocar o formulário
                  TextButton(
                    onPressed: _abrirWhatsapp,
                    child: Text(
                      "Problemas para conectar? Fale conosco",
                      style: const TextStyle(color: Colors.deepPurple),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
