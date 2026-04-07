// test/services/migration_service_test.dart

import 'package:flutter_test/flutter_test.dart';

import 'package:futstats/models/competition.dart';
import 'package:futstats/models/statistics.dart';
import 'package:futstats/services/firestore_paths.dart';
import 'package:futstats/services/migration_service.dart';
import '../helpers/in_memory_migration_adapter.dart';
import '../helpers/test_factories.dart';

void main() {
  const playerId = 'player-1';
  const seasonId = 'season-1';
  const season2Id = 'season-2';

  // ─── Helpers de paths ──────────────────────────────────────────────────────

  String seasonCollPath() =>
      FirestorePaths.seasonCollectionPath(playerId);
  String compCollPath(String sid) =>
      FirestorePaths.competitionCollectionPath(playerId, sid);
  String legacyMatchPath(String sid) =>
      'players/$playerId/seasons/$sid/matches';
  String legacyStatsPath(String sid) =>
      'players/$playerId/seasons/$sid/statistics';
  String newMatchPath(String sid, String cid) =>
      FirestorePaths.matchCollectionPath(playerId, sid, cid);

  // ─── Helpers de datos ──────────────────────────────────────────────────────

  Map<String, dynamic> legacySeasonDoc({int? numMatchweeks = 34}) => {
        'id': seasonId,
        'start': 2024,
        'end': 2025,
        if (numMatchweeks != null) 'matchweeks': numMatchweeks,
      };

  // ─── Setup ─────────────────────────────────────────────────────────────────

  late InMemoryMigrationAdapter adapter;
  late MigrationService service;

  setUp(() {
    adapter = InMemoryMigrationAdapter();
    service = MigrationService(adapter: adapter);
  });

  // ─── Helper: extraer compId tras migración ─────────────────────────────────

  String getCreatedCompId(String sid) =>
      adapter.getCollectionSync(compCollPath(sid)).first['id'] as String;

  // ═══════════════════════════════════════════════════════════════════════════
  // Sin datos legacy
  // ═══════════════════════════════════════════════════════════════════════════

  group('sin datos legacy', () {
    test('sin temporadas: no escribe nada', () async {
      await service.migrateIfNeeded(playerId);
      expect(adapter.collectionIsEmpty(compCollPath(seasonId)), isTrue);
    });

    test('con temporada pero sin matches: no migra', () async {
      adapter.seedDocument(seasonCollPath(), seasonId, legacySeasonDoc());
      await service.migrateIfNeeded(playerId);
      expect(adapter.collectionIsEmpty(compCollPath(seasonId)), isTrue);
    });
    
    test('stats huérfanas sin matches se borran sin crear competición', () async {
      adapter.seedDocument(seasonCollPath(), seasonId, legacySeasonDoc());
      // Stats pero sin matches
      adapter.seedDocument(legacyStatsPath(seasonId), 'goals_for',
          {'statId': 'goals_for', 'value': 5.0});

      await service.migrateIfNeeded(playerId);

      expect(adapter.collectionIsEmpty(legacyStatsPath(seasonId)), isTrue);
      expect(adapter.collectionIsEmpty(compCollPath(seasonId)), isTrue,
          reason: 'No debe crear competición sin partidos');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Creación de competición
  // ═══════════════════════════════════════════════════════════════════════════

  group('creación de competición', () {
    setUp(() {
      adapter.seedDocument(seasonCollPath(), seasonId, legacySeasonDoc());
      adapter.seedDocument(legacyMatchPath(seasonId), 'match-1',
          TestFactories.match(id: 'match-1').toMap());
    });

    test('se crea exactamente una competición', () async {
      await service.migrateIfNeeded(playerId);
      expect(adapter.collectionSize(compCollPath(seasonId)), equals(1));
    });

    test('la competición es de tipo liga', () async {
      await service.migrateIfNeeded(playerId);
      final compDocs = adapter.getCollectionSync(compCollPath(seasonId));
      expect(compDocs.first['type'], equals(CompetitionType.league.name));
    });

    test('la competición se llama "Liga"', () async {
      await service.migrateIfNeeded(playerId);
      final compDocs = adapter.getCollectionSync(compCollPath(seasonId));
      expect(compDocs.first['name'], equals('Liga'));
    });

    test('numMatchweeks se recupera del documento legacy', () async {
      await service.migrateIfNeeded(playerId);
      final compDocs = adapter.getCollectionSync(compCollPath(seasonId));
      expect(compDocs.first['numMatchweeks'], equals(34));
    });

    test('numMatchweeks null no impide la migración', () async {
      adapter.seedDocument(seasonCollPath(), seasonId,
          legacySeasonDoc(numMatchweeks: null));
      await service.migrateIfNeeded(playerId);
      expect(adapter.collectionSize(compCollPath(seasonId)), equals(1));
      final compDocs = adapter.getCollectionSync(compCollPath(seasonId));
      expect(compDocs.first['numMatchweeks'], isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Migración de partidos
  // ═══════════════════════════════════════════════════════════════════════════

  group('migración de partidos', () {
    final matches = [
      TestFactories.match(id: 'match-1', goalsFor: 2, goalsAgainst: 1, matchweek: 1),
      TestFactories.match(id: 'match-2', goalsFor: 0, goalsAgainst: 0, matchweek: 2),
      TestFactories.match(id: 'match-3', goalsFor: 3, goalsAgainst: 1, matchweek: 3),
    ];

    setUp(() {
      adapter.seedDocument(seasonCollPath(), seasonId, legacySeasonDoc());
      for (final m in matches) {
        adapter.seedDocument(legacyMatchPath(seasonId), m.id, m.toMap());
      }
    });

    test('todos los partidos aparecen en el nuevo path', () async {
      await service.migrateIfNeeded(playerId);
      final cid = getCreatedCompId(seasonId);
      expect(adapter.collectionSize(newMatchPath(seasonId, cid)), equals(3));
    });

    test('los IDs de los partidos se preservan', () async {
      await service.migrateIfNeeded(playerId);
      final cid = getCreatedCompId(seasonId);
      for (final m in matches) {
        expect(adapter.documentExists(newMatchPath(seasonId, cid), m.id), isTrue,
            reason: 'Match ${m.id} no encontrado en nuevo path');
      }
    });

    test('los datos de los partidos se preservan íntegros', () async {
      await service.migrateIfNeeded(playerId);
      final cid = getCreatedCompId(seasonId);
      final doc = adapter.getDocumentSync(newMatchPath(seasonId, cid), 'match-1')!;
      expect(doc['goalsFor'], equals(2));
      expect(doc['goalsAgainst'], equals(1));
      expect(doc['matchweek'], equals(1));
    });

    test('el path legacy queda vacío tras la migración', () async {
      await service.migrateIfNeeded(playerId);
      expect(adapter.collectionIsEmpty(legacyMatchPath(seasonId)), isTrue);
    });

    test('los partidos no aparecen duplicados en ningún path', () async {
      await service.migrateIfNeeded(playerId);
      final cid = getCreatedCompId(seasonId);
      expect(adapter.collectionSize(newMatchPath(seasonId, cid)), equals(3));
      expect(adapter.collectionIsEmpty(legacyMatchPath(seasonId)), isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Recálculo de estadísticas
  // ═══════════════════════════════════════════════════════════════════════════

  group('recálculo de estadísticas', () {
    final matchList = [
      // win: 2-1
      TestFactories.match(id: 'm1', goalsFor: 2, goalsAgainst: 1, matchweek: 1),
      // draw: 0-0
      TestFactories.match(id: 'm2', goalsFor: 0, goalsAgainst: 0, matchweek: 2),
      // loss: 1-3
      TestFactories.match(id: 'm3', goalsFor: 1, goalsAgainst: 3, matchweek: 3),
    ];

    // Expected calculado con la misma función de producción
    Map<String, double> expectedStats() {
      final stats = StatFormulas.aggregateMatchStats(matchList);
      StatFormulas.calculateAggregateStats(stats);
      return stats;
    }

    setUp(() {
      adapter.seedDocument(seasonCollPath(), seasonId, legacySeasonDoc());
      for (final m in matchList) {
        adapter.seedDocument(legacyMatchPath(seasonId), m.id, m.toMap());
      }
    });

    test('games_played es correcto', () async {
      await service.migrateIfNeeded(playerId);
      final seasonDoc = adapter.getDocumentSync(seasonCollPath(), seasonId)!;
      final stats = Map<String, double>.from(seasonDoc['stats'] as Map);
      expect(stats['games_played'], equals(3.0));
    });

    test('wins, draws y defeats son correctos', () async {
      await service.migrateIfNeeded(playerId);
      final seasonDoc = adapter.getDocumentSync(seasonCollPath(), seasonId)!;
      final stats = Map<String, double>.from(seasonDoc['stats'] as Map);
      expect(stats['wins'], equals(1.0));
      expect(stats['draws'], equals(1.0));
      expect(stats['defeats'], equals(1.0));
    });

    test('goals_for y goals_against son correctos', () async {
      // 2+0+1=3 a favor, 1+0+3=4 en contra
      await service.migrateIfNeeded(playerId);
      final seasonDoc = adapter.getDocumentSync(seasonCollPath(), seasonId)!;
      final stats = Map<String, double>.from(seasonDoc['stats'] as Map);
      expect(stats['goals_for'], equals(3.0));
      expect(stats['goals_against'], equals(4.0));
    });

    test('points son correctos', () async {
      // 3 (win) + 1 (draw) + 0 (loss) = 4
      await service.migrateIfNeeded(playerId);
      final seasonDoc = adapter.getDocumentSync(seasonCollPath(), seasonId)!;
      final stats = Map<String, double>.from(seasonDoc['stats'] as Map);
      expect(stats['points'], equals(4.0));
    });

    test('clean_sheets son correctos', () async {
      // Solo el 0-0 es portería imbatida
      await service.migrateIfNeeded(playerId);
      final seasonDoc = adapter.getDocumentSync(seasonCollPath(), seasonId)!;
      final stats = Map<String, double>.from(seasonDoc['stats'] as Map);
      expect(stats['clean_sheets'], equals(1.0));
    });

    test('goal_difference es correcto', () async {
      // 3 - 4 = -1
      await service.migrateIfNeeded(playerId);
      final seasonDoc = adapter.getDocumentSync(seasonCollPath(), seasonId)!;
      final stats = Map<String, double>.from(seasonDoc['stats'] as Map);
      expect(stats['goal_difference'], equals(-1.0));
    });

    test('stats de competición coinciden exactamente con el recálculo', () async {
      await service.migrateIfNeeded(playerId);
      final cid = getCreatedCompId(seasonId);
      final compDoc = adapter.getDocumentSync(compCollPath(seasonId), cid)!;
      final stats = Map<String, double>.from(compDoc['stats'] as Map);

      for (final entry in expectedStats().entries) {
        expect(stats[entry.key], closeTo(entry.value, 0.001),
            reason: '${entry.key}: expected ${entry.value}, got ${stats[entry.key]}');
      }
    });

    test('stats de temporada coinciden exactamente con el recálculo', () async {
      await service.migrateIfNeeded(playerId);
      final seasonDoc = adapter.getDocumentSync(seasonCollPath(), seasonId)!;
      final stats = Map<String, double>.from(seasonDoc['stats'] as Map);

      for (final entry in expectedStats().entries) {
        expect(stats[entry.key], closeTo(entry.value, 0.001),
            reason: '${entry.key}: expected ${entry.value}, got ${stats[entry.key]}');
      }
    });

    test('stats de temporada y competición son iguales (única competición)', () async {
      await service.migrateIfNeeded(playerId);
      final cid = getCreatedCompId(seasonId);
      final compStats = Map<String, double>.from(
          (adapter.getDocumentSync(compCollPath(seasonId), cid)!['stats'] as Map));
      final seasonStats = Map<String, double>.from(
          (adapter.getDocumentSync(seasonCollPath(), seasonId)!['stats'] as Map));

      expect(compStats, equals(seasonStats));
    });

    test('las stats NO provienen de datos legacy erróneos', () async {
      // Stats legacy con valor incorrecto del método v0.1.0
      adapter.seedDocument(legacyStatsPath(seasonId), 'goals_for',
          {'statId': 'goals_for', 'value': 999.0});

      await service.migrateIfNeeded(playerId);

      final seasonDoc = adapter.getDocumentSync(seasonCollPath(), seasonId)!;
      final stats = Map<String, double>.from(seasonDoc['stats'] as Map);
      expect(stats['goals_for'], equals(3.0),
          reason: 'Las stats deben venir del recálculo, no del valor legacy incorrecto');
      expect(stats['goals_for'], isNot(equals(999.0)));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Borrado de datos legacy
  // ═══════════════════════════════════════════════════════════════════════════

  group('borrado de datos legacy', () {
    setUp(() {
      adapter.seedDocument(seasonCollPath(), seasonId, legacySeasonDoc());
      adapter.seedDocument(legacyMatchPath(seasonId), 'match-1',
          TestFactories.match(id: 'match-1').toMap());
      adapter.seedDocument(legacyStatsPath(seasonId), 'goals_for',
          {'statId': 'goals_for', 'value': 5.0});
      adapter.seedDocument(legacyStatsPath(seasonId), 'assists',
          {'statId': 'assists', 'value': 3.0});
      adapter.seedDocument(legacyStatsPath(seasonId), 'games_played',
          {'statId': 'games_played', 'value': 10.0});
    });

    test('todos los documentos de statistics legacy se borran', () async {
      await service.migrateIfNeeded(playerId);
      expect(adapter.collectionIsEmpty(legacyStatsPath(seasonId)), isTrue);
    });

    test('los matches legacy se borran del path antiguo', () async {
      await service.migrateIfNeeded(playerId);
      expect(adapter.collectionIsEmpty(legacyMatchPath(seasonId)), isTrue);
    });

    test('el documento de temporada se conserva', () async {
      await service.migrateIfNeeded(playerId);
      expect(adapter.documentExists(seasonCollPath(), seasonId), isTrue);
    });

    test('la competición creada no se borra', () async {
      await service.migrateIfNeeded(playerId);
      expect(adapter.collectionSize(compCollPath(seasonId)), equals(1));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Idempotencia
  // ═══════════════════════════════════════════════════════════════════════════

  group('idempotencia', () {
    setUp(() {
      adapter.seedDocument(seasonCollPath(), seasonId, legacySeasonDoc());
      adapter.seedDocument(legacyMatchPath(seasonId), 'match-1',
          TestFactories.match(id: 'match-1').toMap());
    });

    test('segunda ejecución no crea competiciones adicionales', () async {
      await service.migrateIfNeeded(playerId);
      final countAfterFirst = adapter.collectionSize(compCollPath(seasonId));

      await service.migrateIfNeeded(playerId);

      expect(adapter.collectionSize(compCollPath(seasonId)), equals(countAfterFirst));
    });

    test('segunda ejecución no borra los matches ya migrados', () async {
      await service.migrateIfNeeded(playerId);
      final cid = getCreatedCompId(seasonId);
      final countAfterFirst = adapter.collectionSize(newMatchPath(seasonId, cid));

      await service.migrateIfNeeded(playerId);

      expect(adapter.collectionSize(newMatchPath(seasonId, cid)),
          equals(countAfterFirst));
    });

    test('segunda ejecución no modifica las stats', () async {
      await service.migrateIfNeeded(playerId);
      final statsAfterFirst = Map<String, double>.from(
          (adapter.getDocumentSync(seasonCollPath(), seasonId)!['stats'] as Map));

      await service.migrateIfNeeded(playerId);

      final statsAfterSecond = Map<String, double>.from(
          (adapter.getDocumentSync(seasonCollPath(), seasonId)!['stats'] as Map));
      expect(statsAfterSecond, equals(statsAfterFirst));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Múltiples temporadas
  // ═══════════════════════════════════════════════════════════════════════════

  group('múltiples temporadas', () {
    setUp(() {
      // Temporada 1: 1 victoria
      adapter.seedDocument(seasonCollPath(), seasonId,
          {...legacySeasonDoc(), 'numMatchweeks': 38});
      adapter.seedDocument(legacyMatchPath(seasonId), 'match-1',
          TestFactories.match(id: 'match-1', goalsFor: 2, goalsAgainst: 0).toMap());

      // Temporada 2: 1 empate + 1 derrota
      adapter.seedDocument(seasonCollPath(), season2Id, {
        'id': season2Id, 'start': 2023, 'end': 2024, 'numMatchweeks': 34,
      });
      adapter.seedDocument(legacyMatchPath(season2Id), 'match-a',
          TestFactories.match(id: 'match-a', goalsFor: 1, goalsAgainst: 1).toMap());
      adapter.seedDocument(legacyMatchPath(season2Id), 'match-b',
          TestFactories.match(id: 'match-b', goalsFor: 0, goalsAgainst: 2).toMap());
    });

    test('ambas temporadas se migran', () async {
      await service.migrateIfNeeded(playerId);
      expect(adapter.collectionSize(compCollPath(seasonId)), equals(1));
      expect(adapter.collectionSize(compCollPath(season2Id)), equals(1));
    });

    test('los partidos van al path correcto en cada temporada', () async {
      await service.migrateIfNeeded(playerId);
      final cid1 = getCreatedCompId(seasonId);
      final cid2 = getCreatedCompId(season2Id);
      expect(adapter.collectionSize(newMatchPath(seasonId, cid1)), equals(1));
      expect(adapter.collectionSize(newMatchPath(season2Id, cid2)), equals(2));
    });

    test('las stats de cada temporada son independientes y correctas', () async {
      await service.migrateIfNeeded(playerId);

      final stats1 = Map<String, double>.from(
          (adapter.getDocumentSync(seasonCollPath(), seasonId)!['stats'] as Map));
      final stats2 = Map<String, double>.from(
          (adapter.getDocumentSync(seasonCollPath(), season2Id)!['stats'] as Map));

      // Temporada 1: 1 partido, 1 victoria, 2-0
      expect(stats1['games_played'], equals(1.0));
      expect(stats1['wins'], equals(1.0));
      expect(stats1['goals_for'], equals(2.0));
      expect(stats1['goals_against'], equals(0.0));

      // Temporada 2: 2 partidos, 0 victorias, 1 empate, 1 derrota
      expect(stats2['games_played'], equals(2.0));
      expect(stats2['draws'], equals(1.0));
      expect(stats2['defeats'], equals(1.0));
    });

    test('los paths legacy de ambas temporadas quedan vacíos', () async {
      await service.migrateIfNeeded(playerId);
      expect(adapter.collectionIsEmpty(legacyMatchPath(seasonId)), isTrue);
      expect(adapter.collectionIsEmpty(legacyMatchPath(season2Id)), isTrue);
    });

    test('una temporada sin matches no bloquea la migración de las demás', () async {
      const season3Id = 'season-3';
      adapter.seedDocument(seasonCollPath(), season3Id,
          {'id': season3Id, 'start': 2022, 'end': 2023});
      // Sin matches legacy en temporada 3

      await service.migrateIfNeeded(playerId);

      // Las otras dos temporadas se migran igualmente
      expect(adapter.collectionSize(compCollPath(seasonId)), equals(1));
      expect(adapter.collectionSize(compCollPath(season2Id)), equals(1));
      // La temporada 3 no se toca
      expect(adapter.collectionIsEmpty(compCollPath(season3Id)), isTrue);
    });
  });
}
