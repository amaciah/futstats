import 'package:flutter_test/flutter_test.dart';

import 'package:futstats/models/competition.dart';
import 'package:futstats/models/match.dart';
import 'package:futstats/models/objective.dart';
import 'package:futstats/models/player.dart';
import 'package:futstats/models/season.dart';
import 'package:futstats/models/statistics.dart';
import '../helpers/test_factories.dart';

void main() {

  // ─── R08: serialización idempotente ─────────────────────────────────────────

  group('R08 - toMap/fromMap idempotente', () {
    test('Player', () {
      final original = Player(
        id: 'test-id',
        name: 'Jugador Test',
        birth: DateTime(1995, 6, 15),
        position: PlayerPosition.midfielder,
      )..currentSeasonId = 'season-1';

      final restored = Player.fromMap(original.toMap());

      expect(restored.id, equals(original.id));
      expect(restored.name, equals(original.name));
      expect(restored.birth, equals(original.birth));
      expect(restored.position, equals(original.position));
      expect(restored.currentSeasonId, equals(original.currentSeasonId));
    });

    test('Season', () {
      final original = Season(
        id: 's-1',
        startDate: 2024,
        endDate: 2025,
        stats: {'goals': 10, 'assists': 5},
      );
      final restored = Season.fromMap(original.toMap());

      expect(restored.id, equals(original.id));
      expect(restored.startDate, equals(original.startDate));
      expect(restored.endDate, equals(original.endDate));
      expect(restored.stats, equals(original.stats));
    });

    test('Competition - liga', () {
      final original = Competition(
        id: 'c-1',
        name: 'Primera División',
        type: CompetitionType.league,
        numMatchweeks: 38,
      );
      final restored = Competition.fromMap(original.toMap());

      expect(restored.id, equals(original.id));
      expect(restored.name, equals(original.name));
      expect(restored.type, equals(original.type));
      expect(restored.numMatchweeks, equals(original.numMatchweeks));
    });

    test('Competition - torneo con grupos', () {
      final original = Competition(
        id: 'c-2',
        name: 'Copa Regional',
        type: CompetitionType.tournament,
        hasGroups: true,
        hasKnockouts: true,
        numMatchweeks: 6,
        numRounds: 4,
      );
      final restored = Competition.fromMap(original.toMap());

      expect(restored.hasGroups, isTrue);
      expect(restored.hasKnockouts, isTrue);
      expect(restored.numMatchweeks, equals(6));
      expect(restored.numRounds, equals(4));
    });

    test('Match - con stats', () {
      final stats = <String, double>{
        'goals': 2, 'assists': 1, 'shots': 5, 'shots_on_target': 3,
      };
      final original = Match(
        id: 'm-1',
        matchweek: 5,
        date: DateTime(2025, 3, 15),
        opponent: 'Real Madrid',
        goalsFor: 2,
        goalsAgainst: 1,
        stats: Map.from(stats),
      );
      final restored = Match.fromMap(original.toMap());

      expect(restored.id, equals(original.id));
      expect(restored.matchweek, equals(original.matchweek));
      expect(restored.opponent, equals(original.opponent));
      expect(restored.goalsFor, equals(original.goalsFor));
      expect(restored.goalsAgainst, equals(original.goalsAgainst));
      // Las stats manuales se preservan
      expect(restored.stats['goals'], equals(2));
      expect(restored.stats['assists'], equals(1));
    });
  });

  // ─── R09: IDs únicos ─────────────────────────────────────────────────────────

  group('R09 - UUID único por instancia', () {
    test('dos Match sin id tienen IDs distintos', () {
      final m1 = Match(
        date: DateTime.now(), opponent: 'A',
        goalsFor: 1, goalsAgainst: 0, stats: {},
      );
      final m2 = Match(
        date: DateTime.now(), opponent: 'B',
        goalsFor: 0, goalsAgainst: 1, stats: {},
      );
      expect(m1.id, isNot(equals(m2.id)));
    });
  });

  // ─── R10: puntos por resultado ──────────────────────────────────────────────

  group('R10 - MatchResult.points', () {
    test('win = 3, draw = 1, loss = 0', () {
      expect(MatchResult.win.points, equals(3));
      expect(MatchResult.draw.points, equals(1));
      expect(MatchResult.loss.points, equals(0));
    });
  });

  // ─── R11: Match.result consistente con goalsFor/goalsAgainst ───────────────

  group('R11 - Match.result correcto', () {
    Match makeMatch(int gf, int ga) => Match(
      date: DateTime.now(), opponent: 'Test',
      goalsFor: gf, goalsAgainst: ga, stats: {},
    );

    test('gf > ga → win', () => expect(makeMatch(3, 1).result, MatchResult.win));
    test('gf < ga → loss', () => expect(makeMatch(0, 2).result, MatchResult.loss));
    test('gf == ga → draw', () => expect(makeMatch(1, 1).result, MatchResult.draw));
    test('0-0 → draw', () => expect(makeMatch(0, 0).result, MatchResult.draw));
  });

  // ─── R12: Season.date ───────────────────────────────────────────────────────

  group('R12 - Season.date', () {
    test('mismo año: solo muestra un año', () {
      final s = Season(startDate: 2025, endDate: 2025);
      expect(s.date, equals('2025'));
    });

    test('años distintos: muestra rango', () {
      final s = Season(startDate: 2024, endDate: 2025);
      expect(s.date, equals('2024-2025'));
    });
  });

  // ─── R13/R14: Competition.requiresMatchweek / requiresRound ────────────────

  group('R13/R14 - Competition flags por tipo', () {
    test('liga: requiresMatchweek=true, requiresRound=false', () {
      final c = Competition(name: 'Liga', type: CompetitionType.league);
      expect(c.requiresMatchweek, isTrue);
      expect(c.requiresRound, isFalse);
    });

    test('copa: requiresMatchweek=false, requiresRound=true', () {
      final c = Competition(name: 'Copa', type: CompetitionType.cup);
      expect(c.requiresMatchweek, isFalse);
      expect(c.requiresRound, isTrue);
    });

    test('torneo: requiresMatchweek=false, requiresRound=true', () {
      final c = Competition(name: 'Torneo', type: CompetitionType.tournament);
      expect(c.requiresMatchweek, isFalse);
      expect(c.requiresRound, isTrue);
    });

    test('amistoso: ambos false', () {
      final c = Competition(name: 'Amistoso', type: CompetitionType.friendly);
      expect(c.requiresMatchweek, isFalse);
      expect(c.requiresRound, isFalse);
    });
  });

  group('Objective', () {
    test('R08 - toMap/fromMap idempotente', () {
      final original = TestFactories.objective(
        statId: 'goals',
        target: 15,
        isPositive: false,
      );
      final restored = Objective.fromMap(original.toMap());

      expect(restored.id, equals(original.id));
      expect(restored.statId, equals(original.statId));
      expect(restored.target, equals(original.target));
      expect(restored.isPositive, equals(original.isPositive));
    });

    group('isPositive semántica', () {
      test('objetivo positivo: target por defecto es true', () {
        final obj = Objective(statId: 'goals', target: 10);
        expect(obj.isPositive, isTrue);
      });

      test('objetivo negativo se serializa y restaura correctamente', () {
        final obj = Objective(
          statId: 'yellow_cards',
          target: 5,
          isPositive: false,
        );
        final restored = Objective.fromMap(obj.toMap());
        expect(restored.isPositive, isFalse);
      });
    });

    group('target', () {
      test('acepta valores decimales', () {
        final obj = Objective(statId: 'pass_accuracy', target: 75.5);
        final restored = Objective.fromMap(obj.toMap());
        expect(restored.target, equals(75.5));
      });

      test('acepta target cero', () {
        final obj = Objective(statId: 'red_cards', target: 0, isPositive: false);
        expect(obj.target, equals(0));
      });
    });
  });
}
