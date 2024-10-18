import 'package:flutter/material.dart';
import 'package:futstats/models/player.dart';
import 'package:futstats/models/season.dart';
import 'package:futstats/pages/add_match_page.dart';
import 'package:futstats/pages/matches_page.dart';
import 'package:futstats/pages/objectives_page.dart';
import 'package:futstats/pages/progress_page.dart';
import 'package:futstats/pages/stats_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  static final Player player = Player(
    id: 'test-player',
    name: 'Test Player',
    position: PlayerPosition.midfielder,
  );
  static final Season season = Season(id: 'test-season', year: '2024-25');

  int _selectedIdx = 0;
  List<Widget> _getPages() {
    return <Widget>[
      const ObjectivesPage(),
      StatsPage(player: player, season: season),
      AddMatchPage(
        player: player,
        season: season,
        onMatchSaved: () {
          // Navegar a la página de partidos
          navigateToPage(4);
        },
      ),
      const ProgressPage(),
      MatchesPage(player: player, season: season),
    ];
  }

  void navigateToPage(int index) {
    setState(() {
      _selectedIdx = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _getPages().elementAt(_selectedIdx),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIdx,
        onDestinationSelected: navigateToPage,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.data_saver_off_outlined),
            label: "Objetivos",
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            label: "Estadísticas",
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            label: "Añadir",
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart),
            label: "Progreso",
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_soccer),
            label: "Partidos",
          ),
        ],
      ),
    );
  }
}
