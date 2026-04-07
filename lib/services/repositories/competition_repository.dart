// services/repositories/competition_repository.dart

import 'package:futstats/models/competition.dart';
import 'package:futstats/services/firestore_paths.dart';
import 'package:futstats/services/repositories/firestore_repository.dart';

class CompetitionRepository extends FirestoreRepository<Competition> {
  CompetitionRepository({
    required String playerId, 
    required String seasonId,
  }) : super(FirestorePaths.competitionCollectionPath(playerId, seasonId));

  @override
  Competition fromMap(Map<String, dynamic> map) => Competition.fromMap(map);

  @override
  Map<String, dynamic> toMap(Competition model) => model.toMap();

  @override
  String getDocumentId(Competition model) => model.id;
}
