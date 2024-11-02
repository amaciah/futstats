import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as ui;
import 'package:flutter/material.dart';
import 'package:futstats/main.dart';
import 'package:futstats/models/player.dart';
import 'package:futstats/models/season.dart';
import 'package:futstats/pages/home_page.dart';
import 'package:futstats/pages/player_form_page.dart';
import 'package:futstats/pages/seasons_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasData) {
          return FutureBuilder<Player?>(
            future: MyApp.playerRepo.getPlayer(snapshot.data!.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData) {
                // El jugador existe
                MyApp.player = snapshot.data!;
                // Obtener temporada actual
                return FutureBuilder<Season?>(
            future: snapshot.data!.currentSeason,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData) {
                // La temporada actual existe
                MyApp.season = snapshot.data!;
                // Ir a la página principal
                return const HomePage();
              } else {
                return const SeasonsPage();
              }
            },
          );

              } else {
                return const PlayerFormPage();
              }
            },
          );
        } else {
          return ui.SignInScreen(
            providers: [
              ui.EmailAuthProvider(),
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
      },
    );
  }
}
