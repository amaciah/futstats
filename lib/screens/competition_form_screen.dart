// competition_form_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:futstats/models/competition.dart';
import 'package:futstats/state/app_state.dart';

class CompetitionFormScreen extends StatefulWidget {
  const CompetitionFormScreen({
    super.key,
    this.competition,
  });

  final Competition? competition;

  @override
  State<CompetitionFormScreen> createState() => _CompetitionFormScreenState();
}

class _CompetitionFormScreenState extends State<CompetitionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late CompetitionType _type = widget.competition?.type ?? CompetitionType.friendly;
  late String? _name = widget.competition?.name;
  late int? _numMatchweeks = widget.competition?.numMatchweeks;
  late int? _numRounds = widget.competition?.numRounds;
  late bool _hasGroups = widget.competition?.hasGroups ?? false;
  late bool _hasKnockouts = widget.competition?.hasKnockouts ?? false;

  Future<void> _saveCompetition() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final competition = Competition(
      id: widget.competition?.id,
      name: _name!,
      type: _type,
      numMatchweeks: (_type.isLeague || _type.isTournament && _hasGroups) ? _numMatchweeks : null,
      numRounds: (_type.isCup || _type.isTournament) ? _numRounds : null,
      hasGroups: _type.isTournament ? _hasGroups : false,
      hasKnockouts: _type.isTournament ? _hasKnockouts : false,
      stats: widget.competition?.stats,
    );
    await appState.saveCompetition(competition);
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.competition == null ? 'Nueva competición' : 'Editar competición',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Nombre
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Nombre'),
                onSaved: (value) => _name = value,
                validator: (value) => 
                    value == null || value.isEmpty ? 'Introduzca un nombre' : null,
              ),
              const SizedBox(height: 8),
              // Tipo
              DropdownButtonFormField<CompetitionType>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: CompetitionType.values
                    .map((type) => DropdownMenuItem(value: type, child: Text(type.label)))
                    .toList(),
                onChanged: (value) => setState(() {
                  _type = value!;
                  // Resetear campos condicionales al cambiar tipo
                  _numMatchweeks = null;
                  _numRounds = null;
                  _hasGroups = false;
                  _hasKnockouts = false;
                }),
              ),
              const SizedBox(height: 8),
              // Jornadas (liga o torneo con fase de grupos)
              if (_type.isLeague || _type.isTournament && _hasGroups)
                TextFormField(
                  key: const ValueKey('matchweeks'),
                  initialValue: _numMatchweeks?.toString(),
                  decoration: const InputDecoration(labelText: 'Número de jornadas'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _numMatchweeks = int.tryParse(value ?? ''),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Introduzca el número de jornadas'
                      : null,
                ),
              // Rondas (copa o torneo)
              if (_type.isCup || _type.isTournament)
                TextFormField(
                  key: const ValueKey('rounds'),
                  initialValue: _numRounds?.toString(),
                  decoration: const InputDecoration(labelText: 'Número de rondas'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _numRounds = int.tryParse(value ?? ''),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Introduzca el número de rondas'
                      : null,
                ),
              // Opciones de torneo
              if (_type.isTournament) ...[
                SwitchListTile(
                  title: const Text('Tiene fase de grupos'),
                  value: _hasGroups, 
                  onChanged: (value) => setState(() => _hasGroups = value),
                ),
                SwitchListTile(
                  title: const Text('Tiene eliminatorias'),
                  value: _hasKnockouts, 
                  onChanged: (value) => setState(() => _hasKnockouts = value),
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            await _saveCompetition();
          }
        },
      ),
    );
  }
}
