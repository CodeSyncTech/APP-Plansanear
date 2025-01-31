import 'package:Plansanear/lista_presenca.dart';
import 'package:Plansanear/custom_button.dart';
import 'package:Plansanear/onboarding.dart';
import 'package:Plansanear/pesquisaSatisfacao.dart';
import 'package:Plansanear/router.dart';
import 'package:Plansanear/singleton.dart';

import 'package:Plansanear/view/auth_screen.dart';
import 'package:Plansanear/view/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
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
      CriarFormularioScreen(),
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
                      const Text(
                        'MENU',
                        style: TextStyle(
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
          Icon(Icons.camera_alt, size: 30),
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
          _buildAnimatedCard(
            context,
            title: 'Produto A',
            subtitle: 'Atividades iniciais para a elaboração do PMSB',
            imagePath: 'assets/capaProdutos/produtoA.png',
            onTap: () {
              showErrorToast(
                context,
                'Aguarde!',
                'Por favor, aguarde, o produto B ainda está em desenvolvimento!',
              );
            },
          ),
          // Produto B: Vai para a tela Esgoto
          _buildAnimatedCard(
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
          _buildAnimatedCard(
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
          _buildAnimatedCard(
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
          _buildAnimatedCard(
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
          _buildAnimatedCard(
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

          _buildAnimatedCard(
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

Widget _buildAnimatedCard(
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
                      textAlign: TextAlign.center,
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

class ListPage extends StatelessWidget {
  const ListPage({super.key});

  void _showPopup(BuildContext context) async {
    final estados = ["Rio de Janeiro", "Pernambuco", "Bahia"];
    final municipios = {
      "Bahia": [
        "Araci",
        "Caatiba",
        "Cícero Dantas",
        "Iaçu",
        "Nova Itarana",
        "Barra da Estiva",
        "Canudos",
        "Coronel João Sá",
        "Muquém do São Francisco",
        "Rio Real"
      ],
      "Pernambuco": [
        "Belém do São Francisco",
        "Betânia",
        "Cabrobó",
        "Carnaubeira da Penha",
        "Lajedo",
        "Petrolândia",
        "Quixaba",
        "São José do Belmonte",
        "Serrita",
        "Trindade"
      ],
      "Rio de Janeiro": [
        "Itaocara",
        "São Francisco de Itabapoana",
        "São Fidélis",
        "Duas Barras",
        "Casimiro de Abreu",
        "Bom Jardim",
        "Bom Jesus de Itabapoana"
      ]
    };
    final tipos = ["Comitê", "Evento Público"];

    String? estadoSelecionado;
    String? municipioSelecionado;
    String? tipoSelecionado;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Stack(
              children: [
                // 1) Animação Lottie ocupando todo o fundo
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Lottie.asset(
                      'assets/lottie.json', // Caminho da sua animação
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // 2) Overlay (opcional) para dar contraste
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.15),
                          Colors.black.withOpacity(0.25),
                        ],
                      ),
                    ),
                  ),
                ),

                // 3) Conteúdo principal do Popup
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/ze_planinho.png',
                        width: 100,
                        height: 100,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Selecione as opções",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 239, 239, 239),
                        ),
                      ),
                      const SizedBox(height: 10),
                      StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          Widget campoDropdown({
                            required String rotulo,
                            required Widget dropdown,
                            Color? rotuloColor,
                          }) {
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 255, 255, 255)
                                    .withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        const Color.fromARGB(255, 80, 80, 80),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: rotulo,
                                  labelStyle: TextStyle(
                                    color: rotuloColor ?? Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                child: dropdown,
                              ),
                            );
                          }

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Campo para escolher o Estado
                              campoDropdown(
                                rotulo: 'Estado',
                                rotuloColor: Colors.blue.shade700,
                                dropdown: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: estadoSelecionado,
                                    hint: const Text("Selecione o estado"),
                                    items: estados.map((String estado) {
                                      return DropdownMenuItem<String>(
                                        value: estado,
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              'assets/bandeiras/bandeira_${estado.toLowerCase().replaceAll(" ", "_")}.png',
                                              width: 40,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(estado),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        estadoSelecionado = newValue;
                                        municipioSelecionado = null;
                                      });
                                    },
                                  ),
                                ),
                              ),

                              // Campo para escolher o Município
                              if (estadoSelecionado != null)
                                campoDropdown(
                                  rotulo: 'Município',
                                  rotuloColor: Colors.green.shade700,
                                  dropdown: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: municipioSelecionado,
                                      hint: const Text("Selecione o município"),
                                      items: municipios[estadoSelecionado]!
                                          .map((String municipio) {
                                        return DropdownMenuItem<String>(
                                          value: municipio,
                                          child: Text(municipio),
                                        );
                                      }).toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          municipioSelecionado = newValue;
                                        });
                                      },
                                    ),
                                  ),
                                ),

                              // Campo para escolher o Tipo
                              campoDropdown(
                                rotulo: 'Tipo',
                                rotuloColor: Colors.orange.shade700,
                                dropdown: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: tipoSelecionado,
                                    hint: const Text("Selecione o tipo"),
                                    items: tipos.map((String tipo) {
                                      return DropdownMenuItem<String>(
                                        value: tipo,
                                        child: Text(tipo),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        tipoSelecionado = newValue;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              // Use seu Singleton ou lógica própria
                              MeuSingleton.instance.zerarVetor();
                              if (estadoSelecionado != null &&
                                  municipioSelecionado != null &&
                                  tipoSelecionado != null) {
                                print("Estado: $estadoSelecionado");
                                print("Município: $municipioSelecionado");
                                print("Tipo: $tipoSelecionado");

                                MeuSingleton.instance.adicionarItem(
                                  "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year} "
                                  "${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}",
                                );
                                MeuSingleton.instance
                                    .adicionarItem(municipioSelecionado!);
                                MeuSingleton.instance
                                    .adicionarItem(estadoSelecionado!);
                                MeuSingleton.instance
                                    .adicionarItem(tipoSelecionado!);

                                print(
                                  "\n\nEste é o meu vetor: ${MeuSingleton.instance.obterVetor()}",
                                );

                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PesquisaSatisfacao(),
                                  ),
                                );
                              }

                              if (estadoSelecionado != null &&
                                  municipioSelecionado != null &&
                                  tipoSelecionado != null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PesquisaSatisfacao(),
                                  ),
                                );
                              } else {
                                showErrorToast(
                                  context,
                                  'Erro!',
                                  'Por favor, selecione todas as opções!',
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text("Confirmar"),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 255, 255, 255),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text("Cancelar"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          CustomButton(
            imagePath: 'assets/ico_presenca.png',
            label: 'ICONE WIDGET TESTE',
            backgroundColor: const Color(0xFF1E90FF),
            textColor: const Color.fromARGB(255, 255, 255, 255),
            outlineColor: const Color.fromARGB(255, 0, 0, 0),
            outlineWidth: 2.0,
            onPressed: () {
              CriarFormularioScreen();
              /*
              toastification.show(
                context: context, // optional if you use ToastificationWrapper
                type: ToastificationType
                    .success, // Definindo o tipo como 'sucesso'
                style: ToastificationStyle.flat,
                autoCloseDuration:
                    const Duration(seconds: 5), // Definindo a duração
                title: const Text('Sucesso!'),
                description: RichText(
                    text: const TextSpan(
                        text:
                            'Os dados foram enviados com sucesso!')), // Texto personalizado
                alignment: Alignment
                    .bottomCenter, // Centralizando a notificação no topo
                direction: TextDirection.ltr,
                animationDuration: const Duration(milliseconds: 300),

                icon: const Icon(Icons.check_circle,
                    color: Colors.white), // Ícone de sucesso
                showIcon: true, // Mostra o ícone
                primaryColor: Colors.green, // Cor principal para sucesso
                backgroundColor: const Color.fromARGB(
                    255, 24, 126, 29), // Cor de fundo verde
                foregroundColor: Colors.white, // Cor do texto branca
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(0, 132, 255, 101),
                    blurRadius: 16,
                    offset: Offset(0, 16),
                    spreadRadius: 0,
                  )
                ],
                showProgressBar: true, // Barra de progresso visível
                closeButtonShowType: CloseButtonShowType.onHover,
                closeOnClick: false,
                pauseOnHover: true,
                dragToClose: true,
                applyBlurEffect: false,
                callbacks: ToastificationCallbacks(
                  onTap: (toastItem) => print('Toast ${toastItem.id} tapped'),
                  onCloseButtonTap: (toastItem) =>
                      print('Toast ${toastItem.id} close button tapped'),
                  onAutoCompleteCompleted: (toastItem) =>
                      print('Toast ${toastItem.id} auto complete completed'),
                  onDismissed: (toastItem) =>
                      print('Toast ${toastItem.id} dismissed'),
                ),
              );*/

              print("teste");
            },
          ),
          CustomButton2(
            imagePath: 'assets/ico_pesquisa.png',
            label: 'PESQUISA DE SATISFAÇÃO',
            backgroundColor: const Color(0xFF1E90FF),
            textColor: const Color.fromARGB(255, 255, 255, 255),
            outlineColor: const Color.fromARGB(255, 0, 0, 0),
            outlineWidth: 2.0,
            onPressed: () {
              _showPopup(context);
              print("teste");
            },
          ),
        ],
      ),
    );
  }
}

class ComparePage extends StatelessWidget {
  const ComparePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Em manutenção',
        style: TextStyle(fontSize: 30, color: Colors.white),
      ),
    );
  }
}
