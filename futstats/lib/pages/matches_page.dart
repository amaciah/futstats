import 'package:flutter/material.dart';
import 'package:futstats/models/match.dart';
import 'package:futstats/models/player.dart';
import 'package:futstats/models/season.dart';
import 'package:futstats/repositories/match_repository.dart';

class MatchesPage extends StatelessWidget {
  const MatchesPage({required this.player, required this.season, super.key});

  final Player player;
  final Season season;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                subtitle: Text('Fecha: ${match.date.toIso8601String()}'),
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
