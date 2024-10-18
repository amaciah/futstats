import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futstats/firebase_options.dart';
import 'package:futstats/repositories/season_repository.dart';
import 'package:futstats/models/season.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  group('SeasonRepository CRUD Operations', () {
    final seasonRepo = SeasonRepository();
    final testPlayerId = 'test-player-id'; // Asegúrate de tener este jugador creado
    final testSeason = Season(year: '2023', matches: [], seasonStats: {}, objectives: []);

    // Agregar temporada
    test('Add Season', () async {
      await seasonRepo.setSeason(testPlayerId, testSeason);
      final retrievedSeason = await seasonRepo.getSeason(testPlayerId, testSeason.id);
      expect(retrievedSeason?.year, equals('2023'));
    });

    // Obtener temporada
    test('Get Season by ID', () async {
      final retrievedSeason = await seasonRepo.getSeason(testPlayerId, testSeason.id);
      expect(retrievedSeason, isNotNull);
      expect(retrievedSeason?.year, equals('2023'));
    });

    // Actualizar temporada
    test('Update Season', () async {
      final updatedSeason = Season(
        id: testSeason.id,
        year: '2024',
        matches: [],
        seasonStats: {},
        objectives: [],
      );
      await seasonRepo.setSeason(testPlayerId, updatedSeason);

      final retrievedUpdatedSeason = await seasonRepo.getSeason(testPlayerId, updatedSeason.id);
      expect(retrievedUpdatedSeason?.year, equals('2024'));
    });

    // Obtener todas las temporadas
    test('Get All Seasons for Player', () async {
      final allSeasons = await seasonRepo.getAllSeasons(testPlayerId);
      expect(allSeasons.length, greaterThanOrEqualTo(1));
    });

    // Eliminar temporada
    test('Delete Season', () async {
      await seasonRepo.deleteSeason(testPlayerId, testSeason.id);
      final deletedSeason = await seasonRepo.getSeason(testPlayerId, testSeason.id);
      expect(deletedSeason, isNull);
    });
  });
}
