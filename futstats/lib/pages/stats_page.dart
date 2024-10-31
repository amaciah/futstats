import 'package:flutter/material.dart';
import 'package:futstats/main.dart';
import 'package:futstats/widgets/stat_display.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
      ),
      body: FutureBuilder<Map<String, double>>(
        future: MyApp.statsRepo.getSeasonStatistics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay estadísticas disponibles'));
          }

          final stats = snapshot.data!;
          return StatDisplay(stats: stats);
        },
      ),
    );
  }
}
