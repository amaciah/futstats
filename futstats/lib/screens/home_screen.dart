import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:futstats/main.dart';
import 'package:futstats/screens/match_details_screen.dart';
import 'package:futstats/screens/match_form_page.dart';
import 'package:futstats/screens/matches_page.dart';
import 'package:futstats/screens/objectives_page.dart';
import 'package:futstats/screens/player_form_screen.dart';
import 'package:futstats/screens/progress_page.dart';
import 'package:futstats/screens/seasons_screen.dart';
import 'package:futstats/screens/stats_page.dart';
import 'package:futstats/screens/auth_gate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;

  // GlobalKey para controlar el estado del Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedIdx = 0;

  void _navigateToPage(int index) {
    setState(() {
      _selectedIdx = index;
    });
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const MatchesPage();
      case 1:
        return const StatsPage();
      case 2:
        return MatchFormPage(
          saveMatch: ({required newMatch, oldMatch}) {
            return MyApp.season.addMatch(newMatch);
          },
          onMatchSaved: (newMatch) async {
            // Navegar a la página de detalles de partido
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MatchDetailsScreen(match: newMatch),
              ),
            );
            // Navegar a la página de partidos
            _navigateToPage(0);
          },
          appBarLeading: IconButton(
            onPressed: _openMenu,
            icon: const Icon(Icons.menu),
          ),
        );
      case 3:
        return const ProgressPage();
      case 4:
        return const ObjectivesPage();
      default:
        return const MatchesPage();
    }
  }

  AppBar? _getAppBar(int index) {
    switch (index) {
      case 0:
        return AppBar(title: const Text('Partidos'));
      case 1:
        return AppBar(title: const Text('Estadísticas'));
      case 2:
        return null; // MatchFormPage tiene su propia AppBar
      case 3:
        return AppBar(title: const Text('Progreso'));
      case 4:
        return AppBar(title: const Text('Objetivos'));
      default:
        return AppBar(title: const Text('Futstats'));
    }
  }

  Future<void> _signOut(BuildContext context) async {
    await _auth.signOut();
  }

  void _openMenu() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _closeMenu() {
    _scaffoldKey.currentState?.closeDrawer();
  }

  void _reloadAuthGate() {
    final authGateState = context.findAncestorStateOfType<AuthGateState>();
    authGateState?.rebuild();
  }

  void _onReturnFromMenuAction() {
    Navigator.pop(context);
    _reloadAuthGate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _getAppBar(_selectedIdx),
      body: Center(
        child: _getPage(_selectedIdx),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIdx,
        onDestinationSelected: _navigateToPage,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.sports_soccer),
            label: "Partidos",
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
            enabled: false,
          ),
          NavigationDestination(
            icon: Icon(Icons.data_saver_off_outlined),
            label: "Objetivos",
            enabled: false,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // Encabezado del Drawer con información del usuario
            UserAccountsDrawerHeader(
              accountName: Text(_auth.currentUser?.displayName ?? 'Usuario'),
              accountEmail: Text(_auth.currentUser?.email ?? 'No hay correo'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColorDark,
                child: Text(
                  _auth.currentUser?.email?.substring(0, 1).toUpperCase() ??
                      '?',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Datos del jugador'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlayerFormScreen(
                      player: MyApp.player,
                      icon: const Icon(Icons.save),
                      onPlayerSaved: _onReturnFromMenuAction,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Temporada'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SeasonsScreen(
                      onSeasonSelected: _onReturnFromMenuAction,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () => _signOut(context),
            ),
          ],
        ),
      ),
    );
  }
}
