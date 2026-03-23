import 'package:flutter/material.dart';
import 'objective_card.dart';

class CardSection extends StatelessWidget {
  const CardSection({
    super.key,
    required this.sectionTitle,
    required this.objectives,
    required this.cardSize,
    required this.onChangeCardSize,
    required this.color,
  });

  final Color color;
  final String sectionTitle;
  final List<Map<String, dynamic>> objectives;
  final int cardSize;
  final VoidCallback onChangeCardSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sectionTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.format_size),
                onPressed: onChangeCardSize,
              ),
            ],
          ),
        ),
        _buildGrid(),
      ],
    );
  }

  Widget _buildGrid() {
    int crossAxisCount = cardSize == 0
        ? 4 // Pequeñas: 4 tarjetas por fila
        : cardSize == 1
            ? 3 // Medianas: 3 tarjetas por fila
            : 2; // Grandes: 2 tarjetas por fila

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),  // Sin scroll interno
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 1.0,
        mainAxisSpacing: 1.0,
        childAspectRatio: cardSize == 0
            ? 0.8 // Tarjeta pequeña
            : cardSize == 1
                ? 0.7 // Tarjeta mediana
                : 0.9, // Tarjeta grande
      ),
      itemCount: objectives.length,
      itemBuilder: (context, index) {
        final objective = objectives[index];
        return ObjectiveCard(
          title: objective['title'],
          stat: objective['stat'],
          target: objective['target'],
          isPositive: objective['isPositive'],
          cardSize: cardSize,
          color: color,
        );
      },
    );
  }
}
