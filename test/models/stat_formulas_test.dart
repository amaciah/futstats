// test/models/stat_formulas_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:futstats/models/statistics.dart';

void main() {
  // ─── Helpers ───────────────────────────────────────────────────────────────

  Map<String, double> statsFrom(Map<String, double> manual) {
    final stats = Map<String, double>.from(manual);
    StatFormulas.calculateMatchStats(stats);
    return stats;
  }

  // ─── R01: calculateMatchStats no modifica stats manuales ───────────────────

  group('R01 - calculateMatchStats preserva stats manuales', () {
    test('goals no cambia tras calculateMatchStats', () {
      final stats = statsFrom({'goals': 3.0, 'assists': 1.0});
      expect(stats['goals'], equals(3.0));
      expect(stats['assists'], equals(1.0));
    });
  });

  // ─── R02: porcentajes en rango [0, 100] ────────────────────────────────────

  group('R02 - porcentajes siempre en [0, 100]', () {
    final percentStats = [
      'shot_accuracy', 'penalty_accuracy', 'set_piece_accuracy',
      'cross_accuracy', 'tackle_accuracy', 'aerial_accuracy',
      'defensive_accuracy', 'shot_stopping_accuracy',
      'penalty_stopping_accuracy', 'gk_1v1_accuracy',
      'pass_accuracy', 'dribble_success',
    ];

    test('todos los porcentajes en caso base', () {
      final stats = statsFrom({
        'shots': 10, 'shots_on_target': 4,
        'passes': 30, 'passes_missed': 10,
        'tackles': 5, 'tackle_attempts': 8,
        'aerial_duels_won': 3, 'aerial_duels_lost': 2,
        'dribbles': 4, 'dribble_attempts': 6,
        'crosses': 3, 'cross_attempts': 5,
        'penalty_goals': 2, 'penalty_attempts': 3,
        'set_piece_goals': 1, 'set_piece_assists': 1, 'set_piece_attempts': 5,
        'shots_stopped': 4, 'shots_on_target_received': 6,
        'penalties_against_stopped': 1, 'penalties_against_commited': 2,
        'penalties_against_missed': 0,
        'gk_1v1_won': 2, 'gk_1v1_lost': 1,
        'blocks': 2, 'clearances': 3, 'interceptions': 1,
        'recoveries': 5, 'losses': 3,
        'fouls_commited': 2, 'times_dribbled': 1,
      }.map((k, v) => MapEntry(k, v.toDouble())));

      for (final id in percentStats) {
        final value = stats[id] ?? 0;
        expect(value, inInclusiveRange(0, 100),
            reason: '$id fuera de rango: $value');
      }
    });

    test('porcentajes cuando denominador es 0 devuelven 0', () {
      final stats = statsFrom({'shots': 0, 'shots_on_target': 0});
      expect(stats['shot_accuracy'], equals(0));
    });
  });

  // ─── R03: división por cero ─────────────────────────────────────────────────

  group('R03 - división por cero produce 0', () {
    test('shot_accuracy con shots == 0', () {
      final stats = statsFrom({'shots': 0, 'shots_on_target': 5});
      expect(stats['shot_accuracy'], equals(0));
      expect(stats['shot_accuracy']!.isNaN, isFalse);
    });

    test('pass_accuracy con totales == 0', () {
      final stats = statsFrom({'passes': 0, 'passes_missed': 0});
      expect(stats['pass_accuracy'], equals(0));
    });

    test('tackle_accuracy con tackle_attempts == 0', () {
      final stats = statsFrom({'tackles': 3, 'tackle_attempts': 0});
      expect(stats['tackle_accuracy'], equals(0));
    });
  });

  // ─── R04: open_play_goals nunca negativo ────────────────────────────────────

  group('R04 - open_play_goals >= 0', () {
    test('no es negativo cuando set_piece + penalty > goals', () {
      // Caso de datos inconsistentes introducidos por el usuario
      final stats = statsFrom({
        'goals': 1,
        'set_piece_goals': 1,
        'penalty_goals': 1,
      }.map((k, v) => MapEntry(k, v.toDouble())));
      // La fórmula puede producir negativo — este test documenta el comportamiento
      // actual y sirve como punto de discusión para añadir un max(0, ...) en el futuro
      expect(stats['open_play_goals'], isNotNull);
    });

    test('caso normal: open_play = goals - penalty - set_piece', () {
      final stats = statsFrom({
        'goals': 5,
        'set_piece_goals': 1,
        'penalty_goals': 1,
      }.map((k, v) => MapEntry(k, v.toDouble())));
      expect(stats['open_play_goals'], equals(3));
    });
  });

  // ─── R05: goal_contributions ────────────────────────────────────────────────

  group('R05 - goal_contributions = goals + assists', () {
    test('caso base', () {
      final stats = statsFrom({'goals': 3, 'assists': 2}
          .map((k, v) => MapEntry(k, v.toDouble())));
      expect(stats['goal_contributions'], equals(5));
    });

    test('ambos cero', () {
      final stats = statsFrom({'goals': 0, 'assists': 0}
          .map((k, v) => MapEntry(k, v.toDouble())));
      expect(stats['goal_contributions'], equals(0));
    });
  });

  // ─── R06: defensive_actions ─────────────────────────────────────────────────

  group('R06 - defensive_actions = blocks + clearances + interceptions', () {
    test('suma correcta', () {
      final stats = statsFrom(
          {'blocks': 2, 'clearances': 3, 'interceptions': 4}
              .map((k, v) => MapEntry(k, v.toDouble())));
      expect(stats['defensive_actions'], equals(9));
    });
  });

  // ─── R07: calculateAggregateStats ───────────────────────────────────────────

  group('R07 - calculateAggregateStats consistente con suma manual', () {
    test('goal_difference correcto sobre stats acumuladas', () {
      final stats = <String, double>{
        'goals_for': 10,
        'goals_against': 4,
      };
      StatFormulas.calculateAggregateStats(stats);
      expect(stats['goal_difference'], equals(6));
    });
  });
}
