import 'dart:math';

import 'custom_button.dart';
import 'singleton.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

void main() => runApp(const MaterialApp(home: BottomNavBar()));

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _page = 1;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  final List<Widget> _pages = [
    const AddPage(),
    const ListPage(),
    const ComparePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF00B3CC), // Azul ciano mais claro
              Color(0xFF004466), // Azul profundo mai s escuro
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // AppBar personalizado com conteúdo centralizado
            Container(
              padding:
                  const EdgeInsets.only(top: 40), // Margem para evitar corte
              child: AppBar(
                toolbarHeight: 50, // Altura personalizada para o AppBar
                flexibleSpace: Center(
                  // Centraliza o conteúdo no eixo principal
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Centraliza o Row em si
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/logo_plan.png',
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 10),
                      const BorderedText(
                        text: ' MENU',
                        fontSize: 44,
                        borderColor: Color(0xFF004466), // Cor da borda
                        textColor: Color(0xFFD2E48E), // Cor do texto
                      )
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
          Icon(Icons.send, size: 30),
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

class AddPage extends StatelessWidget {
  const AddPage({super.key});

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

class ListPage extends StatelessWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            CustomButton2(
              imagePath: 'assets/ico_pesquisa.png',
              label: 'PESQUISA DE SATISFAÇÃO',
              backgroundColor: const Color(0xFF1E90FF),
              textColor: const Color(0xFFD2E48E),
              outlineColor: const Color.fromARGB(255, 0, 0, 0),
              outlineWidth: 2.0,
              onPressed: () {
                MeuSingleton.instance.zerarVetor();
              },
            ),
            CustomButton(
              imagePath: 'assets/ico_presenca.png',
              label: 'LISTA DE PRESENÇA',
              backgroundColor: const Color(0xFF4682B4),
              textColor: const Color(0xFFD2E48E),
              outlineColor: const Color.fromARGB(255, 0, 0, 0),
              outlineWidth: 2.0,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Em manutenção',
                      textAlign: TextAlign.center,
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
            CustomButton2(
              imagePath: 'assets/ico_update.png',
              label: 'OUTROS',
              backgroundColor: const Color(0xFF1E90FF),
              textColor: const Color(0xFFD2E48E),
              outlineColor: const Color.fromARGB(255, 0, 0, 0),
              outlineWidth: 2.0,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Em manutenção',
                      textAlign: TextAlign.center,
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
            CustomButton2(
              imagePath: 'assets/ico_update.png',
              label: 'OUTROS',
              backgroundColor: const Color(0xFF1E90FF),
              textColor: const Color(0xFFD2E48E),
              outlineColor: const Color.fromARGB(255, 0, 0, 0),
              outlineWidth: 2.0,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Em manutenção',
                      textAlign: TextAlign.center,
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
            CustomButton2(
              imagePath: 'assets/ico_update.png',
              label: 'OUTROS',
              backgroundColor: const Color(0xFF1E90FF),
              textColor: const Color(0xFFD2E48E),
              outlineColor: const Color.fromARGB(255, 0, 0, 0),
              outlineWidth: 2.0,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Em manutenção',
                      textAlign: TextAlign.center,
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
          ],
        ),
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
