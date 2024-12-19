import 'package:flutter/material.dart';
import 'package:futstats/main.dart';
import 'package:futstats/models/match.dart';
import 'package:futstats/models/statistics.dart';
import 'package:futstats/widgets/date_picker_field.dart';

class MatchFormPage extends StatefulWidget {
  const MatchFormPage({
    super.key,
    this.match,
    required this.saveMatch,
    required this.onMatchSaved,
    this.appBarLeading,
  });

  // Nulo cuando se crea un partido nuevo
  // Permite inicializar las variables para el formulario
  final Match? match;
  final Future<void> Function({Match? oldMatch, required Match newMatch})
      saveMatch;
  final void Function(Match newMatch) onMatchSaved;
  final Widget? appBarLeading;

  @override
  State<MatchFormPage> createState() => _MatchFormPageState();
}

class _MatchFormPageState extends State<MatchFormPage> {
  // Variables para el formulario
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

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
  Future<void> _saveMatch() async {
    final newMatch = Match(
      id: widget.match?.id,
      matchweek: _matchweek!,
      date: _date,
      opponent: _opponent!,
      goalsFor: _goalsFor!,
      goalsAgainst: _goalsAgainst!,
      stats: _stats,
    );
    await widget.saveMatch(
      oldMatch: widget.match,
      newMatch: newMatch,
    );
    widget.onMatchSaved(newMatch);
  }

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
              items: List<int>.generate(
                      MyApp.season.numMatchweeks, (i) => i + 1)
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
            DatePickerField(
              initialDate: _date,
              firstDate: DateTime(MyApp.season.startDate),
              lastDate: DateTime(MyApp.season.endDate + 1),
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
            : widget.appBarLeading,
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
