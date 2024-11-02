import 'package:flutter/material.dart';
import 'package:futstats/main.dart';
import 'package:futstats/models/match.dart';
import 'package:futstats/models/statistics.dart';
import 'package:futstats/pages/match_details_page.dart';
import 'package:intl/intl.dart';

abstract class MatchFormPage extends StatefulWidget {
  const MatchFormPage({
    super.key,
    this.match,
  });

  // Nulo cuando se crea un partido nuevo
  // Ahorra código para inicializar las variables para el formulario
  final Match? match;
}

class AddMatchPage extends MatchFormPage {
  const AddMatchPage({
    super.key,
    required this.onReturnToHomePage,
  });

  // Como se diseña como parte de la página principal, la navegación debe
  // proporcionarse como método
  final Function onReturnToHomePage;

  @override
  State<MatchFormPage> createState() => _AddMatchPageState();
}

class EditMatchPage extends MatchFormPage {
  const EditMatchPage({
    super.key,
    required Match match,
  }) : _match = match;

  final Match _match;

  @override
  Match get match => _match;

  @override
  State<MatchFormPage> createState() => _EditMatchPageState();
}

class _AddMatchPageState extends _MatchFormPageState {
  @override
  Future<void> _saveMatch() async {
    final newMatch = Match(
      matchweek: _matchweek!,
      date: _date,
      opponent: _opponent!,
      goalsFor: _goalsFor!,
      goalsAgainst: _goalsAgainst!,
      stats: _stats,
    );
    await MyApp.season.addMatch(newMatch);
    _onMatchCreated(newMatch);
  }

  void _onMatchCreated(Match match) {
    // Navegar a la página de detalles del partido
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchDetailsPage(match: match),
      ),
    ).then(
      // Aplicar navegación al volver a la pantalla principal
      (_) => (widget as AddMatchPage).onReturnToHomePage(),
    );
  }
}

class _EditMatchPageState extends _MatchFormPageState {
  @override
  Future<void> _saveMatch() async {
    final match = Match(
      id: widget.match!.id,
      matchweek: _matchweek!,
      date: _date,
      opponent: _opponent!,
      goalsFor: _goalsFor!,
      goalsAgainst: _goalsAgainst!,
      stats: _stats,
    );
    await MyApp.season.updateMatch(
      oldMatch: widget.match!,
      newMatch: match,
    );
    _onMatchUpdated(match);
  }

  void _onMatchUpdated(Match match) {
    Navigator.pop(context, match);
  }
}

abstract class _MatchFormPageState extends State<MatchFormPage> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0; // Paso del formulario

  // Variables para el paso 1
  late int? _matchweek = widget.match?.matchweek;
  late DateTime _date = widget.match?.date ?? DateTime.now();
  late String? _opponent = widget.match?.opponent;
  late int? _goalsFor = widget.match?.goalsFor;
  late int? _goalsAgainst = widget.match?.goalsAgainst;

  // Variables para el paso 2 (estadísticas)
  late final Map<String, double> _stats = widget.match?.stats ??
      {for (var id in StatTemplates.manualStatIds) id: 0};

  // Avanzar al siguiente paso
  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _currentStep++;
      });
    }
  }

  // Retroceder al paso anterior
  void _previousStep() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
    }
    setState(() {
      if (_currentStep > 0) {
        _currentStep--;
      }
    });
  }

  // Guardar el partido en Firestore
  Future<void> _saveMatch();

  // Formulario para el primer paso
  Widget _buildStepOneForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Semana de partido
            DropdownButtonFormField<int>(
              value: _matchweek,
              decoration: const InputDecoration(labelText: 'Semana de partido'),
              items:
                  List<int>.generate(MyApp.season.numMatchweeks, (i) => i + 1)
                      .map((week) => DropdownMenuItem<int>(
                            value: week,
                            child: Text('Semana $week'),
                          ))
                      .toList(),
              onChanged: (value) {
                setState(() {
                  _matchweek = value;
                });
              },
              validator: (value) =>
                  value == null ? 'Seleccione una semana' : null,
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
            InkWell(
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  locale: Localizations.localeOf(context),
                  initialDate: _date,
                  firstDate: DateTime(MyApp.season.startDate),
                  lastDate: DateTime(MyApp.season.endDate + 1),
                );
                if (selectedDate != null) {
                  setState(() {
                    _date = selectedDate;
                  });
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(labelText: 'Fecha'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat.yMd(
                            Localizations.localeOf(context).toString())
                        .format(_date)),
                    Icon(Icons.calendar_month),
                  ],
                ),
              ),
            ),

            // Resultado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Goles a favor
                Expanded(
                  child: TextFormField(
                    initialValue: _goalsFor?.toString() ?? '0',
                    decoration:
                        const InputDecoration(labelText: 'Goles a favor'),
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
      ),
    );
  }

  // Formulario para el segundo paso
  Widget _buildStepTwoForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView.builder(
          itemCount: StatTemplates.manualTemplateList.length,
          itemBuilder: (context, index) {
            var template = StatTemplates.manualTemplateList.elementAt(index);
            return TextFormField(
              decoration: InputDecoration(labelText: template.title),
              keyboardType: TextInputType.number,
              initialValue: template.type.repr(_stats[template.id] ?? 0),
              onChanged: (value) =>
                  _stats[template.id] = double.tryParse(value) ?? 0,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos del partido'),
        leading: _currentStep > 0
            ? IconButton(
                onPressed: _previousStep,
                icon: const Icon(Icons.arrow_back),
              )
            : null,
      ),
      body: _currentStep == 0 ? _buildStepOneForm() : _buildStepTwoForm(),
      floatingActionButton: FloatingActionButton(
        child: Icon(_currentStep == 0 ? Icons.arrow_forward : Icons.save),
        onPressed: () async {
          if (_currentStep == 0) {
            _nextStep();
          } else {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              _saveMatch();
            }
          }
        },
      ),
    );
  }
}
