// competitions_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:futstats/models/competition.dart';
import 'package:futstats/screens/competition_form_screen.dart';
import 'package:futstats/state/app_state.dart';
import 'package:futstats/widgets/reloadable_list_view.dart';

class CompetitionsScreen extends StatelessWidget {
  const CompetitionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final listController = ReloadableListController<Competition>();
    final appState = Provider.of<AppState>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Competiciones')),
      body: ReloadableListView<Competition>(
        emptyListMessage: 'No hay competiciones disponibles',
        controller: listController,
        future: () async {
          await appState.loadCompetitions();
          return appState.competitions;
        },
        itemBuilder: (context, competition) => ListTile(
          title: Text(competition.name),
          subtitle: Text(competition.type.label),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final shouldReload = await Navigator.push<bool>(
                    context, 
                    MaterialPageRoute(
                      builder: (_) =>
                          CompetitionFormScreen(competition: competition),
                    ),
                  ) ?? false;
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
                      title: const Text('Eliminar competición'),
                      content: Text(
                        '¿Realmente desea eliminar "${competition.name}"? '
                        'Se eliminarán también todos sus partidos.',
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
                    await appState.deleteCompetition(competition);
                    listController.reload();
                  }
                },
              ),
            ],
          ),
          
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final shouldReload = await Navigator.push<bool>(
            context, 
            MaterialPageRoute(
              builder: (_) => const CompetitionFormScreen(),
            ),
          ) ?? false;
          if (shouldReload) {
            listController.reload();
          }
        },
      ),
    );
  }
}
