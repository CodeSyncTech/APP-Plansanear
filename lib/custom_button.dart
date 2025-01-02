import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Color outlineColor;
  final double outlineWidth;

  const CustomButton({
    required this.imagePath,
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
    required this.outlineColor,
    this.outlineWidth = 1.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const buttonHeight = 100.0;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: screenWidth,
        height: buttonHeight,
        color: backgroundColor, // Define a cor de fundo do botão
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 10),
            // Usando OutlinedText para aplicar o efeito de borda no texto
            Stack(
              children: [
                // Contorno
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = outlineWidth
                      ..color = outlineColor,
                  ),
                ),
                // Texto principal
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 20,
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Image.asset(
                imagePath,
                height: buttonHeight * 0.9,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomButton2 extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Color outlineColor;
  final double outlineWidth;

  const CustomButton2({
    required this.imagePath,
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
    required this.outlineColor,
    this.outlineWidth = 1.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const buttonHeight = 100.0;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: screenWidth,
        height: buttonHeight,
        decoration: BoxDecoration(
          color: backgroundColor, // Define a cor de fundo do botão
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25), // Cor da sombra
              offset: const Offset(0, 4), // Somente na parte inferior
              blurRadius: 18.0,
              spreadRadius: 10.0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Image.asset(
                imagePath,
                height: buttonHeight * 0.9,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            // Usando OutlinedText para aplicar o efeito de borda no texto
            Stack(
              children: [
                // Contorno
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = outlineWidth
                      ..color = outlineColor,
                  ),
                ),
                // Texto principal
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 20,
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BorderedText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color borderColor;
  final Color textColor;

  const BorderedText({super.key, 
    required this.text,
    required this.fontSize,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(200, 60), // Tamanho do texto
      painter: TextBorderPainter(
        text: text,
        fontSize: fontSize,
        borderColor: borderColor,
        textColor: textColor,
      ),
    );
  }
}

class TextBorderPainter extends CustomPainter {
  final String text;
  final double fontSize;
  final Color borderColor;
  final Color textColor;

  TextBorderPainter({
    required this.text,
    required this.fontSize,
    required this.borderColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: textColor,
    );
    final textStyleBorder = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: borderColor,
    );

    final textSpan = TextSpan(text: text, style: textStyle);
    final textSpanBorder = TextSpan(text: text, style: textStyleBorder);

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    final textPainterBorder = TextPainter(
      text: textSpanBorder,
      textDirection: TextDirection.ltr,
    );

    textPainterBorder.layout();
    textPainter.layout();

    // Desenha o contorno do texto
    textPainterBorder.paint(canvas,
        const Offset(2.0, 2.0)); // Desloca o contorno para dar efeito de borda

    // Desenha o texto normal
    textPainter.paint(canvas, const Offset(0.0, 0.0)); // Texto centralizado
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
