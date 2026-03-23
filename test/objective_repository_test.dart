import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futstats/firebase_options.dart';
import 'package:futstats/repositories/objective_repository.dart';
import 'package:futstats/models/objective.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  group('ObjectiveRepository CRUD Operations', () {
    final objectiveRepo = ObjectiveRepository();
    final testPlayerId = 'test-player-id'; // Asegúrate de tener este jugador creado
    final testSeasonId = 'test-season-id'; // Asegúrate de tener esta temporada creada
    final testObjective = Objective(
      statId: 'goals',
      target: 10,
    );

    // Agregar partido
    test('Add Objective', () async {
      await objectiveRepo.setObjective(testPlayerId, testSeasonId, testObjective);
      final retrievedObjective = await objectiveRepo.getObjective(testPlayerId, testSeasonId, testObjective.id);
      expect(retrievedObjective?.target, equals(10.0));
    });

    // Obtener partido
    test('Get Objective by ID', () async {
      final retrievedObjective = await objectiveRepo.getObjective(testPlayerId, testSeasonId, testObjective.id);
      expect(retrievedObjective, isNotNull);
      expect(retrievedObjective?.target, equals(10.0));
    });

    // Actualizar partido
    test('Update Objective', () async {
      final updatedObjective = Objective(
        id: testObjective.id,
        statId: testObjective.statId,
        target: 8,
      );
      await objectiveRepo.setObjective(testPlayerId, testSeasonId, updatedObjective);

      final retrievedUpdatedObjective = await objectiveRepo.getObjective(testPlayerId, testSeasonId, updatedObjective.id);
      expect(retrievedUpdatedObjective?.target, equals(8.0));
    });

    // Obtener todos los partidos de una temporada
    test('Get All Objectives for Season', () async {
      final allObjectivees = await objectiveRepo.getAllObjectives(testPlayerId, testSeasonId);
      expect(allObjectivees.length, greaterThanOrEqualTo(1));
    });

    // Eliminar partido
    test('Delete Objective', () async {
      await objectiveRepo.deleteObjective(testPlayerId, testSeasonId, testObjective.id);
      final deletedObjective = await objectiveRepo.getObjective(testPlayerId, testSeasonId, testObjective.id);
      expect(deletedObjective, isNull);
    });
  });
}
