// seasons_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:futstats/models/season.dart';
import 'package:futstats/screens/season_form_screen.dart';
import 'package:futstats/state/app_state.dart';
import 'package:futstats/widgets/reloadable_list_view.dart';

class SeasonsScreen extends StatelessWidget {
  const SeasonsScreen({
    super.key,
    required this.onSeasonSelected,
  });

  final Function onSeasonSelected;

  @override
  Widget build(BuildContext context) {
    final listController = ReloadableListController<Season>();
    final appState = Provider.of<AppState>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elegir temporada'),
      ),
      body: ReloadableListView(
        emptyListMessage: 'No hay temporadas disponibles',
        controller: listController,
        future: appState.loadSeasons,
        itemBuilder: (context, season) {
          return ListTile(
            title: Text('Temporada ${season.date}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () async {
                    bool shouldReload = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SeasonFormScreen(season: season),
                          ),
                        ) ??
                        false;
                    if (shouldReload) {
                      listController.reload();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    final confirmDelete = await showDialog<bool>(
                      context: context, 
                      builder: (_) => AlertDialog(
                        title: const Text('Eliminar temporada'),
                        content: Text(
                          '¿Eliminar la temporada ${season.date} '
                          'y todos los datos que contiene? '
                          'Esta acción no se puede deshacer.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false), 
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true), 
                            child: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    ) ?? false;
                    if (confirmDelete) {
                      await appState.deleteSeason(season.id);
                      listController.reload();
                    }
                  },
                ),
              ],
            ),
            onTap: () async {
              await appState.setCurrentSeason(season);
              onSeasonSelected();
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
              ) ??
              false;
          if (shouldReload) {
            listController.reload();
          }
        },
      ),
    );
  }
}
