import 'package:futstats/models/player.dart';
import 'package:futstats/services/firestore_service.dart';

class PlayerRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final String collectionPath = 'players';

  // Crear o actualizar un jugador
  Future<void> setPlayer(Player player) async => await _firestoreService
      .setDocument(collectionPath, player.id, player.toMap());

  // Obtener un jugador
  Future<Player?> getPlayer(String playerId) async {
    var doc = await _firestoreService.getDocument(collectionPath, playerId);
    if (doc.exists) {
      return Player.fromMap(doc.data() as Map<String, dynamic>);
    } else {
      return null;
    }
  }

  // Eliminar un jugador
  Future<void> deletePlayer(String playerId) async =>
      await _firestoreService.deleteDocument(collectionPath, playerId);
}
