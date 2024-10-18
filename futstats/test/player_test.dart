import 'package:futstats/models/player.dart';
import 'package:test/test.dart';

void main() {
  group('Player model tests', () {
    test('- Player serialization', testPlayerSerialization);
    test('- Player deserialization', testPlayerDeserialization);
    test('- Player generates ID if none provided', testPlayerIdGeneration);
  });
}

// Crear y serializar un jugador
void testPlayerSerialization() {
  var player = Player(
    name: "Juan Pérez",
    position: PlayerPosition.midfielder,
  );

  var playerMap = player.toMap();
  expect(playerMap['name'], equals("Juan Pérez"));
  expect(playerMap['position'], equals("midfielder"));
}

// Deserializar un jugador
void testPlayerDeserialization() {
  var playerMap = {
    'id': 'player1',
    'name': 'Juan Pérez',
    'position': 'midfielder',
  };

  var player = Player.fromMap(playerMap);
  expect(player.id, equals('player1'));
  expect(player.name, equals("Juan Pérez"));
  expect(player.position, equals(PlayerPosition.midfielder));
}

// Generar ID si no se proporciona
void testPlayerIdGeneration() {
  var player = Player(
    name: "Carlos López",
    position: PlayerPosition.attacker,
  );
  expect(player.id, isNotNull);
}
