import 'package:futstats/models/season.dart';
import 'package:futstats/services/firestore_service.dart';

class SeasonRepository {
  final FirestoreService _firestoreService = FirestoreService();

  // Crear o actualizar una temporada
  Future<void> setSeason(String playerId, Season season) async =>
      await _firestoreService.setDocument(
          'players/$playerId/seasons', season.id, season.toMap());

  // Obtener una temporada de un jugador
  Future<Season?> getSeason(String playerId, String seasonId) async {
    var doc = await _firestoreService.getDocument(
        'players/$playerId/seasons', seasonId);
    if (doc.exists) {
      return Season.fromMap(doc.data() as Map<String, dynamic>);
    } else {
      return null;
    }
  }

  // Eliminar una temporada
  Future<void> deleteSeason(String playerId, String seasonId) async =>
      await _firestoreService.deleteDocument(
          'players/$playerId/seasons', seasonId);

  // Obtener todas las temporadas de un jugador
  Future<List<Season>> getAllSeasons(String playerId) async {
    var querySnapshot =
        await _firestoreService.getCollection('players/$playerId/seasons');
    return querySnapshot.docs
        .map((doc) => Season.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
