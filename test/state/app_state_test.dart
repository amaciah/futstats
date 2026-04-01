import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:futstats/controllers/competition_controller.dart';
import 'package:futstats/controllers/match_controller.dart';
import 'package:futstats/controllers/objective_controller.dart';
import 'package:futstats/controllers/player_controller.dart';
import 'package:futstats/controllers/season_controller.dart';
import 'package:futstats/models/competition.dart';
import 'package:futstats/models/match.dart';
import 'package:futstats/models/objective.dart';
import 'package:futstats/models/player.dart';
import 'package:futstats/models/season.dart';
import 'package:futstats/state/app_state.dart';

import '../helpers/firebase_mock.dart';
import '../helpers/test_factories.dart';

@GenerateMocks([
  PlayerController,
  SeasonController,
  CompetitionController,
  ObjectiveController,
  MatchController,
])
import 'app_state_test.mocks.dart';

// ─── AppState testeable ──────────────────────────────────────────────────────
//
// AppState instancia sus controladores internamente, lo que lo hace difícil
// de testear directamente. La solución es una subclase que permite inyectar
// los mocks desde fuera, sin modificar el código de producción.

class TestableAppState extends AppState {
  TestableAppState({
    required this.mockPlayerController,
    required this.mockSeasonControllerFactory,
    required this.mockCompetitionControllerFactory,
    required this.mockObjectiveControllerFactory,
    required this.mockMatchControllerFactory,
  });

  final PlayerController mockPlayerController;
  final SeasonController Function(String playerId) mockSeasonControllerFactory;
  final CompetitionController Function(String playerId, String seasonId)
      mockCompetitionControllerFactory;
  final ObjectiveController Function(String playerId, String seasonId)
      mockObjectiveControllerFactory;
  final MatchController Function(Competition competition) mockMatchControllerFactory;

  @override
  PlayerController createPlayerController() => mockPlayerController;

  @override
  SeasonController createSeasonController(String playerId) =>
      mockSeasonControllerFactory(playerId);

  @override
  CompetitionController createCompetitionController(
          String playerId, String seasonId) =>
      mockCompetitionControllerFactory(playerId, seasonId);

  @override
  ObjectiveController createObjectiveController(
          String playerId, String seasonId) =>
      mockObjectiveControllerFactory(playerId, seasonId);

  @override
  MatchController createMatchController(Competition competition) =>
      mockMatchControllerFactory(competition);
}

