// auth_gate.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as auth_ui;
import 'package:flutter/material.dart';
import 'package:futstats/services/migration_service.dart';
import 'package:provider/provider.dart';

import 'package:futstats/screens/home_screen.dart';
import 'package:futstats/screens/player_form_screen.dart';
import 'package:futstats/screens/seasons_screen.dart';
import 'package:futstats/state/app_state.dart';
import 'package:futstats/widgets/waiting_indicator.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => AuthGateState();
}

class AuthGateState extends State<AuthGate> {
  void rebuild() => setState(() {});

  Future<Widget> _checkPlayerAndSeason(BuildContext context, String userId) async {
    final appState = Provider.of<AppState>(context, listen: false);

    // Comprobar si hay jugador asociado al usuario
    final player = await appState.getPlayerById(userId);
    if (player == null) {
      return PlayerFormScreen(
        icon: const Icon(Icons.arrow_forward),
        onPlayerSaved: rebuild,
      );
    }
    await appState.setActivePlayer(player);

    // Ejecutar migraciones antes de cargar la temporada actual
    await MigrationService().migrateIfNeeded(player.id);

    // Comprobar si el jugador tiene temporada actual
    final season = await appState.getCurrentSeasonFromDB();
    if (season == null) {
      return SeasonsScreen(onSeasonSelected: rebuild);
    }
    await appState.setCurrentSeason(season);

    // Ir a la página principal
    return const HomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const WaitingIndicator();
        }
        // No hay usuario
        if (!userSnapshot.hasData) {
          // Mostrar página de inicio de sesión
          return auth_ui.SignInScreen(
            providers: [
              auth_ui.EmailAuthProvider(),
            ],
            footerBuilder: (context, action) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '© 2026 Futstats',
                  style: TextStyle(fontSize: 12),
                ),
              );
            },
            showPasswordVisibilityToggle: true,
          );
        }
        // Hay usuario
        else {
          return FutureBuilder<Widget>(
            future: _checkPlayerAndSeason(context, userSnapshot.data!.uid),
            builder: (context, widgetSnapshot) {
              if (widgetSnapshot.connectionState == ConnectionState.waiting) {
                return const WaitingIndicator();
              }
              if (widgetSnapshot.hasError) {
                return Center(
                  child: Text('Ocurrió un error: ${widgetSnapshot.error}'),
                );
              }
              return widgetSnapshot.data!;
            },
          );
        }
      },
    );
  }
}
