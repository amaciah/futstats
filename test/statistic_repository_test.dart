import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futstats/firebase_options.dart';
import 'package:futstats/repositories/statistic_repository.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  group('StatisticRepository CRUD Operations', () {
    final statisticRepo = StatisticRepository();
    final testPlayerId = 'test-player-id'; // Asegúrate de tener este jugador creado
    final testSeasonId = 'test-season-id'; // Asegúrate de tener esta temporada creada
    final testStatistic = ManualStat(
      id: 'test-stat-id',
      initialValue: 3,
    );

    // Agregar partido
    test('Add Statistic', () async {
      await statisticRepo.setStatistic(testPlayerId, testSeasonId, testStatistic);
      final retrievedStatistic = await statisticRepo.getStatistic(testPlayerId, testSeasonId, testStatistic.id);
      expect(retrievedStatistic.value, equals(3.0));
    });

    // Obtener partido
    test('Get Statistic by ID', () async {
      final retrievedStatistic = await statisticRepo.getStatistic(testPlayerId, testSeasonId, testStatistic.id);
      expect(retrievedStatistic, isNotNull);
    });

    // Actualizar partido
    test('Update Statistic', () async {
      final updatedStatistic = ManualStat(
        id: testStatistic.id,
        initialValue: 5
      );
      await statisticRepo.setStatistic(testPlayerId, testSeasonId, updatedStatistic);

      final retrievedUpdatedStatistic = await statisticRepo.getStatistic(testPlayerId, testSeasonId, updatedStatistic.id);
      expect(retrievedUpdatedStatistic.value, equals(5.0));
    });

    // Obtener todos los partidos de una temporada
    test('Get All Statistices for Season', () async {
      final allStatistices = await statisticRepo.getAllStatistics(testPlayerId, testSeasonId);
      expect(allStatistices.length, greaterThanOrEqualTo(1));
    });

    // Eliminar partido
    test('Delete Statistic', () async {
      await statisticRepo.deleteStatistic(testPlayerId, testSeasonId, testStatistic.id);
      final deletedStatistic = await statisticRepo.getStatistic(testPlayerId, testSeasonId, testStatistic.id);
      expect(deletedStatistic, isNull);
    });
  });
}