void main() {
  late MockPlayerController mockPlayerController;
  late MockSeasonController mockSeasonController;
  late MockCompetitionController mockCompetitionController;
  late MockObjectiveController mockObjectiveController;
  late MockMatchController mockMatchController;
  late TestableAppState appState;

  final testPlayer = TestFactories.player(currentSeasonId: 'season-1');
  final testSeason = TestFactories.season();
  final testCompetition = TestFactories.competition();
  final testFriendly = TestFactories.friendly();
  final testObjective = TestFactories.objective();

  // Red de seguridad: si algún path no mockeado llega a Firebase, no explota
  setUpAll(() async {
    await initializeFirebaseForTests();
  });

  // Importante: resetear el estado de Firebase entre grupos si hay
  // tests que modifiquen FirebasePlatform.instance
  tearDownAll(() {
    // Opcional: restaurar la plataforma real si otros tests la necesitan
    // No necesario si los tests de estado corren en proceso aislado
  });

  setUp(() {
    mockPlayerController = MockPlayerController();
    mockSeasonController = MockSeasonController();
    mockCompetitionController = MockCompetitionController();
    mockObjectiveController = MockObjectiveController();
    mockMatchController = MockMatchController();

    appState = TestableAppState(
      mockPlayerController: mockPlayerController,
      mockSeasonControllerFactory: (_) => mockSeasonController,
      mockCompetitionControllerFactory: (_, __) => mockCompetitionController,
      mockObjectiveControllerFactory: (_, __) => mockObjectiveController,
      mockMatchControllerFactory: (_) => mockMatchController,
    );

    // Stubs por defecto — respuestas vacías para no romper tests que no las necesitan
    // PlayerController
    when(mockPlayerController.savePlayer(any)).thenAnswer((_) async {});
    when(mockPlayerController.setCurrentSeason(any, any))
        .thenAnswer((_) async {});
    
    // SeasonController
    when(mockSeasonController.loadAllSeasons())
        .thenAnswer((_) async => [testSeason]);
    when(mockSeasonController.saveSeason(any)).thenAnswer((_) async {});
    when(mockSeasonController.loadSeason(any))
        .thenAnswer((_) async => testSeason);
    
    // CompetitionController
    when(mockCompetitionController.loadAllCompetitions())
        .thenAnswer((_) async => [testCompetition]);
    when(mockCompetitionController.saveCompetition(any))
        .thenAnswer((_) async {});
    when(mockCompetitionController.deleteCompetition(any))
        .thenAnswer((_) async {});

    // ObjectiveController
    when(mockObjectiveController.loadAllObjectives())
        .thenAnswer((_) async => [testObjective]);
    when(mockObjectiveController.saveObjective(any)).thenAnswer((_) async {});
    when(mockObjectiveController.deleteObjective(any)).thenAnswer((_) async {});

    // MatchController
    when(mockMatchController.saveMatch(any)).thenAnswer((_) async {});
    when(mockMatchController.deleteMatch(any)).thenAnswer((_) async {});
    when(mockMatchController.loadMatches()).thenAnswer((_) async {});
    when(mockMatchController.matches).thenReturn([]);
    when(mockMatchController.isLoaded).thenReturn(false);
  });

  // ─── R20: setActivePlayer reinicia jerarquía de estado ──────────────────────

  group('R20 - setActivePlayer reinicia estado dependiente', () {
    test('season, competition, competitions y objectives se reinician', () async {
      // Establecer estado previo
      await appState.setActivePlayer(testPlayer);
      await appState.setCurrentSeason(testSeason);

      // Ahora cambiar de jugador
      final otherPlayer = TestFactories.player(id: 'player-2', name: 'Otro');
      await appState.setActivePlayer(otherPlayer);

      expect(appState.currentSeason, isNull);
      expect(appState.selectedCompetition, isNull);
      expect(appState.competitions, isEmpty);
      expect(appState.objectives, isEmpty);
    });

    test('notifica listeners tras el cambio', () async {
      int notifyCount = 0;
      appState.addListener(() => notifyCount++);

      await appState.setActivePlayer(testPlayer);

      expect(notifyCount, greaterThan(0));
    });

    test('player queda actualizado', () async {
      await appState.setActivePlayer(testPlayer);
      expect(appState.player, equals(testPlayer));
    });

    test('controladores previos no se reutilizan tras cambio de jugador',
        () async {
      // Primer jugador: cargar competiciones
      await appState.setActivePlayer(testPlayer);
      await appState.setCurrentSeason(testSeason);
      final firstCallCount =
          verify(mockCompetitionController.loadAllCompetitions()).callCount;

      // Segundo jugador: los controladores se reinician
      final otherPlayer = TestFactories.player(id: 'player-2');
      await appState.setActivePlayer(otherPlayer);

      // No debe haber nuevas llamadas al controlador de competiciones
      // porque _competitionController es null hasta setCurrentSeason
      verifyNever(mockCompetitionController.loadAllCompetitions());
      expect(firstCallCount, greaterThan(0));
    });
  });

  // ─── R21: setCurrentSeason inicializa controladores y carga datos ───────────

  group('R21 - setCurrentSeason inicializa y carga', () {
    setUp(() async {
      await appState.setActivePlayer(testPlayer);
    });

    test('competitions se cargan automáticamente', () async {
      await appState.setCurrentSeason(testSeason);

      expect(appState.competitions, contains(testCompetition));
    });

    test('objectives se cargan automáticamente', () async {
      await appState.setCurrentSeason(testSeason);

      expect(appState.objectives, contains(testObjective));
    });

    test('currentSeason queda actualizado', () async {
      await appState.setCurrentSeason(testSeason);

      expect(appState.currentSeason, equals(testSeason));
    });

    test('persiste currentSeasonId en el jugador', () async {
      await appState.setCurrentSeason(testSeason);

      verify(mockPlayerController.setCurrentSeason(
        argThat(isA<Player>()),
        testSeason.id,
      )).called(1);
    });

    test('crea amistosos automáticamente si no existen', () async {
      // Solo hay una liga, sin amistosos
      when(mockCompetitionController.loadAllCompetitions())
          .thenAnswer((_) async => [testCompetition]);

      await appState.setCurrentSeason(testSeason);

      // Debe haber guardado una competición de tipo friendly
      final captured = verify(
        mockCompetitionController.saveCompetition(captureAny),
      ).captured;

      final savedCompetitions = captured.cast<Competition>();
      expect(
        savedCompetitions.any((c) => c.type == CompetitionType.friendly),
        isTrue,
        reason: 'Debe crear amistosos automáticamente',
      );
    });

    test('NO crea amistosos si ya existe uno', () async {
      // Ya hay un amistoso en la lista
      when(mockCompetitionController.loadAllCompetitions())
          .thenAnswer((_) async => [testCompetition, testFriendly]);

      await appState.setCurrentSeason(testSeason);

      // No debe haber guardado ninguna competición nueva
      verifyNever(mockCompetitionController.saveCompetition(any));
    });

    test('notifica listeners al completar', () async {
      int notifyCount = 0;
      appState.addListener(() => notifyCount++);

      await appState.setCurrentSeason(testSeason);

      expect(notifyCount, greaterThan(0));
    });
  });

  // ─── R22: saveMatch no corrompe el estado ────────────────────────────────────

  group('R22 - saveMatch no corrompe el estado', () {
    setUp(() async {
      await appState.setActivePlayer(testPlayer);
      await appState.setCurrentSeason(testSeason);
    });

    test('competitions se recarga tras saveMatch', () async {
      // Limpiar interacciones previas acumuladas por setCurrentSeason (en setUp)
      clearInteractions(mockCompetitionController);

      await appState.saveMatch(TestFactories.match(), testCompetition);

      // Verificar exactamente 1 recarga tras saveMatch, sin ambigüedad
      verify(mockCompetitionController.loadAllCompetitions()).called(1);
    });

    test('selectedCompetition no cambia tras saveMatch', () async {
      appState.selectCompetition(testCompetition);

      await appState.saveMatch(TestFactories.match(), testCompetition);

      // La competición seleccionada puede haberse actualizado (nueva instancia
      // desde Firestore) pero debe mantener el mismo id
      expect(appState.selectedCompetition?.id, equals(testCompetition.id));
    });

    test('saveMatch sin player activo no lanza excepción', () async {
      final freshState = TestableAppState(
        mockPlayerController: mockPlayerController,
        mockSeasonControllerFactory: (_) => mockSeasonController,
        mockCompetitionControllerFactory: (_, __) => mockCompetitionController,
        mockObjectiveControllerFactory: (_, __) => mockObjectiveController,
        mockMatchControllerFactory: (_) => mockMatchController,
      );

      // No debe lanzar — simplemente no hace nada
      await expectLater(
        freshState.saveMatch(TestFactories.match(), testCompetition),
        completes,
      );
    });

    test('saveMatch sin season activa no lanza excepción', () async {
      final freshState = TestableAppState(
        mockPlayerController: mockPlayerController,
        mockSeasonControllerFactory: (_) => mockSeasonController,
        mockCompetitionControllerFactory: (_, __) => mockCompetitionController,
        mockObjectiveControllerFactory: (_, __) => mockObjectiveController,
        mockMatchControllerFactory: (_) => mockMatchController,
      );
      await freshState.setActivePlayer(testPlayer);
      // Sin llamar a setCurrentSeason

      await expectLater(
        freshState.saveMatch(TestFactories.match(), testCompetition),
        completes,
      );
    });
  });

  // ─── Tests adicionales de AppState ──────────────────────────────────────────

  group('selectCompetition', () {
    setUp(() async {
      await appState.setActivePlayer(testPlayer);
      await appState.setCurrentSeason(testSeason);
    });

    test('actualiza selectedCompetition', () {
      appState.selectCompetition(testCompetition);
      expect(appState.selectedCompetition, equals(testCompetition));
    });

    test('acepta null para deseleccionar', () {
      appState.selectCompetition(testCompetition);
      appState.selectCompetition(null);
      expect(appState.selectedCompetition, isNull);
    });

    test('notifica listeners', () {
      int count = 0;
      appState.addListener(() => count++);
      appState.selectCompetition(testCompetition);
      expect(count, equals(1));
    });
  });

  group('getStatsFromCompetition', () {
    final statsMap = {'goals': 5.0, 'assists': 3.0};

    setUp(() async {
      await appState.setActivePlayer(testPlayer);
    });

    test('sin competición seleccionada devuelve stats de temporada', () async {
      final seasonWithStats = TestFactories.season(stats: statsMap);
      when(mockCompetitionController.loadAllCompetitions())
          .thenAnswer((_) async => [testCompetition]);
      await appState.setCurrentSeason(seasonWithStats);

      final result = await appState.getStatsFromSelectedCompetition();
      expect(result, equals(statsMap));
    });

    test('con competición seleccionada devuelve sus stats', () async {
      final compWithStats = TestFactories.competition(stats: statsMap);
      when(mockCompetitionController.loadAllCompetitions())
          .thenAnswer((_) async => [compWithStats]);
      await appState.setCurrentSeason(testSeason);
      appState.selectCompetition(compWithStats);

      final result = await appState.getStatsFromSelectedCompetition();
      expect(result, equals(statsMap));
    });

    test('sin temporada devuelve mapa vacío', () async {
      final result = await appState.getStatsFromSelectedCompetition();
      expect(result, isEmpty);
    });
  });

  group('saveObjective / deleteObjective', () {
    setUp(() async {
      await appState.setActivePlayer(testPlayer);
      await appState.setCurrentSeason(testSeason);
    });

    test('saveObjective llama al controlador y recarga', () async {
      clearInteractions(mockObjectiveController);
      await appState.saveObjective(testObjective);

      verify(mockObjectiveController.saveObjective(testObjective)).called(1);
      verify(mockObjectiveController.loadAllObjectives()).called(greaterThan(0));
    });

    test('deleteObjective llama al controlador y recarga', () async {
      clearInteractions(mockObjectiveController);
      await appState.deleteObjective(testObjective.id);

      verify(mockObjectiveController.deleteObjective(testObjective.id))
          .called(1);
      verify(mockObjectiveController.loadAllObjectives()).called(greaterThan(0));
    });
  });

  group('deleteSeason', () {
    setUp(() async {
      await appState.setActivePlayer(testPlayer);
      await appState.setCurrentSeason(testSeason);
      when(mockSeasonController.deleteSeason(any)).thenAnswer((_) async {});
    });

    test('elimina la temporada de la lista local', () async {
      await appState.loadSeasons();
      await appState.deleteSeason(testSeason.id);

      expect(appState.seasons.any((s) => s.id == testSeason.id), isFalse);
    });

    test('limpia currentSeason si se borra la activa', () async {
      await appState.deleteSeason(testSeason.id);

      expect(appState.currentSeason, isNull);
      expect(appState.competitions, isEmpty);
      expect(appState.objectives, isEmpty);
    });

    test('no limpia currentSeason si se borra una temporada diferente',
        () async {
      await appState.deleteSeason('otra-temporada-id');

      expect(appState.currentSeason, equals(testSeason));
    });
  });

  group('getCurrentSeasonFromDB', () {
    test('devuelve null si player es null', () async {
      final result = await appState.getCurrentSeasonFromDB();
      expect(result, isNull);
    });

    test('devuelve null si currentSeasonId es null', () async {
      final playerSinTemporada = TestFactories.player(currentSeasonId: null);
      await appState.setActivePlayer(playerSinTemporada);
      final result = await appState.getCurrentSeasonFromDB();
      expect(result, isNull);
    });

    test('delega en seasonController con el id correcto', () async {
      await appState.setActivePlayer(testPlayer); // tiene currentSeasonId = 'season-1'
      await appState.getCurrentSeasonFromDB();
      verify(mockSeasonController.loadSeason('season-1')).called(1);
    });
  });

  group('loadSeasons', () {
    test('devuelve lista vacía si seasonController es null', () async {
      // Sin setActivePlayer, _seasonController es null
      final result = await appState.loadSeasons();
      expect(result, isEmpty);
    });

    test('actualiza seasons y notifica', () async {
      await appState.setActivePlayer(testPlayer);
      int notifyCount = 0;
      appState.addListener(() => notifyCount++);

      final result = await appState.loadSeasons();

      expect(result, equals([testSeason]));
      expect(appState.seasons, equals([testSeason]));
      expect(notifyCount, greaterThan(0));
    });
  });

  group('saveSeason', () {
    setUp(() async => await appState.setActivePlayer(testPlayer));

    test('delega en seasonController', () async {
      await appState.saveSeason(testSeason);
      verify(mockSeasonController.saveSeason(testSeason)).called(1);
    });

    test('añade la temporada si no estaba en la lista', () async {
      expect(appState.seasons, isEmpty);
      await appState.saveSeason(testSeason);
      expect(appState.seasons, contains(testSeason));
    });

    test('actualiza la temporada si ya estaba en la lista', () async {
      appState.seasons = [testSeason];
      final updated = TestFactories.season(id: testSeason.id, startDate: 2023);
      await appState.saveSeason(updated);
      expect(appState.seasons.length, equals(1));
      expect(appState.seasons.first.startDate, equals(2023));
    });
  });

  group('deleteCompetition', () {
    setUp(() async {
      await appState.setActivePlayer(testPlayer);
      await appState.setCurrentSeason(testSeason);
      clearInteractions(mockCompetitionController);
    });

    test('limpia selectedCompetition si se borra la activa', () async {
      appState.selectCompetition(testCompetition);
      await appState.deleteCompetition(testCompetition);
      expect(appState.selectedCompetition, isNull);
    });

    test('no limpia selectedCompetition si se borra otra', () async {
      appState.selectCompetition(testCompetition);
      final otra = TestFactories.competition(id: 'otra-comp');
      await appState.deleteCompetition(otra);
      expect(appState.selectedCompetition?.id, equals(testCompetition.id));
    });

    test('recarga competiciones tras borrar', () async {
      await appState.deleteCompetition(testCompetition);
      verify(mockCompetitionController.loadAllCompetitions()).called(1);
    });
  });
}
