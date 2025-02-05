import 'package:Redeplansanea/singleton.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PesquisaSatisfacao extends StatelessWidget {
  const PesquisaSatisfacao({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: AppBar(
          elevation: 2,
          shadowColor: Colors.blue.shade100,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Centralização principal
                children: [
                  // Logo centralizado
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
                          'assets/logo_plan.png',
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 20),

                  // Título centralizado verticalmente
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pesquisa de',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        'Satisfação',
                        style: GoogleFonts.roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;

    // Tela de introdução
    if (_currentQuestionIndex == -1) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.indigo.shade700, Colors.purple.shade400],
          ),
        ),
        child: Center(
          child: Container(
            constraints:
                BoxConstraints(maxWidth: isWeb ? 800 : double.infinity),
            padding: EdgeInsets.symmetric(
              vertical: isWeb ? 40 : 16,
              horizontal: isWeb ? 40 : 16,
            ),
            child: AnimatedOpacity(
              opacity: 1.0,
              duration: Duration(milliseconds: 500),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: EdgeInsets.all(isWeb ? 40.0 : 20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: Duration(milliseconds: 500),
                        builder: (context, double value, child) {
                          return Transform.scale(
                            scale: value,
                            child: child,
                          );
                        },
                        child: Icon(
                          Icons.assignment_outlined,
                          size: isWeb ? 80 : 60,
                          color: Colors.indigo,
                        ),
                      ),
                      SizedBox(height: isWeb ? 30 : 20),
                      Text(
                        'Pesquisa de Satisfação - ${MeuSingleton.instance.respostasSatisfacao[3] == 'Comitê' ? 'Comitê Executivo e de Coordenação' : 'Encontro Público'} - ${MeuSingleton.instance.respostasSatisfacao[2]} ${MeuSingleton.instance.respostasSatisfacao[1]}',
                        style: TextStyle(
                          fontSize: isWeb ? 26 : 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isWeb ? 30 : 20),
                      Flexible(
                        child: SingleChildScrollView(
                          child: Text(
                            MeuSingleton.instance.respostasSatisfacao[3] ==
                                    'Comitê'
                                ? 'Agradecemos sua participação nesta pesquisa de satisfação. Seu feedback é essencial para que possamos melhorar continuamente nossos processos e a eficácia do comitê executivo e de coordenação. Suas respostas serão tratadas com confidencialidade e utilizadas exclusivamente para fins de aprimoramento interno.'
                                : 'Agradecemos por participar da nossa pesquisa de satisfação. Sua opinião é fundamental para melhorarmos nossos serviços. Por favor, responda às perguntas a seguir com sinceridade.',
                            style: TextStyle(
                              fontSize: isWeb ? 18 : 16,
                              height: 1.5,
                              color: Colors.grey.shade800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(height: isWeb ? 25 : 15),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: Duration(milliseconds: 500),
                          builder: (context, double value, child) {
                            return Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: Opacity(
                                opacity: value,
                                child: child,
                              ),
                            );
                          },
                          child: ElevatedButton(
                            onPressed: _nextQuestion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              padding: EdgeInsets.symmetric(
                                vertical: isWeb ? 20 : 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                              shadowColor: Colors.indigo.withOpacity(0.3),
                            ),
                            child: AnimatedSwitcher(
                              duration: Duration(milliseconds: 300),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Iniciar',
                                    style: TextStyle(
                                      fontSize: isWeb ? 20 : 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: isWeb ? 24 : 20,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
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
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Header com contador
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Pergunta ${_currentQuestionIndex + 1} de ${_questions.length}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.indigo[800],
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Card da pergunta
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                      color: Colors.indigo.withOpacity(0.2), width: 1),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    currentQuestion['question'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[800],
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Campo de texto ou rating
              if (currentQuestion['isText'] == true)
                TextField(
                  onChanged: (value) => setState(() => _observations = value),
                  decoration: InputDecoration(
                    hintText: 'Escreva aqui suas observações...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.indigo, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  maxLines: 4,
                )
              else ...[
                // Labels da escala
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currentQuestion['lowLabel'] ?? "",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        currentQuestion['highLabel'] ?? "",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Rating moderno
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (index) {
                      final ratingValue = index + 1;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _questions[_currentQuestionIndex]['rating'] =
                              ratingValue;
                        }),
                        child: Container(
                          width: 48,
                          height: 48,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: currentQuestion['rating'] == ratingValue
                                ? _getRatingColor(ratingValue)
                                : Colors.grey[100],
                            shape: BoxShape.circle,
                            border: currentQuestion['rating'] == ratingValue
                                ? Border.all(
                                    color: Colors.indigo.withOpacity(0.2),
                                    width: 2)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '$ratingValue',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: currentQuestion['rating'] == ratingValue
                                    ? Colors.white
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],

              const SizedBox(height: 36),

              // Botões de navegação
              Row(
                mainAxisAlignment: _currentQuestionIndex > 0
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.end,
                children: [
                  if (_currentQuestionIndex > 0)
                    OutlinedButton(
                      onPressed: _previousQuestion,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 12),
                        side: BorderSide(color: Colors.indigo),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Voltar',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.indigo[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (_currentQuestionIndex < _questions.length - 1)
                    ElevatedButton(
                      onPressed: isAnswerSelected ? _nextQuestion : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'Próxima',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (_currentQuestionIndex == _questions.length - 1)
                    ElevatedButton(
                      onPressed: _saveResponses,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Enviar Respostas',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
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

  Color _getRatingColor(int rating) {
    final hues = [
      Colors.red[400]!,
      Colors.orange[400]!,
      Colors.yellow[600]!,
      Colors.lightGreen[400]!,
      Colors.green[400]!
    ];
    return hues[rating - 1];
  }
}
