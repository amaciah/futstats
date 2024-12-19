import 'package:flutter/material.dart';
import 'package:futstats/main.dart';
import 'package:futstats/widgets/empty_reload_message.dart';
import 'package:futstats/widgets/stat_display.dart';
import 'package:futstats/widgets/waiting_indicator.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  void reload() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<Map<String, double>>(
        future: MyApp.statsRepo.getSeasonStatistics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const WaitingIndicator();
          } else if (snapshot.hasError) {
            return EmptyReloadMessage(
              message: 'Se produjo un error al cargar los datos',
              reloadAction: reload,
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return EmptyReloadMessage(
              message: 'No hay estadísticas disponibles',
              reloadAction: reload,
            );
          }

          final stats = snapshot.data!;
          return StatDisplay(stats: stats);
        },
      ),
    );
  }
}
