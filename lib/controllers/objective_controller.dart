// objective_controller.dart

import 'package:futstats/models/objective.dart';
import 'package:futstats/services/repositories/objective_repository.dart';

class ObjectiveController {
  ObjectiveController({
    required String playerId,
    required String seasonId,
  }) : objectiveRepo = ObjectiveRepository(
          playerId: playerId,
          seasonId: seasonId,
        );

  final ObjectiveRepository objectiveRepo;

  Future<Objective?> loadObjective(String objectiveId) =>
      objectiveRepo.get(objectiveId);

  Future<void> saveObjective(Objective objective) =>
      objectiveRepo.set(objective);

  Future<void> deleteObjective(String objectiveId) =>
      objectiveRepo.delete(objectiveId);

  Future<List<Objective>> loadAllObjectives() =>
      objectiveRepo.getAll();
}
