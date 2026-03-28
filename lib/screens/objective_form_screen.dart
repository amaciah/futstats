// objective_form_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:futstats/models/objective.dart';
import 'package:futstats/models/statistics.dart';
import 'package:futstats/state/app_state.dart';

class ObjectiveFormScreen extends StatefulWidget {
  const ObjectiveFormScreen({super.key, this.objective});

  final Objective? objective;

  @override
  State<ObjectiveFormScreen> createState() => _ObjectiveFormScreenState();
}

class _ObjectiveFormScreenState extends State<ObjectiveFormScreen> {
  final _formKey = GlobalKey<FormState>();
  StatCategory? _selectedCategory;
  late String? _statId = widget.objective?.statId;
  late double? _target = widget.objective?.target;
  late bool _isPositive = widget.objective?.isPositive ?? true;

  // Estadísticas filtradas según categoría seleccionada
  Map<String, StatTemplate> get _filteredStats {
    final allTemplates = StatTemplates.allSeasonTemplates;
    if (_selectedCategory == null) return allTemplates;
    return Map.fromEntries(
      allTemplates.entries.where((template) => 
          template.value.category == _selectedCategory),
    );
  }

  // Plantilla de la estadística seleccionada actualmente
  StatTemplate? get _selectedTemplate =>
      _statId != null ? StatTemplates.allSeasonTemplates[_statId] : null;

  Future<void> _saveObjective() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final objective = Objective(
      id: widget.objective?.id,
      statId: _statId!,
      target: _target!,
      isPositive: _isPositive,
    );
    await appState.saveObjective(objective);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.objective == null ? 'Nuevo objetivo' : 'Editar objetivo',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filtro por categoría
              DropdownButtonFormField<StatCategory?>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Filtrar por categoría',
                  prefixIcon: Icon(Icons.filter_list),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Todas las categorías'),
                  ),
                  ...StatCategory.values.map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category.title),
                      )),
                ], 
                onChanged: (value) => setState(() {
                  _selectedCategory = value;
                  // Limpiar selección si la estadística no está en el filtro
                  if (_statId != null && _filteredStats[_statId] == null) {
                    _statId == null;
                  } 
                }),
              ),
              const SizedBox(height: 8),
              // Estadística
              DropdownButtonFormField<String>(
                initialValue: _statId,
                decoration: const InputDecoration(labelText: 'Estadística'),
                isExpanded: true,
                items: _filteredStats.entries
                    .map((entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value.title),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _statId = value),
                validator: (value) =>
                    value == null ? 'Seleccione una estadística' : null,
              ),
              // Descripción de la estadística seleccionada
              if (_selectedTemplate != null) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    _selectedTemplate!.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              // Objetivo numérico
              TextFormField(
                initialValue: _target?.toString(),
                decoration: InputDecoration(
                  labelText: 'Objetivo',
                  suffixText: _selectedTemplate?.type == StatValueType.percent
                      ? '%'
                      : null,
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onSaved: (value) => _target = double.tryParse(value ?? ''),
                validator: (value) => value == null || value.isEmpty
                    ? 'Introduzca un valor objetivo'
                    : null,
              ),
              const SizedBox(height: 8),
              // Positivo / negativo
              SwitchListTile(
                title: const Text('Objetivo positivo'),
                subtitle: Text(
                  _isPositive
                      ? 'Cumplido al alcanzar o superar el objetivo'
                      : 'Cumplido al mantenerse por debajo del objetivo',
                ),
                value: _isPositive,
                onChanged: (value) => setState(() => _isPositive = value),
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
            await _saveObjective();
          }
        },
      ),
    );
  }
}
