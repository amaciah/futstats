import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:futstats/main.dart';
import 'package:futstats/models/player.dart';
import 'package:futstats/widgets/date_picker_field.dart';

class PlayerFormScreen extends StatefulWidget {
  const PlayerFormScreen({
    super.key,
    this.player,
    required this.icon,
    required this.onPlayerSaved,
  });

  final Player? player;
  final Icon icon;
  final Function onPlayerSaved;

  @override
  State<StatefulWidget> createState() => _PlayerFormScreenState();
}

class _PlayerFormScreenState extends State<PlayerFormScreen> {
  // Variables para el formulario
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.player?.name);
  late DateTime _birth = widget.player?.birth ?? DateTime.now();
  late PlayerPosition? _position = widget.player?.position;

  void _savePlayer() async {
    if (_formKey.currentState!.validate()) {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final player = Player(
        id: userId,
        name: _nameController.text,
        birth: _birth,
        position: _position!,
      );
      final currentSeason = await widget.player?.currentSeason;
      if (currentSeason != null) {
        await player.setCurrentSeason(currentSeason.id);
      }
      MyApp.player = player;
      MyApp.playerRepo.setPlayer(player);
      widget.onPlayerSaved();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Información del jugador'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Introduzca un nombre'
                    : null,
              ),

              // Fecha de nacimiento
              DatePickerField(
                initialDate: _birth,
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
                labelText: 'Fecha de nacimiento',
                onDateSelected: (selectedDate) {
                  setState(() {
                    _birth = selectedDate;
                  });
                },
              ),

              // Posición
              DropdownButtonFormField(
                value: _position,
                decoration: const InputDecoration(labelText: 'Posición'),
                items: PlayerPosition.values
                    .map((position) => DropdownMenuItem(
                          value: position,
                          child: Text(position.label),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _position = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Seleccione una posición' : null,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: widget.icon,
        onPressed: () => _savePlayer(),
      ),
    );
  }
}
