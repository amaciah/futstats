import 'package:flutter/material.dart';
import 'package:futstats/main.dart';
import 'package:futstats/models/season.dart';
import 'package:futstats/screens/season_form_screen.dart';
import 'package:futstats/widgets/reloadable_list_view.dart';

class SeasonsScreen extends StatelessWidget {
  const SeasonsScreen({
    super.key,
    required this.onSeasonSelected,
  });

  final Function onSeasonSelected;

  @override
  Widget build(BuildContext context) {
    final controller = ReloadableListController<Season>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elegir temporada'),
      ),
      body: ReloadableListView(
        emptyListMessage: 'No hay temporadas disponibles',
        controller: controller,
        future: MyApp.seasonRepo.getAllSeasons,
        itemBuilder: (context, season) {
          return ListTile(
            title: Text('Temporada ${season.date}'),
            onTap: () async {
              await MyApp.setSeason(season);
              onSeasonSelected();
            },
            onLongPress: () async {
              bool shouldReload = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => SeasonFormScreen(season: season),
                ),
              ) ?? false;
              if (shouldReload) {
                controller.reload();
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          bool shouldReload = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SeasonFormScreen()),
          ) ?? false;
          if (shouldReload) {
            controller.reload();
          }
        },
      ),
    );
  }
}
