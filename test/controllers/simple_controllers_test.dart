// test/controllers/simple_controllers_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:futstats/controllers/competition_controller.dart';
import 'package:futstats/controllers/objective_controller.dart';
import 'package:futstats/controllers/player_controller.dart';
import 'package:futstats/controllers/season_controller.dart';
import 'package:futstats/services/repositories/competition_repository.dart';
import 'package:futstats/services/repositories/objective_repository.dart';
import 'package:futstats/services/repositories/player_repository.dart';
import 'package:futstats/services/repositories/season_repository.dart';

import '../helpers/test_factories.dart';

@GenerateMocks([
  PlayerRepository,
  SeasonRepository,
  CompetitionRepository,
  ObjectiveRepository,
])
import 'simple_controllers_test.mocks.dart';

void main() {

  // ─── PlayerController ───────────────────────────────────────────────────────

  group('PlayerController', () {
    late MockPlayerRepository mockRepo;
    late PlayerController controller;
    final player = TestFactories.player();

    setUp(() {
      mockRepo = MockPlayerRepository();
      controller = PlayerController(repo: mockRepo); // ← inyección directa
      when(mockRepo.get(any)).thenAnswer((_) async => player);
      when(mockRepo.set(any)).thenAnswer((_) async {});
      when(mockRepo.delete(any)).thenAnswer((_) async {});
    });

    test('loadPlayer delega en el repositorio', () async {
      final result = await controller.loadPlayer(player.id);
      verify(mockRepo.get(player.id)).called(1);
      expect(result, equals(player));
    });

    test('savePlayer delega en el repositorio', () async {
      await controller.savePlayer(player);
      verify(mockRepo.set(player)).called(1);
    });

    test('deletePlayer delega en el repositorio', () async {
      await controller.deletePlayer(player.id);
      verify(mockRepo.delete(player.id)).called(1);
    });

    test('setCurrentSeason actualiza currentSeasonId y guarda', () async {
      await controller.setCurrentSeason(player, 'season-99');
      expect(player.currentSeasonId, equals('season-99'));
      verify(mockRepo.set(player)).called(1);
    });
  });

  // ─── SeasonController ───────────────────────────────────────────────────────

  group('SeasonController', () {
    late MockSeasonRepository mockRepo;
    late SeasonController controller;
    final season = TestFactories.season();

    setUp(() {
      mockRepo = MockSeasonRepository();
      controller = SeasonController(playerId: 'test', repo: mockRepo);
      when(mockRepo.get(any)).thenAnswer((_) async => season);
      when(mockRepo.set(any)).thenAnswer((_) async {});
      when(mockRepo.delete(any)).thenAnswer((_) async {});
      when(mockRepo.getAll()).thenAnswer((_) async => [season]);
    });

    test('loadSeason delega en el repositorio', () async {
      final result = await controller.loadSeason(season.id);
      verify(mockRepo.get(season.id)).called(1);
      expect(result, equals(season));
    });

    test('saveSeason delega en el repositorio', () async {
      await controller.saveSeason(season);
      verify(mockRepo.set(season)).called(1);
    });

    test('deleteSeason delega en el repositorio', () async {
      await controller.deleteSeason(season.id);
      verify(mockRepo.delete(season.id)).called(1);
    });

    test('loadAllSeasons devuelve lista completa', () async {
      final result = await controller.loadAllSeasons();
      expect(result, equals([season]));
    });
  });

  // ─── CompetitionController ──────────────────────────────────────────────────

  group('CompetitionController', () {
    late MockCompetitionRepository mockRepo;
    late CompetitionController controller;
    final competition = TestFactories.competition();

    setUp(() {
      mockRepo = MockCompetitionRepository();
      controller = CompetitionController(
        playerId: 'test',
        seasonId: 'test',
        repo: mockRepo,
      );
      when(mockRepo.get(any)).thenAnswer((_) async => competition);
      when(mockRepo.set(any)).thenAnswer((_) async {});
      when(mockRepo.delete(any)).thenAnswer((_) async {});
      when(mockRepo.getAll()).thenAnswer((_) async => [competition]);
    });

    test('loadCompetition delega en el repositorio', () async {
      final result = await controller.loadCompetition(competition.id);
      verify(mockRepo.get(competition.id)).called(1);
      expect(result, equals(competition));
    });

    test('saveCompetition delega en el repositorio', () async {
      await controller.saveCompetition(competition);
      verify(mockRepo.set(competition)).called(1);
    });

    test('deleteCompetition delega en el repositorio', () async {
      await controller.deleteCompetition(competition.id);
      verify(mockRepo.delete(competition.id)).called(1);
    });

    test('loadAllCompetitions devuelve lista completa', () async {
      final result = await controller.loadAllCompetitions();
      expect(result, equals([competition]));
    });
  });

  // ─── ObjectiveController ────────────────────────────────────────────────────

  group('ObjectiveController', () {
    late MockObjectiveRepository mockRepo;
    late ObjectiveController controller;
    final objective = TestFactories.objective();

    setUp(() {
      mockRepo = MockObjectiveRepository();
      controller = ObjectiveController(
        playerId: 'test',
        seasonId: 'test',
        repo: mockRepo,
      );
      when(mockRepo.get(any)).thenAnswer((_) async => objective);
      when(mockRepo.set(any)).thenAnswer((_) async {});
      when(mockRepo.delete(any)).thenAnswer((_) async {});
      when(mockRepo.getAll()).thenAnswer((_) async => [objective]);
    });

    test('loadObjective delega en el repositorio', () async {
      final result = await controller.loadObjective(objective.id);
      verify(mockRepo.get(objective.id)).called(1);
      expect(result, equals(objective));
    });

    test('saveObjective delega en el repositorio', () async {
      await controller.saveObjective(objective);
      verify(mockRepo.set(objective)).called(1);
    });

    test('deleteObjective delega en el repositorio', () async {
      await controller.deleteObjective(objective.id);
      verify(mockRepo.delete(objective.id)).called(1);
    });

    test('loadAllObjectives devuelve lista completa', () async {
      final result = await controller.loadAllObjectives();
      expect(result, equals([objective]));
    });
  });
}
