import 'package:Plansanear/singleton.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PesquisaSatisfacao extends StatelessWidget {
  const PesquisaSatisfacao({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(150.0), // Define a altura do AppBar
        child: AppBar(
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 50, left: 10, right: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Image.asset(
                          'assets/logo_plan.png', // Caminho da sua imagem
                          height:
                              120, // Ajuste a altura da imagem conforme necessário
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(
                          width: 10), // Espaço entre a imagem e o texto
                      Flexible(
                        child: Text(
                          'Pesquisa de satisfação',
                          style: GoogleFonts.aDLaMDisplay(
                            fontSize: 28,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: const Color(0xFFB0E0E6),
        ),
      ),
      body: const SatisfactionSurveyForm(),
    );
  }
}

class SatisfactionSurveyForm extends StatefulWidget {
  const SatisfactionSurveyForm({super.key});

  @override
  _SatisfactionSurveyFormState createState() => _SatisfactionSurveyFormState();
}

class _SatisfactionSurveyFormState extends State<SatisfactionSurveyForm>
    with SingleTickerProviderStateMixin {
  int _currentQuestionIndex = -1; // -1 to show the intro screen first
  String? _observations = '';
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _questions = [
    {
      'question':
          'As informações apresentadas durante o encontro foram claras e compreensíveis para você?',
      'rating': null,
      'lowLabel': 'Muito insatisfeito',
      'highLabel': 'Muito satisfeito',
    },
    {
      'question':
          'Você acredita que as informações fornecidas no encontro serão úteis para o seu dia a dia?',
      'rating': null,
      'lowLabel': 'Pouco útil',
      'highLabel': 'Muito útil',
    },
    {
      'question':
          'Qual é a sua opinião sobre a qualidade geral do nosso encontro de saneamento básico?',
      'rating': null,
      'lowLabel': 'Muito insatisfeito',
      'highLabel': 'Muito satisfeito',
    },
    {
      'question':
          'Em uma escala de 1 a 5, qual é a probabilidade de você participar de outro encontro organizado por nós no futuro?',
      'rating': null,
      'lowLabel': 'Muito improvável',
      'highLabel': 'Muito provável',
    },
    {
      'question':
          'Como você avalia a sua experiência em nosso encontro sobre saneamento básico?',
      'rating': null,
      'lowLabel': 'Muito insatisfeito',
      'highLabel': 'Muito satisfeito',
    },
    {
      'question': 'Questionamentos/ Observações/ Dúvidas:',
      'isText': true,
    },
  ];

  // Lista para armazenar as respostas finais
  final List<String> respostaFinal = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
      _controller.forward(from: 0);
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
      _controller.forward(from: 0);
    }
  }

  void _saveResponses() {
    // Armazena as respostas das perguntas e observações em respostaFinal
    for (var i = 0; i < _questions.length - 1; i++) {
      respostaFinal.add(_questions[i]['rating'].toString());
    }
    respostaFinal.add(_observations ?? '');

    // Exibe o vetor de respostas no console
    print(respostaFinal);

    MeuSingleton.instance.respostasSatisfacao.addAll(respostaFinal);
    MeuSingleton.instance.flagPodeEnviar = true;

    print(MeuSingleton.instance.respostasSatisfacao);
    MeuSingleton.instance.zerarVetor();
    Navigator.of(context).pop();

    /* Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => TesteClass(),
    ));*/
  }

  @override
  Widget build(BuildContext context) {
    // Tela de introdução
    if (_currentQuestionIndex == -1) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Pesquisa de Satisfação - ${MeuSingleton.instance.respostasSatisfacao[3] == 'Comitê' ? 'Comitê Executivo e de Coordenação' : 'Encontro Público'} - ${MeuSingleton.instance.respostasSatisfacao[2]} ${MeuSingleton.instance.respostasSatisfacao[1]}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            MeuSingleton.instance.respostasSatisfacao[3] == 'Comitê'
                ? const Text(
                    'Agradecemos sua participação nesta pesquisa de satisfação. Seu feedback é essencial para que possamos melhorar continuamente nossos processos e a eficácia do comitê executivo e de coordenação. Suas respostas serão tratadas com confidencialidade e utilizadas exclusivamente para fins de aprimoramento interno.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.justify,
                  )
                : const Text(
                    'Agradecemos por participar da nossa pesquisa de satisfação. Sua opinião é fundamental para melhorarmos nossos serviços. Por favor, responda às perguntas a seguir com sinceridade.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.justify,
                  ),
            const SizedBox(height: 16),
            const Text(
              'Todas as respostas são confidenciais.  Se precisar de mais alguma coisa, estou à disposição!',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Iniciar',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    // Exibir perguntas com animação
    final currentQuestion = _questions[_currentQuestionIndex];
    final isAnswerSelected = currentQuestion['isText'] == true
        ? _observations!.isNotEmpty
        : currentQuestion['rating'] != null;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              Text(
                'Pergunta ${_currentQuestionIndex + 1} de ${_questions.length}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.indigo[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  currentQuestion['question'],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 55),
              if (currentQuestion['isText'] == true)
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _observations = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Escreva aqui suas observações...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 4,
                )
              else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currentQuestion['lowLabel'] ?? "",
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      currentQuestion['highLabel'] ?? "",
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildRatingQuestion(
                  selectedRating: currentQuestion['rating'],
                  onChanged: (int? value) {
                    setState(() {
                      _questions[_currentQuestionIndex]['rating'] = value;
                    });
                  },
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: _currentQuestionIndex > 0
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.end,
                children: [
                  if (_currentQuestionIndex > 0)
                    ElevatedButton(
                      onPressed: _previousQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                      ),
                      child: const Text(
                        'Voltar',
                        style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                    ),
                  if (_currentQuestionIndex < _questions.length - 1)
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: isAnswerSelected ? _nextQuestion : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                        child: const Text(
                          'Próxima',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  if (_currentQuestionIndex == _questions.length - 1)
                    ElevatedButton(
                      onPressed: _saveResponses,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                      ),
                      child: const Text(
                        'Enviar Respostas',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingQuestion({
    required int? selectedRating,
    required ValueChanged<int?> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List<Widget>.generate(5, (index) {
        return Row(
          children: [
            Radio<int?>(
              value: index + 1,
              groupValue: selectedRating,
              onChanged: onChanged,
              activeColor: Colors.indigo,
            ),
            Text(
              '${index + 1}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        );
      }),
    );
  }
}
