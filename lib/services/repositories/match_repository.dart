// services/repositories/match_repository.dart

import 'package:futstats/models/match.dart';
import 'package:futstats/services/firestore_paths.dart';
import 'package:futstats/services/repositories/firestore_repository.dart';

class MatchRepository extends FirestoreRepository<Match> {
  MatchRepository({
    required String playerId, 
    required String seasonId, 
    required String competitionId,
  }) : super(FirestorePaths.matchCollectionPath(playerId, seasonId, competitionId));

  @override
  Match fromMap(Map<String, dynamic> map) => Match.fromMap(map);

  @override
  Map<String, dynamic> toMap(Match model) => model.toMap();

  @override
  String getDocumentId(Match model) => model.id;
}
