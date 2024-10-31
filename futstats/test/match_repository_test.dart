import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futstats/firebase_options.dart';
import 'package:futstats/repositories/match_repository.dart';
import 'package:futstats/models/match.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  group('MatchRepository CRUD Operations', () {
    final matchRepo = MatchRepository();
    final testPlayerId =
        'test-player-id'; // Asegúrate de tener este jugador creado
    final testSeasonId =
        'test-season-id'; // Asegúrate de tener esta temporada creada
    final testMatch = Match(
      matchweek: 1,
      date: DateTime.now(),
      opponent: 'Team A',
      stats: {'goals': 2},
    );

    // Agregar partido
    test('Add Match', () async {
      await matchRepo.setMatch(testPlayerId, testSeasonId, testMatch);
      final retrievedMatch =
          await matchRepo.getMatch(testPlayerId, testSeasonId, testMatch.id);
      expect(retrievedMatch?.opponent, equals('Team A'));
    });

    // Obtener partido
    test('Get Match by ID', () async {
      final retrievedMatch =
          await matchRepo.getMatch(testPlayerId, testSeasonId, testMatch.id);
      expect(retrievedMatch, isNotNull);
      expect(retrievedMatch?.opponent, equals('Team A'));
    });

    // Actualizar partido
    test('Update Match', () async {
      final updatedMatch = Match(
        id: testMatch.id,
        matchweek: 1,
        date: DateTime.now(),
        opponent: 'Team B',
        stats: {'goals': 3},
      );
      await matchRepo.setMatch(testPlayerId, testSeasonId, updatedMatch);

      final retrievedUpdatedMatch =
          await matchRepo.getMatch(testPlayerId, testSeasonId, updatedMatch.id);
      expect(retrievedUpdatedMatch?.opponent, equals('Team B'));
    });

    // Obtener todos los partidos de una temporada
    test('Get All Matches for Season', () async {
      final allMatches =
          await matchRepo.getAllMatches(testPlayerId, testSeasonId);
      expect(allMatches.length, greaterThanOrEqualTo(1));
    });

    // Eliminar partido
    test('Delete Match', () async {
      await matchRepo.deleteMatch(testPlayerId, testSeasonId, testMatch.id);
      final deletedMatch =
          await matchRepo.getMatch(testPlayerId, testSeasonId, testMatch.id);
      expect(deletedMatch, isNull);
    });
  });
}
