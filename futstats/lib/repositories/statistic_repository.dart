import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:futstats/main.dart';
import 'package:futstats/models/statistics.dart';
import 'package:futstats/services/firestore_service.dart';

class StatisticRepository {
  StatisticRepository({
    required String seasonId,
  }) : collectionPath =
            '${MyApp.seasonRepo.collectionPath}/$seasonId/statistics';

  final FirestoreService _firestoreService = FirestoreService();
  final String collectionPath;

  // Crear o actualizar una estadística acumulada
  Future<void> setStatistic(Statistic stat) async => await _firestoreService
      .setDocument(collectionPath, stat.id, stat.toMap());

  // Incrementar el valor de una estadística acumulada
  Future<void> incrementStatistic(String statId, double increment) async =>
      await _firestoreService.setDocument(collectionPath, statId,
          {'id': statId, 'value': FieldValue.increment(increment)});

  // Decrementar el valor de una estadística acumulada
  Future<void> decrementStatistic(String statId, double decrement) async =>
      await _firestoreService.setDocument(collectionPath, statId,
          {'id': statId, 'value': FieldValue.increment(-decrement)});

  // Obtener el valor de una estadística acumulada de una temporada
  Future<double> getStatistic(String statId) async {
    var doc = await _firestoreService.getDocument(collectionPath, statId);
    if (doc.exists) {
      return Statistic.fromMap(doc.data() as Map<String, dynamic>).value;
    } else {
      return 0;
    }
  }

  // Eliminar una estadística acumulada
  Future<void> deleteStatistic(String statId) async =>
      await _firestoreService.deleteDocument(collectionPath, statId);

  // Obtener las estadísticas acumuladas de una temporada
  Future<Map<String, double>> getSeasonStatistics() async {
    var querySnapshot = await _firestoreService.getCollection(collectionPath);
    return {
      for (var stat in querySnapshot.docs.map(
        (doc) => Statistic.fromMap(doc.data() as Map<String, dynamic>),
      ))
        stat.id: stat.value
    };
  }
}
