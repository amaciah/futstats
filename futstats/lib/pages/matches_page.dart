import 'package:flutter/material.dart';
import 'package:futstats/models/match.dart';
import 'package:futstats/models/player.dart';
import 'package:futstats/models/season.dart';
import 'package:futstats/repositories/match_repository.dart';
import 'package:intl/intl.dart';

class MatchesPage extends StatelessWidget {
  const MatchesPage({required this.player, required this.season, super.key});

  final Player player;
  final Season season;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partidos'),
      ),
      body: FutureBuilder<List<Match>>(
        future: MatchRepository().getAllMatches(player.id, season.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay partidos disponibles.'));
          }

          final matches = snapshot.data!;
          return ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];
              return ListTile(
                title: Text(match.opponent),
                subtitle: Text(
                    DateFormat.yMd(Localizations.localeOf(context).toString())
                        .format(match.date)),
                onTap: () {
                  //TODO: Navegar a la vista de detalles del partido
                },
              );
            },
          );
        },
      ),
    );
  }
}
