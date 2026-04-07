// controllers/season_controller.dart

import 'package:futstats/models/season.dart';
import 'package:futstats/services/repositories/season_repository.dart';

class SeasonController {
  SeasonController({
    required String playerId,
    SeasonRepository? repo,
  }) : _seasonRepo = repo ?? SeasonRepository(playerId: playerId);

  SeasonRepository get seasonRepo => _seasonRepo;
  final SeasonRepository _seasonRepo;

  Future<Season?> loadSeason(String seasonId) =>
      seasonRepo.get(seasonId);

  Future<void> saveSeason(Season season) =>
      seasonRepo.set(season);

  Future<void> deleteSeason(String seasonId) =>
      seasonRepo.delete(seasonId);

  Future<List<Season>> loadAllSeasons() =>
      seasonRepo.getAll();
}
