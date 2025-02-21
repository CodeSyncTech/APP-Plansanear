import 'package:Redeplansanea/formularios/presenca/todas_respostas.dart';
import 'package:Redeplansanea/main.dart';
import 'package:Redeplansanea/produtos/produto_a/infoMunicipios/paginarespostas.dart';
import 'package:Redeplansanea/produtos/produto_a/infosetor/setor.dart';
import 'package:Redeplansanea/produtos/produto_a/instituicoes_setor/instituicoes_setor.dart';
import 'package:Redeplansanea/produtos/produto_a/organizacaosocial/organizacao.dart';
import 'package:Redeplansanea/produtos/produto_a/principais_liderancas/p_liderancas.dart';
import 'package:Redeplansanea/produtos/produto_a/views/formacao_comite_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProdutoA_menu extends StatefulWidget {
  const ProdutoA_menu({super.key});

  @override
  State<ProdutoA_menu> createState() => _ProdutoA_menuState();
}

class _ProdutoA_menuState extends State<ProdutoA_menu> {
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
                              'Produto A',
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
                  title: 'Formação do Comitê',
                  subtitle: 'Formação do comitê exeutivo',
                  imagePath: 'assets/ico_formcomite.png',
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            FormacaoComiteForm(),
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
                  title: 'Informações Sobre o Municipio',
                  subtitle:
                      'Informações sobre o saneamento e meios de comunicação do município',
                  imagePath: 'assets/ico_infomunicipio.png',
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            AcessoMunicipioScreen(),
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
                  title: 'Organização Social do Municipio',
                  subtitle:
                      'Mapeamento dos conselhos e instituições existentes no município',
                  imagePath: 'assets/ico_organizacao.png',
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            OrganizacaoMunicipioScreen(),
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
                // Exibe o card interativo se o nível do usuário for maior que 2; caso contrário, exibe o card desabilitado
                if ((userData?['nivelConta'] ?? 2) != 2)
                  buildAnimatedCard(
                    context,
                    title: 'Informações por Setor do Municipio',
                    subtitle:
                        'Informações sob saneamento básico no município por setor',
                    imagePath: 'assets/ico_infosaneamento.png',
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  SetoresScreen(),
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
                  )
                else
                  buildDisabledAnimatedCard(
                    context,
                    title: 'Informações por Setor do Municipio',
                    subtitle:
                        'Seu nível de conta não permite acessar essa funcionalidade',
                    imagePath: 'assets/ico_infosaneamento.png',
                  ),

                if ((userData?['nivelConta'] ?? 2) != 2)
                  buildAnimatedCard(
                    context,
                    title: 'Instituições Sociais do Município por Setor',
                    subtitle: 'Instituições Sociais do Município por Setor',
                    imagePath: 'assets/ico_instituicoessetor.png',
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  AtribuirInstituicoesScreen(),
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
                  )
                else
                  buildDisabledAnimatedCard(
                    context,
                    title: 'Instituições Sociais',
                    subtitle: 'Instituições Sociais do Município no Setor',
                    imagePath: 'assets/ico_instituicoessetor.png',
                  ),
                if ((userData?['nivelConta'] ?? 2) != 2)
                  buildAnimatedCard(
                    context,
                    title: 'Principais Lideranças por Setor',
                    subtitle:
                        'Localidades, Principais Lideranças Identificadas e Ponto Focal de casa um dos SM',
                    imagePath: 'assets/ico_plideres.png',
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  AtribuirLiderancasScreen(),
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
                  )
                else
                  buildDisabledAnimatedCard(
                    context,
                    title: 'Principais Lideranças por Setor',
                    subtitle:
                        'Localidades, Principais Lideranças Identificadas e Ponto Focal de casa um dos SM',
                    imagePath: 'assets/ico_plideres.png',
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
