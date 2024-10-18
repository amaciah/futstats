import 'package:futstats/models/objective.dart';
import 'package:futstats/services/firestore_service.dart';

class ObjectiveRepository {
  final FirestoreService _firestoreService = FirestoreService();

  // Crear o actualizar un objetivo
  Future<void> setObjective(
          String playerId, String seasonId, Objective objective) async =>
      await _firestoreService.setDocument(
          'players/$playerId/seasons/$seasonId/objectives',
          objective.id,
          objective.toMap());

  // Obtener un objetivo de una temporada
  Future<Objective?> getObjective(
      String playerId, String seasonId, String objectiveId) async {
    var doc = await _firestoreService.getDocument(
        'players/$playerId/seasons/$seasonId/objectives', objectiveId);
    if (doc.exists) {
      return Objective.fromMap(doc.data() as Map<String, dynamic>);
    } else {
      return null;
    }
  }

  // Eliminar un objetivo
  Future<void> deleteObjective(
          String playerId, String seasonId, String objectiveId) async =>
      await _firestoreService.deleteDocument(
          'players/$playerId/seasons/$seasonId/objectives', objectiveId);

  // Obtener todos los objetivos de una temporada
  Future<List<Objective>> getAllObjectives(
      String playerId, String seasonId) async {
    var querySnapshot = await _firestoreService
        .getCollection('players/$playerId/seasons/$seasonId/objectives');
    return querySnapshot.docs
        .map((doc) => Objective.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
