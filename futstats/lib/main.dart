import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:futstats/firebase_options.dart';
import 'package:futstats/models/player.dart';
import 'package:futstats/models/season.dart';
import 'package:futstats/pages/auth_page.dart';
import 'package:futstats/repositories/match_repository.dart';
import 'package:futstats/repositories/objective_repository.dart';
import 'package:futstats/repositories/player_repository.dart';
import 'package:futstats/repositories/season_repository.dart';
import 'package:futstats/repositories/statistic_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static Player player = Player(
    id: 'test-player',
    name: 'Test Player',
    birth: DateTime.now(),
    position: PlayerPosition.midfielder,
  );
  static Season season = Season(
    id: 'test-season',
    startDate: 2023,
    endDate: 2024,
    numMatchweeks: 10,
  );
  static PlayerRepository get playerRepo => PlayerRepository();
  static SeasonRepository get seasonRepo =>
      SeasonRepository(playerId: player.id);
  static MatchRepository get matchRepo => MatchRepository(seasonId: season.id);
  static StatisticRepository get statsRepo =>
      StatisticRepository(seasonId: season.id);
  static ObjectiveRepository get objRepo =>
      ObjectiveRepository(seasonId: season.id);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fútbol Stats',
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FirebaseUILocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
      ],
      theme: ThemeData(
        // This is the theme of your application.
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const AuthPage(),
    );
  }
}
