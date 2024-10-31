import 'package:flutter/material.dart';
import 'package:futstats/main.dart';
import 'package:futstats/models/match.dart';
import 'package:futstats/pages/match_form_page.dart';
import 'package:futstats/widgets/stat_display.dart';
import 'package:intl/intl.dart';

class MatchDetailsPage extends StatelessWidget {
  const MatchDetailsPage({
    super.key,
    required this.match,
  });

  final Match match;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partido'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              Match updatedMatch = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditMatchPage(
                    match: match,
                  ),
                ),
              );
              // Reemplazar página actual con detalles de partido actualizados
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MatchDetailsPage(
                    match: updatedMatch,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              bool confirmDelete = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Eliminar partido'),
                  content:
                      const Text('¿Realmente desea eliminar este partido?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
              );

              if (confirmDelete) {
                await MyApp.season.deleteMatch(match);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mostrar información general del partido
            Text(
              'Oponente: ${match.opponent}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            // const SizedBox(height: 8),
            Text(
              DateFormat.yMd(Localizations.localeOf(context).toString())
                  .format(match.date),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            // const SizedBox(height: 8),
            Text(
              '${match.goalsFor} - ${match.goalsAgainst}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(height: 32),

            // Mostrar estadísticas del partido
            Expanded(
              child: StatDisplay(stats: match.stats),
            ),
          ],
        ),
      ),
    );
  }
}
