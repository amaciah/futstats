import 'package:futstats/main.dart';
import 'package:futstats/services/firestore_service.dart';

class StatisticRepository {
  StatisticRepository({
    required String seasonId,
  }) : collectionPath =
            '${MyApp.seasonRepo.collectionPath}/$seasonId/statistics';

  final FirestoreService _firestoreService = FirestoreService();
  final String collectionPath;
  final String documentId = 'stats';

  // Crear o actualizar las estadísticas acumuladas de una temporada
  Future<void> setSeasonStatistics(Map<String, double> stats) async =>
      await _firestoreService.setDocument(collectionPath, documentId, stats);

  // Obtener las estadísticas acumuladas de una temporada
  Future<Map<String, double>> getSeasonStatistics() async {
    var doc = await _firestoreService.getDocument(collectionPath, documentId);
    if (doc.exists) {
      return Map<String, double>.from(doc.data() as Map<String, dynamic>);
    } else {
      return {};
    }
  }
}
