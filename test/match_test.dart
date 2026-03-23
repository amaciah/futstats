import 'package:flutter_test/flutter_test.dart';
import 'package:futstats/models/match.dart';

void main() {
  group('MatchResult enum', () {
    test('points getter returns correct values', () {
      expect(MatchResult.win.points, 3);
      expect(MatchResult.draw.points, 1);
      expect(MatchResult.loss.points, 0);
    });

    test('color getter returns correct colors', () {
      expect(MatchResult.win.color, isNotNull);
      expect(MatchResult.draw.color, isNotNull);
      expect(MatchResult.loss.color, isNotNull);
    });
  });

  group('Match class', () {
    final stats = {'shots': 10.0, 'possession': 55.0};

    test('constructor assigns values and generates id if not provided', () {
      final match = Match(
        matchweek: 1,
        date: DateTime(2024, 6, 1),
        opponent: 'Team B',
        goalsFor: 2,
        goalsAgainst: 1,
        stats: stats,
      );
      expect(match.id, isNotNull);
      expect(match.matchweek, 1);
      expect(match.date, DateTime(2024, 6, 1));
      expect(match.opponent, 'Team B');
      expect(match.goalsFor, 2);
      expect(match.goalsAgainst, 1);
      expect(match.stats, stats);
    });

    test('constructor uses provided id', () {
      final match = Match(
        id: 'custom-id',
        matchweek: 2,
        date: DateTime(2024, 6, 2),
        opponent: 'Team C',
        goalsFor: 0,
        goalsAgainst: 0,
        stats: stats,
      );
      expect(match.id, 'custom-id');
    });

    test('result getter returns win', () {
      final match = Match(
        matchweek: 3,
        date: DateTime(2024, 6, 3),
        opponent: 'Team D',
        goalsFor: 3,
        goalsAgainst: 1,
        stats: stats,
      );
      expect(match.result, MatchResult.win);
    });

    test('result getter returns draw', () {
      final match = Match(
        matchweek: 4,
        date: DateTime(2024, 6, 4),
        opponent: 'Team E',
        goalsFor: 2,
        goalsAgainst: 2,
        stats: stats,
      );
      expect(match.result, MatchResult.draw);
    });

    test('result getter returns loss', () {
      final match = Match(
        matchweek: 5,
        date: DateTime(2024, 6, 5),
        opponent: 'Team F',
        goalsFor: 0,
        goalsAgainst: 1,
        stats: stats,
      );
      expect(match.result, MatchResult.loss);
    });

    test('toMap returns correct map', () {
      final date = DateTime(2024, 6, 6);
      final match = Match(
        id: 'test-id',
        matchweek: 6,
        date: date,
        opponent: 'Team G',
        goalsFor: 1,
        goalsAgainst: 0,
        stats: stats,
      );
      final map = match.toMap();
      expect(map['id'], 'test-id');
      expect(map['matchweek'], 6);
      expect(map['date'], date.toIso8601String());
      expect(map['opponent'], 'Team G');
      expect(map['goalsFor'], 1);
      expect(map['goalsAgainst'], 0);
      expect(map['stats'], stats);
    });

    test('fromMap creates correct Match object', () {
      final date = DateTime(2024, 6, 7);
      final map = {
        'id': 'frommap-id',
        'matchweek': 7,
        'date': date.toIso8601String(),
        'opponent': 'Team H',
        'goalsFor': 4,
        'goalsAgainst': 2,
        'stats': stats,
      };
      final match = Match.fromMap(map);
      expect(match.id, 'frommap-id');
      expect(match.matchweek, 7);
      expect(match.date, date);
      expect(match.opponent, 'Team H');
      expect(match.goalsFor, 4);
      expect(match.goalsAgainst, 2);
      expect(match.stats, stats);
    });
  });
}

