import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:futstats/firebase_options.dart';
import 'package:futstats/models/player.dart';
import 'package:futstats/models/season.dart';
import 'package:futstats/screens/auth_gate.dart';
import 'package:futstats/repositories/match_repository.dart';
import 'package:futstats/repositories/objective_repository.dart';
import 'package:futstats/repositories/player_repository.dart';
import 'package:futstats/repositories/season_repository.dart';
import 'package:futstats/repositories/statistic_repository.dart';
import 'package:futstats/widgets/exit_confirm_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
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
  static Season _season = Season(
    id: 'test-season',
    startDate: 2023,
    endDate: 2024,
    numMatchweeks: 10,
  );

  static PlayerRepository get playerRepo => PlayerRepository();
  static SeasonRepository get seasonRepo =>
      SeasonRepository(playerId: player.id);
  static MatchRepository get matchRepo => MatchRepository(seasonId: _season.id);
  static StatisticRepository get statsRepo =>
      StatisticRepository(seasonId: _season.id);
  static ObjectiveRepository get objRepo =>
      ObjectiveRepository(seasonId: _season.id);

  static Season get season => _season;
  static Future<void> setSeason(Season season) async {
    _season = season;
    await player.setCurrentSeason(season.id);
  }

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
        navigationBarTheme: NavigationBarThemeData(
          labelTextStyle: WidgetStatePropertyAll(
            TextStyle(
              overflow: TextOverflow.ellipsis,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
      home: const ExitConfirmWrapper(
        child: AuthGate(),
      ),
    );
  }
}
