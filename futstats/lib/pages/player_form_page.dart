import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:futstats/main.dart';
import 'package:futstats/models/player.dart';
import 'package:futstats/pages/seasons_page.dart';
import 'package:intl/intl.dart';

class PlayerFormPage extends StatefulWidget {
  const PlayerFormPage({super.key});

  @override
  State<StatefulWidget> createState() => _PlayerFormPageState();
}

class _PlayerFormPageState extends State<PlayerFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime _birth = DateTime.now();
  PlayerPosition? _position;

  Future<void> _savePlayer() async {
    if (_formKey.currentState!.validate()) {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final player = Player(
        id: userId,
        name: _nameController.text,
        birth: _birth,
        position: _position!,
      );
      MyApp.player = player;
      await MyApp.playerRepo.setPlayer(player);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SeasonsPage()),
      );
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
              InkWell(
                onTap: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    locale: Localizations.localeOf(context),
                    initialDate: _birth,
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      _birth = selectedDate;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(labelText: 'Fecha de nacimiento'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat.yMd(
                              Localizations.localeOf(context).toString())
                          .format(_birth)),
                      Icon(Icons.calendar_month),
                    ],
                  ),
                ),
              ),

              // Posición
              DropdownButtonFormField(
                decoration: InputDecoration(labelText: 'Posición'),
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
        child: Icon(Icons.arrow_forward),
        onPressed: () => _savePlayer(),
      ),
    );
  }
}
