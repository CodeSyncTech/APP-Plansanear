import 'package:Redeplansanea/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intro_screen_onboarding_flutter/intro_app.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

    if (isFirstTime) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IntroScreen(),
        ),
      );
      await prefs.setBool('isFirstTime', false);
    }

    _navigateToMainPage();
  }

  void _navigateToMainPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => BottomNavBar(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class IntroScreen extends StatelessWidget {
  final List<Introduction> list = [
    Introduction(
      title: 'Bem-vindos',
      subTitle:
          'O Plansanear é um projeto de apoio à elaboração de Planos Municipais de Saneamento Básico (PMSBs)',
      imageUrl: 'assets/ze_planinho3.png',
    ),
    Introduction(
      title: 'Atuação',
      subTitle:
          'com atuação nos Municípios dos Estados do Rio de Janeiro, Pernambuco e Bahia.',
      imageUrl: 'assets/mapa_plansanear.png',
    ),
  ];

  IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return IntroScreenOnboarding(
      introductionList: list,
      onTapSkipButton: () {
        Navigator.pop(context);
      },
    );
  }
}
