import 'package:flutter/material.dart';
import 'package:futstats/main.dart';
import 'package:futstats/models/season.dart';

class SeasonFormPage extends StatefulWidget {
  const SeasonFormPage({super.key});

  @override
  State<SeasonFormPage> createState() => _SeasonFormPageState();
}

class _SeasonFormPageState extends State<SeasonFormPage> {
  final _formKey = GlobalKey<FormState>();
  late int _startDate = DateTime.now().year;
  late int _endDate = _startDate + 1;
  int? _matchweeks;

  Future<void> _saveSeason() async {
    final season = Season(
      startDate: _startDate,
      endDate: _endDate,
      numMatchweeks: _matchweeks!,
    );
    MyApp.season = season;
    await MyApp.seasonRepo.setSeason(season);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Información de la temporada'),
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
                value: _startDate,
                decoration: const InputDecoration(labelText: 'Año de inicio'),
                items: List<int>.generate(50, (i) => DateTime.now().year - i)
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
                value: _endDate,
                decoration: const InputDecoration(labelText: 'Año de fin'),
                items: List<int>.generate(50, (i) => DateTime.now().year + 1 - i)
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
                    ? 'Seleccione un año válido'
                    : null,
              ),

              // Número de jornadas
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nº de jornadas'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _matchweeks = int.tryParse(value ?? '0'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Introduzca el número de jornadas'
                    : null,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.arrow_forward),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            _saveSeason();
          }
        },
      ),
    );
  }
}
