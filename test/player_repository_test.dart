import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futstats/firebase_options.dart';
import 'package:futstats/repositories/player_repository.dart';
import 'package:futstats/models/player.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });
  
  group('PlayerRepository CRUD Operations', () {
    final playerRepo = PlayerRepository();
    final testPlayer = Player(name: 'Cristiano Ronaldo', position: PlayerPosition.attacker);

    // Agregar jugador
    test('Add Player', () async {
      await playerRepo.setPlayer(testPlayer);
      final retrievedPlayer = await playerRepo.getPlayer(testPlayer.id);
      expect(retrievedPlayer?.name, equals('Cristiano Ronaldo'));
      expect(retrievedPlayer?.position, equals(PlayerPosition.attacker));
    });

    // Obtener jugador
    test('Get Player by ID', () async {
      final retrievedPlayer = await playerRepo.getPlayer(testPlayer.id);
      expect(retrievedPlayer, isNotNull);
      expect(retrievedPlayer?.name, equals('Cristiano Ronaldo'));
    });

    // Actualizar jugador
    test('Update Player', () async {
      final updatedPlayer = Player(
        id: testPlayer.id,
        name: 'CR7',
        position: PlayerPosition.attacker,
      );
      await playerRepo.setPlayer(updatedPlayer);

      final retrievedUpdatedPlayer = await playerRepo.getPlayer(testPlayer.id);
      expect(retrievedUpdatedPlayer?.name, equals('CR7'));
    });

    // Eliminar jugador
    test('Delete Player', () async {
      await playerRepo.deletePlayer(testPlayer.id);
      final deletedPlayer = await playerRepo.getPlayer(testPlayer.id);
      expect(deletedPlayer, isNull);
    });
  });
}
