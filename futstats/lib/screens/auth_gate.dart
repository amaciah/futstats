import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as auth_ui;
import 'package:flutter/material.dart';
import 'package:futstats/main.dart';
import 'package:futstats/screens/home_screen.dart';
import 'package:futstats/screens/player_form_screen.dart';
import 'package:futstats/screens/seasons_screen.dart';
import 'package:futstats/widgets/waiting_indicator.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => AuthGateState();
}

class AuthGateState extends State<AuthGate> {
  void rebuild() => setState(() {});

  Future<Widget> _checkPlayerAndSeason(String userId) async {
    // Comprobar si hay jugador asociado al usuario
    final player = await MyApp.playerRepo.getPlayer(userId);
    if (player == null) {
      return PlayerFormScreen(
        icon: Icon(Icons.arrow_forward),
        onPlayerSaved: rebuild,
      );
    }
    MyApp.player = player;

    // Comprobar si el jugador tiene temporada actual
    final season = await player.currentSeason;
    if (season == null) return SeasonsScreen(onSeasonSelected: rebuild);
    await MyApp.setSeason(season);

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
                  '© 2024 Futstats',
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
            future: _checkPlayerAndSeason(userSnapshot.data!.uid),
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
