import 'package:futstats/models/objective.dart';
import 'package:test/test.dart';

void main() {
  group('Objective tests', () {
    test('- Objective serialization', testObjectiveSerialization);
    test('- Objective deserialization', testObjectiveDeserialization);
    test('- Objective generates ID if none provided', testObjectiveIdGeneration);
    test('- Positive Objective target is calculated correctly',
        testPositiveObjectiveTargetMet);
    test('- Negative Objective target is calculated correctly',
        testNegativeObjectiveTargetMet);
  });
}

// Crear y serializar un objetivo
void testObjectiveSerialization() {
  var objective = Objective(
    statId: 'stat1',
    target: 5.0,
    isPositive: true,
  );

  var objectiveMap = objective.toMap();
  expect(objectiveMap['statId'], equals('stat1'));
  expect(objectiveMap['target'], equals(5.0));
  expect(objectiveMap['isPositive'], equals(true));
}

// Deserializar un objetivo
void testObjectiveDeserialization() {
  var objectiveMap = {
    'id': 'obj1',
    'statId': 'stat1',
    'target': 5.0,
    'isPositive': true,
  };

  var objective = Objective.fromMap(objectiveMap);
  expect(objective.id, equals('obj1'));
  expect(objective.statId, equals('stat1'));
  expect(objective.target, equals(5.0));
}

// Generar ID si no se proporciona
void testObjectiveIdGeneration() {
  var objective = Objective(
    statId: 'stat2',
    target: 10.0,
  );
  expect(objective.id, isNotNull);
}

// Calcular objetivo positivo cumplido
void testPositiveObjectiveTargetMet() {
  var objective = Objective(
    statId: "goals",
    target: 5,
    isPositive: true,
  );

  var stat = ManualStat(
    id: "goals",
    initialValue: 3,
  );

  expect(objective.isTargetMet, equals(false)); // No se han alcanzado 5 goles
  stat.value = 5;
  expect(objective.isTargetMet, equals(true)); // Objetivo alcanzado
}

// Calcular objetivo negativo cumplido
void testNegativeObjectiveTargetMet() {
  var objective = Objective(
    statId: "goals",
    target: 5,
    isPositive: false,
  );

  var stat = ManualStat(
    id: "goals_conceded",
    initialValue: 3,
  );

  expect(objective.isTargetMet, equals(true)); // Cumpliendo objetivo
  stat.value = 5;
  expect(objective.isTargetMet, equals(false)); // Se han alcanzado 5 goles
}

