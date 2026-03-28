// match_form_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:futstats/models/competition.dart';
import 'package:futstats/models/match.dart';
import 'package:futstats/models/statistics.dart';
import 'package:futstats/state/app_state.dart';
import 'package:futstats/widgets/date_picker_field.dart';
import 'package:futstats/widgets/loading_overlay.dart';

class MatchFormPage extends StatefulWidget {
  const MatchFormPage({
    super.key,
    this.match,
    this.competition,
    required this.onMatchSaved,
    this.appBarLeading,
  });

  // Nulo cuando se crea un partido nuevo
  // Permite inicializar las variables para el formulario
  final Match? match;
  final Competition? competition;
  final void Function(Match newMatch, Competition competition) onMatchSaved;
  final Widget? appBarLeading;

  @override
  State<MatchFormPage> createState() => _MatchFormPageState();
}

class _MatchFormPageState extends State<MatchFormPage> {
  // Variables para el formulario
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isSaving = false; // Para mostrar el indicador de carga

  // Variables para el paso 1 (datos generales)
  late Competition? _competition = widget.competition;
  late int? _matchweek = widget.match?.matchweek;
  late int? _round = widget.match?.round;
  late DateTime _date = widget.match?.date ?? DateTime.now();
  late String? _opponent = widget.match?.opponent;
  late int? _goalsFor = widget.match?.goalsFor;
  late int? _goalsAgainst = widget.match?.goalsAgainst;

  // Variables para el paso 2+ (estadísticas por categoría)
  late final Map<String, double> _stats = widget.match?.stats ??
      {for (var id in StatTemplates.manualStatIds) id: 0};
  final List<StatCategory> _categories = StatCategory.values;

