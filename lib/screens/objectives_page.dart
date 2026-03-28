// objectives_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:futstats/models/objective.dart';
import 'package:futstats/models/statistics.dart';
import 'package:futstats/screens/objective_form_screen.dart';
import 'package:futstats/state/app_state.dart';
import 'package:futstats/widgets/card_section.dart';
import 'package:futstats/widgets/waiting_indicator.dart';

class ObjectivesPage extends StatefulWidget {
  const ObjectivesPage({super.key});

  @override
  State<ObjectivesPage> createState() => _ObjectivesPageState();
}

class _ObjectivesPageState extends State<ObjectivesPage> {
  Future<Map<String, double>>? _statsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Regenerar solo cuando cambia la competición seleccionada
    _statsFuture = context.read<AppState>().getStatsFromSelectedCompetition();
  }

  // Tamaño de las tarjetas por sección
  // 0: small, 1: medium, 2: large
  Map<String, int> sectionCardSizes = {};

  // Colores por categoría
  static const Map<StatCategory, Color> _categoryColors = {
    StatCategory.participation: Colors.blue,
    StatCategory.attack: Colors.orange,
    StatCategory.defense: Colors.purple,
    StatCategory.possession: Colors.teal,
    StatCategory.goalkeeping: Colors.green,
  };

  // Cambia el tamaño de las tarjetas en una sección
  void _changeCardSize(StatCategory category) {
    setState(() {
      final key = category.name;
      sectionCardSizes[key] = ((sectionCardSizes[key] ?? 0) + 1) % 3;
    });
  }

  // Agrupa objetivos por categoría de estadística
  Map<StatCategory, List<Objective>> _groupByCategory(List<Objective> objectives) {
    final grouped = <StatCategory, List<Objective>>{};
    for (final objective in objectives) {
      final template = StatTemplates.allSeasonTemplates[objective.statId];
      if (template == null) continue;
      grouped.putIfAbsent(template.category, () => []).add(objective);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return FutureBuilder<Map<String, double>>(
          future: _statsFuture, 
          builder: (context, statsSnapshot) {
            if (statsSnapshot.connectionState == ConnectionState.waiting) {
              return const WaitingIndicator();
            }
            final stats = statsSnapshot.data ?? {};
            final objectives = appState.objectives;
            final grouped = _groupByCategory(objectives);

            return Scaffold(
              body: objectives.isEmpty
                  ? const Center(
                      child: Text('No hay objetivos disponibles'),
                    )
                  : SingleChildScrollView(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: grouped.entries.map((entry) {
                        // Obtener datos de objetivos de cada sección
                        final category = entry.key;
                        final categoryObjectives = entry.value;
                        final cardSizeKey = category.name;

                        // Adaptar a formato para CardSection
                        final objectiveData = categoryObjectives.map((objective) {
                          final template = StatTemplates.allSeasonTemplates[objective.statId]!;
                          return {
                            'title': template.shortTitle,
                            'stat': stats[objective.statId] ?? 0.0,
                            'target': objective.target,
                            'isPositive': objective.isPositive,
                            'statType': template.type,
                          };
                        }).toList();

                        return CardSection(
                          sectionTitle: category.title, 
                          objectives: objectiveData, 
                          cardSize: sectionCardSizes[cardSizeKey] ?? 0, 
                          onChangeCardSize: () => _changeCardSize(category), 
                          color: _categoryColors[category] ?? Colors.blue,
                          onObjectiveTap: (data) async {
                            // Encontrar objetivo original por ID
                            final objective = appState.objectives
                                .firstWhere((objective) => objective.id == data['id']);
                            final saved = await Navigator.push<bool>(
                              context, 
                              MaterialPageRoute(
                                builder: (_) => ObjectiveFormScreen(objective: objective),
                              ),
                            );
                            if (saved == true) setState(() {});
                          },
                          onObjectiveLongPress: (data) async {
                            final objective = appState.objectives
                                .firstWhere((objective) => objective.id == data['id']);
                            final template = StatTemplates.allSeasonTemplates[objective.statId]!;
                            final confirmDelete = await showDialog<bool>(
                              context: context, 
                              builder: (_) => AlertDialog(
                                title: const Text('Eliminar objetivo'),
                                content: Text('¿Eliminar el objetivo de ${template.title}?'),
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
                              await appState.deleteObjective(objective.id);
                              setState(() {});
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
              floatingActionButton: FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () async {
                  final saved = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ObjectiveFormScreen(),
                    ),
                  ) ?? false;
                  if (saved) setState(() {});
                },
              ),
            );
          },
        );
      },
    );
  }
}
