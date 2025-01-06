import 'package:Plansanear/custom_button.dart';
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

class ListPage extends StatelessWidget {
  const ListPage({super.key});

  void _showPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Selecione um estado"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              children: [
                ListTile(
                  leading: Image.asset('assets/ico_pesquisa.png', width: 40),
                  title: const Text("Rio de Janeiro"),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Image.asset('assets/pernambuco.png', width: 40),
                  title: const Text("Pernambuco"),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Image.asset('assets/ico_pesquisa.png', width: 40),
                  title: const Text("Bahia"),
                  onTap: () {
                    Navigator.pop(context);
                  },
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
      child: CustomButton2(
        imagePath: 'assets/ico_pesquisa.png',
        label: 'PESQUISA DE SATISFAÇÃO',
        backgroundColor: const Color(0xFF1E90FF),
        textColor: const Color(0xFFD2E48E),
        outlineColor: const Color.fromARGB(255, 0, 0, 0),
        outlineWidth: 2.0,
        onPressed: () {
          _showPopup(context);
        },
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
