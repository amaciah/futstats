// season_controller.dart

import 'package:futstats/models/season.dart';
import 'package:futstats/services/repositories/season_repository.dart';

class SeasonController {
  SeasonController({
    required String playerId,
  }) : seasonRepo = SeasonRepository(playerId: playerId);

  final SeasonRepository seasonRepo;

  Future<Season?> loadSeason(String seasonId) =>
      seasonRepo.get(seasonId);

  Future<void> saveSeason(Season season) =>
      seasonRepo.set(season);

  Future<void> deleteSeason(String seasonId) =>
      seasonRepo.delete(seasonId);

  Future<List<Season>> loadAllSeasons() =>
      seasonRepo.getAll();
}
