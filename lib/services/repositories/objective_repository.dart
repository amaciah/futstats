// objective_repository.dart

import 'package:futstats/models/objective.dart';
import 'package:futstats/services/firestore_paths.dart';
import 'package:futstats/services/repositories/firestore_repository.dart';

class ObjectiveRepository extends FirestoreRepository<Objective> {
  ObjectiveRepository({
    required String playerId, 
    required String seasonId,
  }) : super(FirestorePaths.objectiveCollectionPath(playerId, seasonId));

  @override
  Objective fromMap(Map<String, dynamic> map) => Objective.fromMap(map);

  @override
  Map<String, dynamic> toMap(Objective model) => model.toMap();

  @override
  String getDocumentId(Objective model) => model.id;
}
