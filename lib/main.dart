import 'package:Redeplansanea/formularios/presenca/forms_page.dart';
import 'package:Redeplansanea/produtos/produto_a/views/formacao_comite_form.dart';
import 'package:Redeplansanea/router.dart';
import 'package:Redeplansanea/view/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MyApp());
  } catch (e) {
    print("Erro ao inicializar Firebase: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  User? get _currentUser => FirebaseAuth.instance.currentUser;
  int _page = 1;
  // Se quiser, deixe sem nada aqui e adicione 'late'
  late List<Widget> _pages;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // Aqui já é seguro acessar métodos de instância
    _pages = [
      ListPage(),
      // AdminScreen(),

      const Produtos(),
      HomeScreen(_currentUser), // Agora funciona
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF00B3CC), // Azul ciano mais claro
              Color(0xFF004466), // Azul profundo mais escuro
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 40),
              child: AppBar(
                toolbarHeight: 50,
                flexibleSpace: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/logo_plan.png',
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _page == 0
                            ? 'FORMULÁRIOS'
                            : _page == 1
                                ? 'MENU'
                                : 'PERFIL',
                        style: const TextStyle(
                          fontSize: 44,
                          color: Color(0xFFD2E48E),
                          shadows: [
                            Shadow(
                              color: Color(0xFF004466),
                              offset: Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            ),
            Expanded(
              child: _pages[_page],
            ),
          ],
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: 1,
        items: const <Widget>[
          Icon(Icons.list, size: 30),
          Icon(Icons.house, size: 30),
          Icon(Icons.supervised_user_circle_sharp, size: 30),
        ],
        color: const Color(0xFFFFFFFF),
        buttonBackgroundColor: Colors.blueAccent,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
        onTap: (index) {
          setState(() {
            _page = index;
          });
        },
        letIndexChange: (index) => true,
      ),
    );
  }
}

class Produtos extends StatelessWidget {
  const Produtos({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Produto A: Vai para a tela Saneamento
          buildAnimatedCard(
            context,
            title: 'Produto A',
            subtitle: 'Atividades iniciais para a elaboração do PMSB',
            imagePath: 'assets/capaProdutos/produtoA.png',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FormacaoComiteForm()),
              );
            },
          ),
          // Produto B: Vai para a tela Esgoto
          buildAnimatedCard(
            context,
            title: 'Produto B',
            subtitle: 'Estratégia de Mobilização, Participação e Comunicação',
            imagePath: 'assets/capaProdutos/produtoB.png',
            onTap: () {
              showErrorToast(
                context,
                'Aguarde!',
                'Por favor, aguarde, o produto B ainda está em desenvolvimento!',
              );
            },
          ),
          // Produto C: Apenas como exemplo, sem navegação específica
          buildAnimatedCard(
            context,
            title: 'Produto C',
            subtitle: 'Diagnóstico Técnico-Participativo',
            imagePath: 'assets/capaProdutos/produtoC.png',
            onTap: () {
              showErrorToast(
                context,
                'Aguarde!',
                'Por favor, aguarde, o produto C ainda está em desenvolvimento!',
              );
            },
          ),
          buildAnimatedCard(
            context,
            title: 'Produto D',
            subtitle: 'Prognóstico',
            imagePath: 'assets/capaProdutos/produtoD.png',
            onTap: () {
              showErrorToast(
                context,
                'Aguarde!',
                'Por favor, aguarde, o produto D ainda está em desenvolvimento!',
              );
            },
          ),
          buildAnimatedCard(
            context,
            title: 'Produto E',
            subtitle: 'Programas, Projetos e Ações',
            imagePath: 'assets/capaProdutos/produtoE.png',
            onTap: () {
              showErrorToast(
                context,
                'Aguarde!',
                'Por favor, aguarde, o produto E ainda está em desenvolvimento!',
              );
            },
          ),
          buildAnimatedCard(
            context,
            title: 'Produto F',
            subtitle: 'Indicadores de Desempenho',
            imagePath: 'assets/capaProdutos/produtoF.png',
            onTap: () {
              showErrorToast(
                context,
                'Aguarde!',
                'Por favor, aguarde, o produto E ainda está em desenvolvimento!',
              );
            },
          ),

          buildAnimatedCard(
            context,
            title: 'Produto G',
            subtitle: 'Resumo Executivo e Minuta de Lei',
            imagePath: 'assets/capaProdutos/produtoG.png',
            onTap: () {
              showErrorToast(
                context,
                'Aguarde!',
                'Por favor, aguarde, o produto G ainda está em desenvolvimento!',
              );
            },
          ),
          SizedBox(height: 100),
        ],
      ),
    );
  }
}

void showErrorToast(BuildContext context, String title, String message) {
  toastification.show(
    context: context,
    type: ToastificationType.error,
    style: ToastificationStyle.flat,
    autoCloseDuration: const Duration(seconds: 5),
    title: Text(title),
    description: Text(message),
    alignment: Alignment.bottomCenter,
    direction: TextDirection.ltr,
    animationDuration: const Duration(milliseconds: 300),
    icon: const Icon(Icons.error, color: Colors.white),
    showIcon: true,
    primaryColor: Colors.red,
    borderSide: const BorderSide(color: Color.fromARGB(255, 113, 69, 66)),
    backgroundColor: const Color.fromARGB(255, 213, 50, 50),
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [
      BoxShadow(
        color: Color.fromARGB(0, 255, 85, 85),
        blurRadius: 16,
        offset: Offset(0, 16),
        spreadRadius: 0,
      )
    ],
    showProgressBar: true,
    closeButtonShowType: CloseButtonShowType.onHover,
    closeOnClick: false,
    pauseOnHover: true,
    dragToClose: true,
    applyBlurEffect: false,
  );
}

Widget buildAnimatedCard(
  BuildContext context, {
  required String title,
  required String subtitle,
  required String imagePath,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 7,
            offset: const Offset(
                3, 5), // Deslocamento horizontal e vertical da sombra
          ),
        ],
      ),
      child: Card(
        elevation: 6,
        shadowColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
              child: Image.asset(
                imagePath,
                width: 100,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    )
        // Adiciona animação ao card
        .animate()
        .fadeIn(duration: 700.ms)
        .slideX(curve: Curves.easeOut),
  );
}
