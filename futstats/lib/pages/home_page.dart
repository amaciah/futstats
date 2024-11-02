import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:futstats/pages/match_form_page.dart';
import 'package:futstats/pages/matches_page.dart';
import 'package:futstats/pages/objectives_page.dart';
import 'package:futstats/pages/progress_page.dart';
import 'package:futstats/pages/stats_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final _auth = FirebaseAuth.instance;

  int _selectedIdx = 0;
  List<Widget> _getPages() {
    return <Widget>[
      const ObjectivesPage(),
      const StatsPage(),
      AddMatchPage(
        onReturnToHomePage: () =>
            navigateToPage(4), // Navegar a la página de partidos
      ),
      const ProgressPage(),
      MatchesPage(
        onReturnToHomePage: () => navigateToPage(4), // Actualizar partidos
      ),
    ];
  }

  void navigateToPage(int index) {
    setState(() {
      _selectedIdx = index;
    });
  }

  Future<void> _signOut(BuildContext context) async {
    await _auth.signOut();
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
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // Encabezado del Drawer con información del usuario
            UserAccountsDrawerHeader(
              accountName: Text(_auth.currentUser?.displayName ?? 'Usuario'),
              accountEmail: Text(_auth.currentUser?.email ?? 'No hay correo'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Theme.of(context).canvasColor,
                child: Text(
                  _auth.currentUser?.email?.substring(0, 0).toUpperCase() ?? '?',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Cerrar sesión'),
              onTap: () => _signOut(context),
            ),
          ],
        ),
      ),
    );
  }
}
