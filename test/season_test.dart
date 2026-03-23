import 'package:test/test.dart';
import 'package:futstats/models/season.dart';
import 'package:futstats/models/match.dart';
import 'package:futstats/models/objective.dart';

void main() {
  group('Season Model Tests', () {
    test('- Season Serialization', testSeasonSerialization);

    test('- Season Deserialization', testSeasonDeserialization);

    test('- Season generates ID if none provided', testSeasonIdGeneration);
  });
}

// Crear y serializar una temporada
testSeasonSerialization() {
  var match = Match(
    matchweek: 5,
    date: DateTime(2023, 10, 3),
    opponent: 'FC Barcelona',
    stats: {'goals': 2.0, 'assists': 1.0},
  );

  var objective = Objective(
    statId: 'stat1',
    target: 5.0,
    isPositive: true,
  );

  var season = Season(
    year: '2023',
    matches: [match],
    seasonStats: {'goals': 10.0},
    objectives: [objective],
  );

  var seasonMap = season.toMap();
  expect(seasonMap['year'], equals('2023'));
  expect(seasonMap['matches'][0]['opponent'], equals('FC Barcelona'));
  expect(seasonMap['seasonStats']['goals'], equals(10.0));
  expect(seasonMap['objectives'][0]['statId'], equals('stat1'));
}

// Deserializar una temporada
testSeasonDeserialization() {
  var seasonMap = {
    'id': 'season1',
    'year': '2023',
    'matches': [
      {
        'id': 'match1',
        'matchweek': 5,
        'date': '2023-10-03T00:00:00.000',
        'opponent': 'FC Barcelona',
        'stats': {'goals': 2.0, 'assists': 1.0},
      }
    ],
    'seasonStats': {'goals': 10.0},
    'objectives': [
      {'id': 'obj1', 'statId': 'stat1', 'target': 5.0, 'isPositive': true}
    ]
  };

  var season = Season.fromMap(seasonMap);
  expect(season.id, equals('season1'));
  expect(season.year, equals('2023'));
  expect(season.matches[0].opponent, equals('FC Barcelona'));
  expect(season.seasonStats['goals'], equals(10.0));
  expect(season.objectives[0].statId, equals('stat1'));
}

// Generar ID si no se proporciona
testSeasonIdGeneration() {
  var season = Season(
    year: '2023',
    matches: [],
    seasonStats: {},
    objectives: [],
  );
  expect(season.id, isNotNull);
}
