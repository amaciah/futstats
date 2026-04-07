// screens/stats_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:futstats/models/competition.dart';
import 'package:futstats/state/app_state.dart';
import 'package:futstats/widgets/empty_reload_message.dart';
import 'package:futstats/widgets/stat_display.dart';
import 'package:futstats/widgets/waiting_indicator.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  Future<Map<String, double>>? _statsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cargar estadísticas al cargar la página o cambiar de competición
    _statsFuture = context.read<AppState>().getStatsFromSelectedCompetition();
  }

  void reload() {
    setState(() {});
  }

  Widget _buildStatDisplay(BuildContext context, AppState appState) {
    return Center(
        child: FutureBuilder<Map<String, double>>(
          future: _statsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const WaitingIndicator();
            } else if (snapshot.hasError) {
              return EmptyReloadMessage(
                message: 'Se produjo un error al cargar los datos',
                reloadAction: reload,
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return EmptyReloadMessage(
                message: 'No hay estadísticas disponibles',
                reloadAction: reload,
              );
            }

            final stats = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(8),
              child: StatDisplay(stats: stats),
            );
          },
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Column(
          children: [
            DropdownButton<Competition>(
              value: appState.competitions
                  .where((competition) => competition.id == appState.selectedCompetition?.id)
                  .firstOrNull,
              hint: const Text('Seleccione una competición'),
              items: [
                DropdownMenuItem(value: null, child: const Text('Todas')),
                ...appState.competitions.map(
                  (competition) => DropdownMenuItem<Competition>(
                    value: competition,
                    child: Text(competition.name),
                  ),
                )
              ],
              onChanged: (competition) {
                appState.selectCompetition(competition);
                setState(() {
                  // Forzar recarga de estadísticas al cambiar de competición
                  _statsFuture = appState.getStatsFromSelectedCompetition();
                });
              },
            ),
            Expanded(child: _buildStatDisplay(context, appState)),
          ],
        );
      }
    );
  }
}
