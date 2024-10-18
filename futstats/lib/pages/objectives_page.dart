import 'package:flutter/material.dart';
import 'package:futstats/widgets/card_section.dart';

class ObjectivesPage extends StatefulWidget {
  const ObjectivesPage({super.key});

  @override
  State<ObjectivesPage> createState() => _ObjectivesPageState();
}

class _ObjectivesPageState extends State<ObjectivesPage> {
  // Tamaño de las tarjetas por sección
  // 0: small, 1: medium, 2: large
  Map<String, int> sectionCardSizes = {
    "Resumen": 0,
    "Defensa": 1,
  };

  // Datos de ejemplo
  List<Map<String, dynamic>> summaryObjectives = [
    {
      'title': "Partidos",
      'stat': 13,
      'target': 30,
      'isPositive': true,
    },
    {
      'title': "Goles",
      'stat': 2,
      'target': 2,
      'isPositive': true,
    },
    {
      'title': "Asistencias",
      'stat': 4,
      'target': 15,
      'isPositive': true,
    },
    {
      'title': "Pases completados",
      'stat': 127,
      'target': 300,
      'isPositive': true,
    },
    {
      'title': "Entradas exitosas",
      'stat': 47,
      'target': 120,
      'isPositive': true,
    },
    {
      'title': "Acciones defensivas",
      'stat': 34,
      'target': 90,
      'isPositive': true,
    },
  ];

  List<Map<String, dynamic>> defenseObjectives = [
    {
      'title': "Entradas exitosas",
      'stat': 47,
      'target': 120,
      'isPositive': true,
    },
    {
      'title': "Acciones defensivas",
      'stat': 34,
      'target': 90,
      'isPositive': true,
    },
    {
      'title': "Duelos perdidos",
      'stat': 43,
      'target': 120,
      'isPositive': false,
    },
    {
      'title': "Tarjetas recibidas",
      'stat': 7,
      'target': 15,
      'isPositive': false,
    },
    {
      'title': "Errores que llevan a gol",
      'stat': 3,
      'target': 2,
      'isPositive': false,
    },
  ];

  // Cambiar tamaño de las tarjetas en una sección
  void _changeCardSize(String section) {
    setState(() {
      sectionCardSizes[section] = (sectionCardSizes[section]! + 1) % 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Futstats"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CardSection(
                sectionTitle: "Resumen",
                objectives: summaryObjectives,
                cardSize: sectionCardSizes["Resumen"]!,
                onChangeCardSize: () => _changeCardSize("Resumen"),
                color: Colors.blue,
              ),
              CardSection(
                sectionTitle: "Defensa",
                objectives: defenseObjectives,
                cardSize: sectionCardSizes["Defensa"]!,
                onChangeCardSize: () => _changeCardSize("Defensa"),
                color: Colors.purple,
              ),
              // TODO: añadir secciones
            ],
          ),
        ),
      ),
    );
  }
}
