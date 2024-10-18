import 'package:futstats/models/statistic.dart';
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
    title: 'Defensive actions',
    shortTitle: 'D. actions',
    category: StatCategory.defense,
    initialValue: 25.0,
  );

  var statMap = stat.toMap();
  expect(statMap['id'], equals('stat2'));
  expect(statMap['title'], equals('Defensive actions'));
  expect(statMap['shortTitle'], equals('D. actions'));
  expect(statMap['category'], equals('defense'));
  expect(statMap['value'], equals(25.0));
}

// Deserializar una estadística
void testStatisticDeserialization() {
  var statMap = {
    'id': 'stat1',
    'title': 'Goals',
    'shortTitle': 'Goals',
    'category': 'attack',
    'value': 5.0,
  };

  var stat = Statistic.fromMap(statMap);
  expect(stat.id, equals('stat1'));
  expect(stat.title, equals('Goals'));
  expect(stat.shortTitle, equals('Goals'));
  expect(stat.category, equals(StatCategory.attack));
  expect(stat.value, equals(5.0));
}

// Inicializar 'shortTitle' si no se proporciona
void testStatisticShortTitleInitialization() {
  var stat = ManualStat(
    id: 'stat1',
    title: 'Goals',
    category: StatCategory.attack,
    initialValue: 5.0,
  );
  expect(stat.shortTitle, equals('Goals'));
}

// Cambiar el valor de una estadística manual
void testManualStatisticValueUpdate() {
  var stat = ManualStat(
    id: 'stat1',
    title: 'Goals',
    category: StatCategory.attack,
    initialValue: 5.0,
  );
  stat.value = 10.0;
  expect(stat.value, equals(10.0));
}

// Calcular valor de una estadística calculada mediante fórmula
void testCalculatedStatisticValueCalculation() {
  var stat = CalculatedStat(
    id: 'stat2',
    title: 'Defensive actions',
    shortTitle: 'D. actions',
    category: StatCategory.defense,
    calculationFunction: () => 3.0 + 5.0 + 8.0,
  );
  expect(stat.value, equals(16.0));
}
