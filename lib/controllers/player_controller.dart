// controllers/player_controller.dart

import 'package:futstats/models/player.dart';
import 'package:futstats/services/repositories/player_repository.dart';

class PlayerController {
  PlayerController({PlayerRepository? repo})
      : _playerRepo = repo ?? PlayerRepository();

  PlayerRepository get playerRepo => _playerRepo;
  final PlayerRepository _playerRepo;

  Future<Player?> loadPlayer(String userId) =>
      playerRepo.get(userId);

  Future<void> savePlayer(Player player) =>
      playerRepo.set(player);

  Future<void> deletePlayer(String userId) =>
      playerRepo.delete(userId);

  Future<void> setCurrentSeason(Player player, String seasonId) async {
    player.currentSeasonId = seasonId;
    await savePlayer(player);
  }
}
