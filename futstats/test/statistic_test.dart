import 'package:test/test.dart';

void main() {
  group('Statistic model tests', () {
    test('- Statistic serialization', testStatisticSerialization);

    test('- Statistic deserialization', testStatisticDeserialization);
    test('- Statistic initializes shortTitle if not provided',
        testStatisticShortTitleInitialization);

    test('- ManualStat value update', testManualStatisticValueUpdate);
  });
}

// Crear y serializar una estadística
testStatisticSerialization() {
  var stat = ManualStat(
    id: 'stat2',
    initialValue: 25.0,
  );

  var statMap = stat.toMap();
  expect(statMap['id'], equals('stat2'));
  expect(statMap['value'], equals(25.0));
}

// Deserializar una estadística
void testStatisticDeserialization() {
  var statMap = {
    'id': 'stat1',
    'value': 5.0,
  };

  var stat = Statistic.fromMap(statMap);
  expect(stat.id, equals('stat1'));
  expect(stat.value, equals(5.0));
}

// Inicializar 'shortTitle' si no se proporciona
void testStatisticShortTitleInitialization() {
  var stat = ManualStat(
    id: 'stat1',
    initialValue: 5.0,
  );
}

// Cambiar el valor de una estadística manual
void testManualStatisticValueUpdate() {
  var stat = ManualStat(
    id: 'stat1',
    initialValue: 5.0,
  );
  stat.value = 10.0;
  expect(stat.value, equals(10.0));
}

// Calcular valor de una estadística calculada mediante fórmula
void testCalculatedStatisticValueCalculation() {
  var stat = CalculatedStat(
    id: 'stat2',
    calculationFunction: () => 3.0 + 5.0 + 8.0,
  );
  expect(stat.value, equals(16.0));
}
