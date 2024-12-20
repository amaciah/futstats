import 'package:flutter/material.dart';
import 'package:futstats/models/statistics.dart';

class StatDisplay extends StatelessWidget {
  const StatDisplay({
    super.key,
    required this.stats,
  });

  final Map<String, double> stats;

  @override
  Widget build(BuildContext context) {
    // Obtener estadísticas agrupadas por categoría
    final groupedStats = StatCategory.values
        .map((category) {
          final statsForCategory = stats.entries
              .where((entry) =>
                  StatTemplates.getTemplateById(entry.key).category == category)
              .toList();
          return MapEntry(category, statsForCategory);
        })
        // Excluir categorías vacías
        .where((entry) => entry.value.isNotEmpty)
        .toList();

    return ListView(
      children: groupedStats.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                entry.key.title,
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            ...entry.value.map((stat) {
              final statTemplate = StatTemplates.getTemplateById(stat.key);
              return ListTile(
                title: Text(statTemplate.title),
                subtitle: Text(statTemplate.description),
                trailing: Text(statTemplate.type.repr(stat.value)),
                isThreeLine: true,
                subtitleTextStyle: const TextStyle(fontSize: 12),
                leadingAndTrailingTextStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }
}
