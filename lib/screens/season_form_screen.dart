// screens/season_form_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:futstats/models/season.dart';
import 'package:futstats/state/app_state.dart';

class SeasonFormScreen extends StatefulWidget {
  const SeasonFormScreen({super.key, this.season});

  final Season? season;

  @override
  State<SeasonFormScreen> createState() => _SeasonFormScreenState();
}

class _SeasonFormScreenState extends State<SeasonFormScreen> {
  // Variables para el formulario
  final _formKey = GlobalKey<FormState>();
  late int _startDate = widget.season?.startDate ?? DateTime.now().year;
  late int _endDate = widget.season?.endDate ?? _startDate + 1;

  Future<void> _saveSeason() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final season = Season(
      id: widget.season?.id,
      startDate: _startDate,
      endDate: _endDate,
    );
    await appState.saveSeason(season);
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.season == null ? 'Nueva temporada' : 'Editar temporada'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Año de inicio
              DropdownButtonFormField<int>(
                initialValue: _startDate,
                decoration: const InputDecoration(labelText: 'Año de inicio'),
                items:
                    List<int>.generate(50, (i) => DateTime.now().year + 1 - i)
                        .map((year) => DropdownMenuItem<int>(
                              value: year,
                              child: Text('$year'),
                            ))
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _startDate = value!;
                  });
                },
                validator: (value) =>
                    value == null ? 'Seleccione un año' : null,
              ),

              // Año de fin
              DropdownButtonFormField<int>(
                initialValue: _endDate,
                decoration: const InputDecoration(labelText: 'Año de fin'),
                items:
                    List<int>.generate(50, (i) => DateTime.now().year + 1 - i)
                        .map((year) => DropdownMenuItem<int>(
                              value: year,
                              child: Text('$year'),
                            ))
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _endDate = value!;
                  });
                },
                validator: (value) => (value == null || value < _startDate)
                    ? 'El año de fin debe ser igual o posterior al de inicio'
                    : null,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            await _saveSeason();
          }
        },
      ),
    );
  }
}
