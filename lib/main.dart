import 'package:Redeplansanea/formularios/presenca/forms_page.dart';
import 'package:Redeplansanea/produtos/produto_a/produto_a.dart';
import 'package:Redeplansanea/produtos/produto_b/produto_b.dart';
import 'package:Redeplansanea/produtos/produto_c/produto_c.dart';
import 'package:Redeplansanea/router.dart';
import 'package:Redeplansanea/view/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:toastification/toastification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

//import 'package:intl/date_symbol_data_http_request.dart';
//import 'package:intl/date_symbol_data_file.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // if (!kIsWeb) await initializeDateFormatting('pt_BR', 'pt_BR');
  await initializeDateFormatting('pt_BR');

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
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
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
  late List<Widget> _pages;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  // userData será carregado assincronamente
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    // Inicializa _pages com uma lista vazia ou com algum placeholder, se desejar.
    _pages = [];
    // Carrega os dados do usuário
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser?.uid)
        .get();

    setState(() {
      userData = doc.data() as Map<String, dynamic>;

      // Monta a lista _pages com base no nível da conta
      _pages = [
        // Se o nível for 1, adiciona a ListPage antes das demais páginas
        if (userData!['nivelConta'] == 1 || userData!['nivelConta'] == 0) ...[
          ListPage(),
        ],
        const Produtos(),
        HomeScreen(_currentUser),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    // Enquanto os dados não são carregados, exibe um indicador de carregamento
    if (userData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Constrói os itens da navegação conforme o nível da conta
    List<Widget> navItems = [];
    if (userData!['nivelConta'] == 1 || userData!['nivelConta'] == 0) {
      navItems.add(const Icon(Icons.list, size: 30));
    }
    navItems.addAll([
      const Icon(Icons.house, size: 30),
      const Icon(Icons.supervised_user_circle_sharp, size: 30),
    ]);

    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF00B3CC),
              Color(0xFF004466),
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
                        'assets/logoredeplanrmbg.png',
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
        items: navItems,
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

class Produtos extends StatefulWidget {
  const Produtos({super.key});

  @override
  State<Produtos> createState() => _ProdutosState();
}

class _ProdutosState extends State<Produtos> {
  User? get _currentUser => FirebaseAuth.instance.currentUser;

  // userData será carregado assincronamente
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    // Carrega os dados do usuário
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser?.uid)
        .get();

    setState(() {
      userData = doc.data() as Map<String, dynamic>?;
    });
  }

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
                MaterialPageRoute(builder: (context) => ProdutoA_menu()),
              );
            },
          ),

          if ((userData?['nivelConta'] ?? 2) > 2 ||
              (userData?['nivelConta'] ?? 2) <= 1)
            buildAnimatedCard(
              context,
              title: 'Produto B',
              subtitle: 'Estratégia de Mobilização, Participação e Comunicação',
              imagePath: 'assets/capaProdutos/produtoB.png',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProdutoB_menu()),
                );
              },
            )
          else
            buildDisabledAnimatedCard(
              context,
              title: 'Produto B',
              subtitle: 'Estratégia de Mobilização, Participação e Comunicação',
              imagePath: 'assets/capaProdutos/produtoB.png',
            ),

          // Produto C: Apenas como exemplo, sem navegação específica
          if ((userData?['nivelConta'] ?? 2) > 3 ||
              (userData?['nivelConta'] ?? 2) <= 1)
            buildAnimatedCard(
              context,
              title: 'Produto C',
              subtitle: 'Diagnóstico Técnico-Participativo',
              imagePath: 'assets/capaProdutos/produtoC.png',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProdutoC_menu()),
                );
              },
            )
          else
            buildDisabledAnimatedCard(
              context,
              title: 'Produto C',
              subtitle: 'Diagnóstico Técnico-Participativo',
              imagePath: 'assets/capaProdutos/produtoC.png',
            ),
          buildDisabledAnimatedCard(
            context,
            title: 'Produto D',
            subtitle: 'Prognóstico',
            imagePath: 'assets/capaProdutos/produtoD.png',
          ),
          buildDisabledAnimatedCard(
            context,
            title: 'Produto E',
            subtitle: 'Programas, Projetos e Ações',
            imagePath: 'assets/capaProdutos/produtoE.png',
          ),
          buildDisabledAnimatedCard(
            context,
            title: 'Produto F',
            subtitle: 'Indicadores de Desempenho',
            imagePath: 'assets/capaProdutos/produtoF.png',
          ),

          buildDisabledAnimatedCard(
            context,
            title: 'Produto G',
            subtitle: 'Resumo Executivo e Minuta de Lei',
            imagePath: 'assets/capaProdutos/produtoG.png',
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

Widget buildDisabledAnimatedCard(
  BuildContext context, {
  required String title,
  required String subtitle,
  required String imagePath,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.4),
          blurRadius: 7,
          offset: const Offset(3, 5),
        ),
      ],
    ),
    child: Card(
      elevation: 4,
      color: Colors.grey[200], // Cor de fundo mais clara
      shadowColor: Colors.grey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          // Overlay branco semi-transparente
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white.withOpacity(0.7),
            ),
          ),

          Row(
            children: [
              // Imagem com filtro cinza
              ColorFiltered(
                colorFilter: const ColorFilter.matrix([
                  0.5,
                  0.5,
                  0.5,
                  0,
                  0,
                  0.5,
                  0.5,
                  0.5,
                  0,
                  0,
                  0.5,
                  0.5,
                  0.5,
                  0,
                  0,
                  0,
                  0,
                  0,
                  1,
                  0,
                ]),
                child: ClipRRect(
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
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600], // Texto cinza
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500], // Texto cinza mais claro
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Texto de indisponível centralizado
        ],
      ),
    ).animate().fadeIn(duration: 700.ms).slideX(curve: Curves.easeOut),
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
        .slideX(curve: Curves.decelerate),
  );
}
