import 'package:futstats/models/statistic.dart';
import 'package:futstats/services/firestore_service.dart';

class StatisticRepository {
  final FirestoreService _firestoreService = FirestoreService();

  // Crear o actualizar una estadística
  Future<void> setStatistic(
          String playerId, String seasonId, Statistic statistic) async =>
      await _firestoreService.setDocument(
          'players/$playerId/seasons/$seasonId/statistics',
          statistic.id,
          statistic.toMap());

  // Obtener una estadística de una temporada
  Future<Statistic?> getStatistic(
      String playerId, String seasonId, String statId) async {
    var doc = await _firestoreService.getDocument(
        'players/$playerId/seasons/$seasonId/statistics', statId);
    if (doc.exists) {
      return Statistic.fromMap(doc.data() as Map<String, dynamic>);
    } else {
      return null;
    }
  }

  // Eliminar una estadística
  Future<void> deleteStatistic(
          String playerId, String seasonId, String statId) async =>
      await _firestoreService.deleteDocument(
          'players/$playerId/seasons/$seasonId/statistics', statId);

  Future<List<Statistic>> getAllStatistics(
      String playerId, String seasonId) async {
    var querySnapshot = await _firestoreService
        .getCollection('players/$playerId/seasons/$seasonId/statistics');
    return querySnapshot.docs
        .map((doc) => Statistic.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, Statistic>> getSeasonStats(
      String playerId, String seasonId) async {
    var statistics = await getAllStatistics(playerId, seasonId);
    return {
      for (var stat in statistics) stat.id: stat,
    };
  }
}
