import 'package:Redeplansanea/formularios/presenca/todas_respostas.dart';
import 'package:Redeplansanea/main.dart';
import 'package:Redeplansanea/produtos/produto_a/infoMunicipios/paginarespostas.dart';
import 'package:Redeplansanea/produtos/produto_a/infosetor/setor.dart';
import 'package:Redeplansanea/produtos/produto_a/instituicoes_setor/instituicoes_setor.dart';
import 'package:Redeplansanea/produtos/produto_a/organizacaosocial/organizacao.dart';
import 'package:Redeplansanea/produtos/produto_a/principais_liderancas/p_liderancas.dart';
import 'package:Redeplansanea/produtos/produto_a/views/formacao_comite_form.dart';
import 'package:Redeplansanea/produtos/produto_b/caracterizacaomunicipio/caracterizacaomunicipio.dart';
import 'package:Redeplansanea/produtos/produto_b/estruturapublica/estruturapublica.dart';
import 'package:Redeplansanea/produtos/produto_b/populacacoestradicionais/populacoestradicionais.dart';
import 'package:Redeplansanea/produtos/produto_b/programascampanhas/programascampanha.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProdutoB_menu extends StatefulWidget {
  const ProdutoB_menu({super.key});

  @override
  State<ProdutoB_menu> createState() => _ProdutoB_menuState();
}

class _ProdutoB_menuState extends State<ProdutoB_menu> {
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
    // Enquanto os dados do usuário não forem carregados, exibe um indicador de carregamento.
    if (userData == null) {
      return Scaffold(
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
                                'Preenchimento do',
                                style: GoogleFonts.roboto(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Produto A',
                                style: GoogleFonts.roboto(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      const Color.fromARGB(255, 230, 242, 255),
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
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
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
                              'Preenchimento do',
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Produto B',
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
      body: Center(
        child: Container(
          height: double.infinity,
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
          // Use SingleChildScrollView para evitar overflow se houver muitos cards
          child: SingleChildScrollView(
            child: Column(
              children: [
                buildAnimatedCard(
                  context,
                  title: 'Estrutura Pública Municipal',
                  subtitle: 'Informações para a caracterização do município',
                  imagePath: 'assets/icon_estruturapublica.png',
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            Tela1(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          final fadeAnimation = CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          );
                          return FadeTransition(
                            opacity: fadeAnimation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                ),
                buildAnimatedCard(
                  context,
                  title: 'Programas, Campanhas e Ações',
                  subtitle:
                      'Programas, campanhas e ações na política de saúde e assistência social',
                  imagePath: 'assets/icon_programasecampanha.png',
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            Tela2(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          final fadeAnimation = CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          );
                          return FadeTransition(
                            opacity: fadeAnimation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                ),
                buildAnimatedCard(
                  context,
                  title: 'Caracterização do Município',
                  subtitle:
                      'Politica de Saneamento, conselho municipal e Plano Diretor',
                  imagePath: 'assets/icon_caracterizacaomunicipio.png',
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            Tela3(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          final fadeAnimation = CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          );
                          return FadeTransition(
                            opacity: fadeAnimation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                ),
                buildAnimatedCard(
                  context,
                  title: 'Populações Tradicionais',
                  subtitle: '',
                  imagePath: 'assets/ico_povostradicionais.png',
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            Tela4(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          final fadeAnimation = CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          );
                          return FadeTransition(
                            opacity: fadeAnimation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
