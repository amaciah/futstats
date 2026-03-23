import 'package:futstats/main.dart';
import 'package:futstats/models/season.dart';
import 'package:futstats/services/firestore_service.dart';

class SeasonRepository {
  SeasonRepository({
    required String playerId,
  }) : collectionPath = '${MyApp.playerRepo.collectionPath}/$playerId/seasons';

  final FirestoreService _firestoreService = FirestoreService();
  final String collectionPath;

  // Crear o actualizar una temporada
  Future<void> setSeason(Season season) async => await _firestoreService
      .setDocument(collectionPath, season.id, season.toMap());

  // Obtener una temporada de un jugador
  Future<Season?> getSeason(String seasonId) async {
    var doc = await _firestoreService.getDocument(collectionPath, seasonId);
    if (doc.exists) {
      return Season.fromMap(doc.data() as Map<String, dynamic>);
    } else {
      return null;
    }
  }

  // Eliminar una temporada
  Future<void> deleteSeason(String seasonId) async =>
      await _firestoreService.deleteDocument(collectionPath, seasonId);

  // Obtener todas las temporadas de un jugador
  Future<List<Season>> getAllSeasons() async {
    var querySnapshot = await _firestoreService.getCollection(collectionPath);
    return querySnapshot.docs
        .map((doc) => Season.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
