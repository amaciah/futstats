import 'package:flutter/material.dart';
import 'package:futstats/models/season.dart';
import 'package:futstats/models/statistic.dart';
import 'package:futstats/models/player.dart';
import 'package:futstats/repositories/statistic_repository.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({required this.player, required this.season, super.key});

  final Player player;
  final Season season;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
      ),
      body: FutureBuilder<Map<String, Statistic>>(
        future: StatisticRepository().getSeasonStats(player.id, season.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No hay estadísticas disponibles.'));
          }

          final stats = snapshot.data!;
          return ListView.builder(
            itemCount: stats.length,
            itemBuilder: (context, index) {
              final statKey = stats.keys.elementAt(index);
              final statistic = stats[statKey]!;
              final statTemplate = StatTemplates.getTemplateById(statistic.id);
              return ListTile(
                title: Text(statTemplate.shortTitle),
                trailing: Text('${statistic.value}'),
              );
            },
          );
        },
      ),
    );
  }
}
