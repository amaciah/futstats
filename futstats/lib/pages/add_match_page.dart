import 'package:flutter/material.dart';
import 'package:futstats/models/match.dart';
import 'package:futstats/models/player.dart';
import 'package:futstats/models/season.dart';
import 'package:futstats/repositories/match_repository.dart';
import 'package:intl/intl.dart';

class AddMatchPage extends StatefulWidget {
  const AddMatchPage({
    required this.player,
    required this.season,
    this.match,
    required this.onMatchSaved,
    super.key,
  });

  final Player player;
  final Season season;
  final Match? match; // Si es nulo, se crea un partido nuevo
  final Function onMatchSaved;

  @override
  State<AddMatchPage> createState() => _AddMatchPageState();
}

class _AddMatchPageState extends State<AddMatchPage> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0; // Paso del formulario

  // Variables para el paso 1
  int? _matchweek;
  String? _opponent;
  DateTime _date = DateTime.now();

  // Variables para el paso 2 (estadísticas)
  final Map<String, double> _stats = {};

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
  void _saveMatch() {
    MatchRepository().setMatch(
      widget.player.id,
      widget.season.id,
      Match(
        matchweek: _matchweek!,
        date: _date,
        opponent: _opponent!,
        stats: _stats,
      ),
    );

    widget.onMatchSaved();
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
              items: List<int>.generate(38, (i) => i + 1)
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
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Goles'),
              keyboardType: TextInputType.number,
              initialValue: _stats['goals']?.toInt().toString() ?? '0',
              onSaved: (value) => _stats['goals'] = double.parse(value!),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir partido'),
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
        onPressed: () {
          if (_currentStep == 0) {
            _nextStep();
          } else {
            // Guardar el partido
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