  // Guardar el partido en Firestore
  Future<void> _saveMatch(AppState appState) async {
    setState(() => _isSaving = true);

    try {
      final match = Match(
        id: widget.match?.id,
        matchweek: _competition!.requiresMatchweek ? _matchweek : null,
        round: _competition!.requiresRound ? _round : null,
        date: _date,
        opponent: _opponent!,
        goalsFor: _goalsFor!,
        goalsAgainst: _goalsAgainst!,
        stats: _stats,
      );
      await appState.saveMatch(match, _competition!);
      widget.onMatchSaved(match, _competition!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar el partido')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // Datos generales
  Step _buildGeneralInfoStep(AppState appState) {
    // Buscar instancia del dropdown que coincide por ID
    final competitionInList = appState.competitions
        .where((competition) => competition.id == _competition?.id)
        .firstOrNull;

    return Step(
      title: const Text('Datos generales'),
      isActive: _currentStep == 0,
      state: _currentStep > 0 ? StepState.editing : StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Competición (deshabilitado al editar para no romper integridad de datos)
          DropdownButtonFormField<Competition>(
            initialValue: competitionInList,
            decoration: const InputDecoration(labelText: 'Competición'),
            items: appState.competitions
                .map((competition) => DropdownMenuItem(
                  value: competition, 
                  child: Text(competition.name),
                ))
                .toList(),
            onChanged: widget.match != null
                ? null
                : (value) => setState(() {
                      _competition = value;
                      _matchweek = null;
                      _round = null;
                    }),
            validator: (value) => 
                value == null ? 'Seleccione una competición' : null,

          ),

          // Jornada
          if (_competition?.requiresMatchweek == true)
            DropdownButtonFormField<int>(
              initialValue: _matchweek,
              decoration: const InputDecoration(labelText: 'Jornada'),
              items: List.generate(
                _competition!.numMatchweeks ?? 38, 
                (i) => DropdownMenuItem(
                  value: i + 1,
                  child: Text('Jornada ${i + 1}'),
                ),
              ),
              onChanged: (value) => setState(() => _matchweek = value),
              validator: (value) =>
                  value == null ? 'Seleccione una jornada' : null,
            ),

          // Ronda
          if (_competition?.requiresRound == true)
            DropdownButtonFormField<int>(
              initialValue: _round,
              decoration: const InputDecoration(labelText: 'Ronda'),
              items: List.generate(
                _competition!.numRounds ?? 8, 
                (i) => DropdownMenuItem(
                  value: i + 1,
                  child: Text('Ronda ${i + 1}'),
                ),
              ),
              onChanged: (value) => setState(() => _round = value),
              validator: (value) =>
                  value == null ? 'Seleccione una ronda' : null,
            ),

          // Oponente
          TextFormField(
            initialValue: _opponent,
            decoration: const InputDecoration(labelText: 'Oponente'),
            onSaved: (value) => _opponent = value,
            validator: (value) =>
                value!.isEmpty ? 'Introduzca el nombre del oponente' : null,
          ),

          // Fecha
          DatePickerField(
            initialDate: _date,
            firstDate: DateTime(_date.year - 5),
            lastDate: DateTime(_date.year + 5),
            labelText: 'Fecha',
            onDateSelected: (selectedDate) {
              setState(() {
                _date = selectedDate;
              });
            },
          ),

          // Resultado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Goles a favor
              Expanded(
                child: TextFormField(
                  initialValue: _goalsFor?.toString() ?? '0',
                  decoration: const InputDecoration(labelText: 'Goles a favor'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _goalsFor = int.tryParse(value ?? '0'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Introduzca los goles a favor'
                      : null,
                ),
              ),

              const SizedBox(width: 16),

              // Goles en contra
              Expanded(
                child: TextFormField(
                  initialValue: _goalsAgainst?.toString() ?? '0',
                  decoration:
                      const InputDecoration(labelText: 'Goles en contra'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) =>
                      _goalsAgainst = int.tryParse(value ?? '0'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Introduzca los goles en contra'
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Step _buildStatsStep(StatCategory category) {
    final statsByCategory = StatTemplates.manualTemplateList
        .where((template) => template.category == category)
        .toList();

    return Step(
      title: Text(category.title),
      isActive: _categories.indexOf(category) + 1 == _currentStep,
      state: _currentStep > _categories.indexOf(category) + 1
          ? StepState.editing
          : StepState.indexed,
      content: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(), // Bloquear scroll
        itemCount: statsByCategory.length,
        itemBuilder: (context, index) {
          var template = statsByCategory[index];
          return ListTile(
            title: Text(template.title),
            subtitle: Text(template.description),
            isThreeLine: true,
            trailing: SizedBox(
              width: 36,
              child: TextFormField(
                initialValue: template.type.repr(_stats[template.id] ?? 0),
                keyboardType: TextInputType.number,
                onChanged: (value) =>
                    _stats[template.id] = double.tryParse(value) ?? 0,
                textAlign: TextAlign.right,
              ),
            ),
          );
        },
      ),
    );
  }

  Step _buildConfirmStep() {
    return Step(
      title: const Text('Guardar partido'),
      isActive: _currentStep == _categories.length + 1,
      state: StepState.indexed,
      content: const Center(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) => LoadingOverlay(
        isLoading: _isSaving,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Datos del partido'),
            leading: widget.appBarLeading,
          ),
          body: Form(
            key: _formKey,
            child: Stepper(
              currentStep: _currentStep,
              onStepContinue: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  setState(() {
                    if (_currentStep <= _categories.length) {
                      _currentStep++;
                    } else {
                      _saveMatch(appState);
                    }
                  });
                }
              },
              onStepCancel: () {
                _formKey.currentState?.save();
                if (_currentStep > 0) {
                  setState(() => _currentStep--);
                }
              },
              onStepTapped: (index) {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  setState(() => _currentStep = index);
                }
              },
              steps: [
                _buildGeneralInfoStep(appState),
                ..._categories.map(_buildStatsStep),
                _buildConfirmStep(),
              ],
              controlsBuilder: (context, details) {
                return Padding(
                  padding: EdgeInsets.only(top: 32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: _currentStep > 0 ? details.onStepCancel : null,
                        label: const Text('Anterior'),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      FilledButton.icon(
                        onPressed: _isSaving ? null : details.onStepContinue,
                        label: _currentStep == _categories.length + 1
                            ? const Text('Guardar')
                            : const Text('Siguiente'),
                        icon: _currentStep == _categories.length + 1
                            ? const Icon(Icons.save)
                            : const Icon(Icons.arrow_forward),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
