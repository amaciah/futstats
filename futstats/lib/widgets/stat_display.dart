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
    return ListView.builder(
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final statId = stats.keys.elementAt(index);
        final statValue = stats[statId] ?? 0;
        final statTemplate = StatTemplates.getTemplateById(statId);
        return ListTile(
          title: Text(statTemplate.title),
          subtitle: Text(statTemplate.description),
          trailing: Text(statTemplate.type.repr(statValue)),
          isThreeLine: true,
          subtitleTextStyle: const TextStyle(fontSize: 12),
          leadingAndTrailingTextStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}
