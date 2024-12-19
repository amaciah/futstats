import 'package:flutter/material.dart';
import 'package:futstats/main.dart';
import 'package:futstats/models/match.dart';
import 'package:futstats/screens/match_form_page.dart';
import 'package:futstats/widgets/match_result_display.dart';
import 'package:futstats/widgets/stat_display.dart';
import 'package:intl/intl.dart';

class MatchDetailsScreen extends StatefulWidget {
  const MatchDetailsScreen({
    super.key,
    required this.match,
  });

  final Match match;

  @override
  State<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> {
  late Match _match;

  @override
  void initState() {
    super.initState();
    _match = widget.match;
  }

  Future<void> _editMatch() async {
    // Navegar a la página de edición
    Match? updatedMatch = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchFormPage(
          match: _match,
          saveMatch: ({required newMatch, oldMatch}) {
            return MyApp.season.updateMatch(
              oldMatch: oldMatch!,
              newMatch: newMatch,
            );
          },
          onMatchSaved: (newMatch) {
            Navigator.pop(context, newMatch);
          },
        ),
      ),
    );

    // Actualizar la página si se modifica el partido
    if (updatedMatch != null) {
      setState(() {
        _match = updatedMatch;
      });
    }
  }

  Future<void> _deleteMatch() async {
    // Mostrar diálogo de confirmación
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar partido'),
        content: const Text('¿Realmente desea eliminar este partido?'),
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

    // Eliminar el partido si el usuario confirma
    if (confirmDelete) {
      await MyApp.season.deleteMatch(_match);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jornada ${_match.matchweek}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editMatch,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteMatch,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mostrar información general del partido
            ListTile(
              title: Text(_match.opponent),
              titleTextStyle: Theme.of(context).textTheme.headlineSmall,
              subtitle: Text(
                  DateFormat.yMd(Localizations.localeOf(context).toString())
                      .format(_match.date)),
              trailing: MatchResultDisplay(match: _match),
            ),
            const Divider(height: 32),

            // Mostrar estadísticas del partido
            Expanded(
              child: StatDisplay(stats: _match.stats),
            ),
          ],
        ),
      ),
    );
  }
}
