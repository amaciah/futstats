import 'package:flutter/material.dart';
import 'package:futstats/main.dart';
import 'package:futstats/models/match.dart';
import 'package:futstats/screens/match_details_screen.dart';
import 'package:futstats/widgets/match_result_display.dart';
import 'package:futstats/widgets/reloadable_list_view.dart';
import 'package:intl/intl.dart';

class MatchesPage extends StatelessWidget {
  const MatchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ReloadableListController<Match>();
    return Center(
      child: ReloadableListView<Match>(
        emptyListMessage: 'No hay partidos disponibles',
        controller: controller,
        future: MyApp.matchRepo.getAllMatches,
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
                      builder: (context) => MatchDetailsScreen(match: match),
                    ),
                  ) ??
                  false;
              if (shouldReload) {
                controller.reload();
              }
            },
          );
        },
      ),
    );
  }
}
