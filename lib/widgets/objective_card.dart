import 'dart:math';

import 'package:flutter/material.dart';

class ObjectiveCard extends StatelessWidget {
  ObjectiveCard({
    super.key,
    required this.title,
    required this.stat,
    required this.target,
    required this.isPositive,
    required this.cardSize,
    required this.color,
  });

  final Color color;
  final String title;
  final int stat;
  final int target;
  final bool isPositive;
  final int cardSize; // 0: pequeña, 1: mediana, 2: grande
  late final double progress = stat / target > 1 ? 1.0 : stat / target;

  static Color? backgroundColor = Colors.grey[850];

  bool get isTargetMet {
    return isPositive ? stat >= target : stat <= target;
  }

  Widget get _buildCardOfSize {
    switch (cardSize) {
      case 0: // Tarjeta pequeña
        return _buildSmallCard();
      case 1: // Tarjeta mediana
        return _buildMediumCard();
      case 2: // Tarjeta grande
        return _buildLargeCard();
      default:
        return _buildSmallCard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: isTargetMet
          ? RoundedRectangleBorder(
              side: BorderSide(
                width: cardSize + 3.0,
                color: Colors.amberAccent,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
            )
          : null,
      child: _buildCardOfSize,
    );
  }

  // Tarjeta pequeña
  Widget _buildSmallCard() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "$stat",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: backgroundColor,
            color: color,
            minHeight: 5,
            borderRadius: BorderRadius.circular(2.5),
          ),
        ],
      ),
    );
  }

  // Tarjeta mediana
  Widget _buildMediumCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              double size = constraints.maxWidth * 0.9;
              double strokeWidth = size * 0.1;
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: size,
                    width: size,
                    child: CustomPaint(
                      painter: CircularProgressCustomPainter(
                        progress: progress,
                        strokeWidth: strokeWidth,
                        color: color,
                        backgroundColor: backgroundColor,
                        endText: "${isPositive ? "" : "+"}$target",
                      ),
                    ),
                  ),
                  Text(
                    "$stat",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // Tarjeta grande
  Widget _buildLargeCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              double size = constraints.maxWidth * 0.8;
              double strokeWidth = size * 0.1;
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: size,
                    width: size,
                    child: CustomPaint(
                      painter: CircularProgressCustomPainter(
                        progress: progress,
                        strokeWidth: strokeWidth,
                        color: color,
                        backgroundColor: backgroundColor,
                        endText: "${isPositive ? "" : "+"}$target",
                      ),
                    ),
                  ),
                  Positioned(
                    child: Text(
                      "$stat",
                      style: TextStyle(
                        fontSize: 33,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ),
                  Positioned(
                    top: size * 0.15,
                    child: Text(
                      "${(progress * 100).toInt()}%",
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (isTargetMet)
                    Positioned(
                      bottom: size * 0.25,
                      child: const Text(
                        "Cumpliendo",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.amberAccent,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// Barra de progreso circular personalizada
class CircularProgressCustomPainter extends CustomPainter {
  CircularProgressCustomPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.backgroundColor,
    required this.endText,
  });

  final double progress;
  final double strokeWidth;
  final Color color;
  final Color? backgroundColor;
  final String? endText;

  @override
  void paint(Canvas canvas, Size size) {
    Paint baseCircle = Paint()
      ..color = backgroundColor!
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Paint progressCircle = Paint()
      ..color = color
      ..strokeWidth = strokeWidth * 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = size.width / 2;

    // Dibujar la base circular
    double startAngle = -5 / 4 * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      3 / 2 * pi,
      false,
      baseCircle,
    );

    // Dibujar la barra de progreso circular
    double sweepAngle = 3 / 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressCircle,
    );

    // Dibujar el número bajo la barra
    if (endText != null) {
      final endTextSpan = TextSpan(
        text: endText,
        style: TextStyle(
          fontSize: strokeWidth * 1.2 + 5.0,
          fontWeight: FontWeight.w500,
        ),
      );
      final textPainter = TextPainter(
        text: endTextSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );

      double textY =
          size.height / 2 + (size.height / 2 + strokeWidth) * sin(startAngle);
      Offset textOffset = Offset(
        size.width / 2 - textPainter.width / 2,
        textY - textPainter.height / 2,
      );

      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(CircularProgressCustomPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.endText != endText ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
