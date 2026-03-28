// matches_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:futstats/models/competition.dart';
import 'package:futstats/models/match.dart';
import 'package:futstats/screens/match_details_screen.dart';
import 'package:futstats/services/repositories/match_repository.dart';
import 'package:futstats/state/app_state.dart';
import 'package:futstats/widgets/match_result_display.dart';
import 'package:futstats/widgets/reloadable_list_view.dart';

class MatchesPage extends StatelessWidget {
  const MatchesPage({super.key});

  Widget _buildMatchList(BuildContext context, AppState appState) {
    final listController = ReloadableListController<Match>();

    if (appState.selectedCompetition == null) {
      return const Center(
        child: Text('Seleccione una competición'),
      );
    }
    final matchRepo = MatchRepository(
      playerId: appState.player!.id,
      seasonId: appState.currentSeason!.id,
      competitionId: appState.selectedCompetition!.id,
    );
    return Center(
      child: ReloadableListView<Match>(
        key: ValueKey(appState.selectedCompetition?.id ?? 'all'),
        emptyListMessage: 'No hay partidos disponibles',
        controller: listController,
        future: matchRepo.getAll,
        itemBuilder: (context, match) {
          return ListTile(
            title: Text(match.opponent),
            subtitle: Text(
                DateFormat.yMd(Localizations.localeOf(context).toString())
                    .format(match.date)),
            trailing: MatchResultDisplay(match: match),
            onTap: () async {
              bool shouldReload = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MatchDetailsScreen(
                        match: match,
                        competition: appState.selectedCompetition!,
                      ),
                    ),
                  ) ?? true;
              if (shouldReload) {
                listController.reload();
              }
            },
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
              onChanged: appState.selectCompetition,
            ),
            Expanded(child: _buildMatchList(context, appState)),
          ],
        );
      },
    );
  }
}
