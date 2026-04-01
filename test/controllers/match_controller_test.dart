import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:futstats/controllers/competition_controller.dart';
import 'package:futstats/controllers/match_controller.dart';
import 'package:futstats/controllers/season_controller.dart';
import 'package:futstats/models/competition.dart';
import 'package:futstats/models/match.dart';
import 'package:futstats/models/season.dart';
import 'package:futstats/services/repositories/match_repository.dart';

@GenerateMocks([MatchRepository, CompetitionController, SeasonController])
import 'match_controller_test.mocks.dart';

void main() {
  late MockMatchRepository mockMatchRepo;
  late MockCompetitionController mockCompetitionController;
  late MockSeasonController mockSeasonController;
  late Competition testCompetition;
  late Season testSeason;
  late MatchController controller;

  Match makeMatch({int gf = 2, int ga = 1, int? matchweek}) => Match(
        date: DateTime(2025, 1, 1),
        opponent: 'Test FC',
        goalsFor: gf,
        goalsAgainst: ga,
        matchweek: matchweek ?? 1,
        stats: {'goals': gf.toDouble(), 'assists': 0},
      );

  setUp(() {
    mockMatchRepo = MockMatchRepository();
    mockCompetitionController = MockCompetitionController();
    mockSeasonController = MockSeasonController();

    testCompetition = Competition(
      id: 'comp-1',
      name: 'Liga Test',
      type: CompetitionType.league,
      numMatchweeks: 10,
    );

    testSeason = Season(id: 'season-1', startDate: 2024, endDate: 2025);

    controller = MatchController(
      matchRepoFactory: (_) => mockMatchRepo,
      competitionController: mockCompetitionController,
      seasonController: mockSeasonController,
      competition: testCompetition,
      season: testSeason,
    );

    // Stubs por defecto
    when(mockMatchRepo.set(any)).thenAnswer((_) async {});
    when(mockMatchRepo.delete(any)).thenAnswer((_) async {});
    when(mockMatchRepo.getAll()).thenAnswer((_) async => []);
    when(mockCompetitionController.loadAllCompetitions())
        .thenAnswer((_) async => [testCompetition]);
    when(mockCompetitionController.saveCompetition(any))
        .thenAnswer((_) async {});
    when(mockSeasonController.saveSeason(any)).thenAnswer((_) async {});
  });

  // ─── R15: saveMatch recalcula stats ─────────────────────────────────────────

  group('R15 - saveMatch recalcula stats de competición y temporada', () {
    test('llama a saveCompetition y saveSeason tras guardar', () async {
      final match = makeMatch();
      when(mockMatchRepo.getAll()).thenAnswer((_) async => [match]);

      await controller.saveMatch(match);

      verify(mockCompetitionController.saveCompetition(any)).called(1);
      verify(mockSeasonController.saveSeason(any)).called(1);
    });
  });

  // ─── R16: deleteMatch recalcula stats ───────────────────────────────────────

  group('R16 - deleteMatch recalcula stats', () {
    test('llama a saveCompetition y saveSeason tras borrar', () async {
      final match = makeMatch();
      controller = MatchController(
        matchRepoFactory: (_) => mockMatchRepo,
        competitionController: mockCompetitionController,
        seasonController: mockSeasonController,
        competition: testCompetition,
        season: testSeason,
      );

      await controller.deleteMatch(match.id);

      verify(mockCompetitionController.saveCompetition(any)).called(1);
      verify(mockSeasonController.saveSeason(any)).called(1);
    });
  });

  // ─── R17: _aggregateMatchStats lista vacía ───────────────────────────────────

  group('R17 - aggregación sobre lista vacía', () {
    test('games_played == 0 con lista vacía', () async {
      when(mockMatchRepo.getAll()).thenAnswer((_) async => []);
      
      // Capturar la season guardada
      Season? savedSeason;
      when(mockSeasonController.saveSeason(any)).thenAnswer((inv) async {
        savedSeason = inv.positionalArguments[0] as Season;
      });

      await controller.saveMatch(makeMatch());

      expect(savedSeason?.stats['games_played'], equals(0));
    });
  });

  // ─── R18: amistosos excluidos de stats de temporada ─────────────────────────

  group('R18 - amistosos excluidos de stats de temporada', () {
    test('partidos de competición friendly no se acumulan en la temporada', () async {
      final leagueComp = testCompetition;
      final friendlyComp = Competition(
        id: 'comp-friendly',
        name: 'Amistosos',
        type: CompetitionType.friendly,
      );
      final friendlyMatch = makeMatch(gf: 5, ga: 0);
      final leagueMatch = makeMatch(gf: 1, ga: 0);

      when(mockCompetitionController.loadAllCompetitions())
          .thenAnswer((_) async => [leagueComp, friendlyComp]);

      // La factory devuelve partidos distintos según la competición
      when(mockMatchRepo.getAll()).thenAnswer((_) async => [leagueMatch]);
      final friendlyRepo = MockMatchRepository();
      when(friendlyRepo.getAll()).thenAnswer((_) async => [friendlyMatch]);
      when(friendlyRepo.set(any)).thenAnswer((_) async {});

      final controllerWithFriendly = MatchController(
        matchRepoFactory: (id) => 
            id == 'comp-friendly' ? friendlyRepo : mockMatchRepo,
        competitionController: mockCompetitionController,
        seasonController: mockSeasonController,
        competition: leagueComp,
        season: testSeason,
      );

      Season? savedSeason;
      when(mockSeasonController.saveSeason(any)).thenAnswer((inv) async {
        savedSeason = inv.positionalArguments[0] as Season;
      });

      await controllerWithFriendly.saveMatch(leagueMatch);

      // Solo el partido de liga cuenta: games_played debe ser 1, no 2
      expect(savedSeason?.stats['games_played'], equals(1));
    });
  });

  // ─── R19: ordenación de partidos ────────────────────────────────────────────

  group('R19 - Match.compareTo', () {
    test('ordena por jornada', () {
      final m1 = makeMatch(matchweek: 3);
      final m2 = makeMatch(matchweek: 1);
      final m3 = makeMatch(matchweek: 2);
      final sorted = [m1, m2, m3]..sort();
      expect(sorted.map((m) => m.matchweek), equals([1, 2, 3]));
    });

    test('ordena por fecha cuando no hay jornada ni ronda', () {
      Match makeByDate(DateTime date) => Match(
        date: date, opponent: 'X',
        goalsFor: 0, goalsAgainst: 0, stats: {},
      );
      final m1 = makeByDate(DateTime(2025, 3, 1));
      final m2 = makeByDate(DateTime(2025, 1, 1));
      final sorted = [m1, m2]..sort();
      expect(sorted.first.date, equals(DateTime(2025, 1, 1)));
    });
  });
}
