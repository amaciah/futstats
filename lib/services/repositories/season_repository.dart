// services/repositories/season_repository.dart

import 'package:futstats/models/season.dart';
import 'package:futstats/services/firestore_paths.dart';
import 'package:futstats/services/repositories/firestore_repository.dart';

class SeasonRepository extends FirestoreRepository<Season> {
  SeasonRepository({
    required String playerId,
  }) : super(FirestorePaths.seasonCollectionPath(playerId));

  @override
  Season fromMap(Map<String, dynamic> map) => Season.fromMap(map);

  @override
  Map<String, dynamic> toMap(Season model) => model.toMap();

  @override
  String getDocumentId(Season model) => model.id;
}
