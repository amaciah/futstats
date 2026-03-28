// match_details_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:futstats/models/competition.dart';
import 'package:futstats/models/match.dart';
import 'package:futstats/screens/match_form_page.dart';
import 'package:futstats/state/app_state.dart';
import 'package:futstats/widgets/match_result_display.dart';
import 'package:futstats/widgets/stat_display.dart';

class MatchDetailsScreen extends StatefulWidget {
  const MatchDetailsScreen({
    super.key,
    required this.match,
    required this.competition,
  });

  final Match match;
  final Competition competition;

  @override
  State<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> {
  late Match _match;
  late bool _matchChanged = false;

  @override
  void initState() {
    super.initState();
    _match = widget.match;
  }

  String get _appBarTitle {
    if (_match.matchweek != null) return 'Jornada ${_match.matchweek}';
    if (_match.round != null) return 'Ronda ${_match.round}';
    return widget.competition.name;
  }

  Future<void> _editMatch(AppState appState) async {
    // Navegar a la página de edición
    Match? updatedMatch = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchFormPage(
          match: _match,
          competition: widget.competition,
          onMatchSaved: (match, competition) {
            Navigator.pop(context, match);
          },
        ),
      ),
    );

    // Actualizar la página si se modifica el partido
    if (updatedMatch != null) {
      setState(() {
        _match = updatedMatch;
        _matchChanged = true;
      });
    }
  }

  Future<void> _deleteMatch(AppState appState) async {
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
      await appState.deleteMatch(_match.id, widget.competition);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) => PopScope<bool>(
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            Navigator.pop(context, _matchChanged);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(_appBarTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editMatch(appState),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteMatch(appState),
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
        ),
      ),
    );
  }
}
