// services/repositories/player_repository.dart

import 'package:futstats/models/player.dart';
import 'package:futstats/services/firestore_paths.dart';
import 'package:futstats/services/repositories/firestore_repository.dart';

class PlayerRepository extends FirestoreRepository<Player> {
  PlayerRepository()
      : super(FirestorePaths.playerCollectionPath());

  @override
  Player fromMap(Map<String, dynamic> map) => Player.fromMap(map);

  @override
  Map<String, dynamic> toMap(Player model) => model.toMap();

  @override
  String getDocumentId(Player model) => model.id;
}
