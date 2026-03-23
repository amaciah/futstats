import 'package:futstats/main.dart';
import 'package:futstats/models/objective.dart';
import 'package:futstats/services/firestore_service.dart';

class ObjectiveRepository {
  ObjectiveRepository({
    required String seasonId,
  }) : collectionPath =
            '${MyApp.seasonRepo.collectionPath}/$seasonId/objectives';

  final FirestoreService _firestoreService = FirestoreService();
  final String collectionPath;

  // Crear o actualizar un objetivo
  Future<void> setObjective(Objective objective) async =>
      await _firestoreService.setDocument(
          collectionPath, objective.id, objective.toMap());

  // Obtener un objetivo de una temporada
  Future<Objective?> getObjective(String objectiveId) async {
    var doc = await _firestoreService.getDocument(collectionPath, objectiveId);
    if (doc.exists) {
      return Objective.fromMap(doc.data() as Map<String, dynamic>);
    } else {
      return null;
    }
  }

  // Eliminar un objetivo
  Future<void> deleteObjective(String objectiveId) async =>
      await _firestoreService.deleteDocument(collectionPath, objectiveId);

  // Obtener todos los objetivos de una temporada
  Future<List<Objective>> getAllObjectives() async {
    var querySnapshot = await _firestoreService.getCollection(collectionPath);
    return querySnapshot.docs
        .map((doc) => Objective.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
