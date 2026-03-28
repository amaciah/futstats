// competition_controller.dart

import 'package:futstats/models/competition.dart';
import 'package:futstats/services/repositories/competition_repository.dart';

class CompetitionController {
  CompetitionController({
    required String playerId,
    required String seasonId,
  }) : competitionRepo = CompetitionRepository(
          playerId: playerId,
          seasonId: seasonId,
        );

  final CompetitionRepository competitionRepo;

  Future<Competition?> loadCompetition(String competitionId) =>
      competitionRepo.get(competitionId);

  Future<void> saveCompetition(Competition competition) =>
      competitionRepo.set(competition);

  Future<void> deleteCompetition(String competitionId) =>
      competitionRepo.delete(competitionId);

  Future<List<Competition>> loadAllCompetitions() =>
      competitionRepo.getAll();
}
