import 'package:futstats/models/match.dart';
import 'package:test/test.dart';

void main() {
  group('Match model tests', () {
    test('- Match serialization', testMatchSerialization);
    test('- Match deserialization', testMatchDeserialization);
    test('- Match generates ID if none provided', testMatchIdGeneration);
  });
}

// Crear y serializar un partido
void testMatchSerialization() {
  var match = Match(
    matchweek: 5,
    date: DateTime(2023, 10, 3),
    opponent: 'FC Barcelona',
    stats: {'goals': 2, 'assists': 1},
  );

  var matchMap = match.toMap();
  expect(matchMap['matchweek'], equals(5));
  expect(matchMap['opponent'], equals('FC Barcelona'));
  expect(matchMap['stats']['goals'], equals(2.0));
  expect(matchMap['date'], equals('2023-10-03T00:00:00.000'));
}

// Deserializar un partido
void testMatchDeserialization() {
  var matchMap = {
    'id': 'match1',
    'matchweek': 5,
    'date': '2023-10-03T00:00:00.000',
    'opponent': 'FC Barcelona',
    'stats': {'goals': 2.0, 'assists': 1.0},
  };

  var match = Match.fromMap(matchMap);
  expect(match.id, equals('match1'));
  expect(match.matchweek, equals(5));
  expect(match.opponent, equals('FC Barcelona'));
  expect(match.stats['goals'], equals(2.0));
}

// Generar ID si no se proporciona
void testMatchIdGeneration() {
  var match = Match(
    matchweek: 6,
    date: DateTime.now(),
    opponent: 'Real Madrid',
    stats: {'goals': 3.0},
  );
  expect(match.id, isNotNull);
}
