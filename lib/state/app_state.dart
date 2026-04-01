// app_state.dart

import 'package:flutter/material.dart';

import 'package:futstats/controllers/competition_controller.dart';
import 'package:futstats/controllers/match_controller.dart';
import 'package:futstats/controllers/objective_controller.dart';
import 'package:futstats/controllers/player_controller.dart';
import 'package:futstats/controllers/season_controller.dart';
import 'package:futstats/models/competition.dart';
import 'package:futstats/models/match.dart';
import 'package:futstats/models/objective.dart';
import 'package:futstats/models/player.dart';
import 'package:futstats/models/season.dart';
import 'package:futstats/services/repositories/match_repository.dart';

/*
 * AppState es el estado global de la aplicación, que mantiene la información 
 * del jugador y temporada actuales y las competiciones y objetivos asociados.
 * Es un ChangeNotifier para que los widgets puedan reaccionar a los cambios.
 * 
 * AppState también es responsable de cargar y actualizar los datos a través de
 * los controladores, y de mantener la coherencia del estado.
 */
class AppState extends ChangeNotifier {

  // Estado actual
  Player? _player;
  Season? _season;
  Competition? _competition;
  List<Season> seasons = [];
  List<Competition> competitions = [];
  List<Objective> objectives = [];

  // Controladores de primer nivel
  late final _playerController = createPlayerController();

  // Controladores dependientes del estado
  SeasonController? _seasonController;
  CompetitionController? _competitionController;
  ObjectiveController? _objectiveController;

  // Factories para controladores
  @visibleForTesting
  PlayerController createPlayerController() => PlayerController();

  @visibleForTesting
  SeasonController createSeasonController(String playerId) =>
      SeasonController(playerId: playerId);
  
  @visibleForTesting
  CompetitionController createCompetitionController(
          String playerId, String seasonId) => 
      CompetitionController(playerId: playerId, seasonId: seasonId);

  @visibleForTesting
  ObjectiveController createObjectiveController(
          String playerId, String seasonId) => 
      ObjectiveController(playerId: playerId, seasonId: seasonId);

  @visibleForTesting
  MatchController createMatchController(Competition competition) {
    return MatchController(
      matchRepoFactory: (competitionId) => MatchRepository(
        playerId: player!.id,
        seasonId: currentSeason!.id,
        competitionId: competitionId,
      ),
      seasonController: _seasonController!,
      competitionController: _competitionController!,
      season: currentSeason!,
      competition: competition,
    );
  }

  // Getters
  Player? get player => _player;
  Season? get currentSeason => _season;
  Competition? get selectedCompetition => _competition;

  // Lectura y escritura de datos
  Future<Player?> getPlayerById(String userId) =>
      _playerController.loadPlayer(userId);
  
  Future<void> setActivePlayer(Player player) async {
    _player = player;

    // Inicializar controladores dependientes
    _seasonController = createSeasonController(player.id);

    // Reiniciar estado dependiente
    _season = null;
    _competition = null;
    seasons = [];
    competitions = [];
    objectives = [];

    notifyListeners();
  }

  Future<void> savePlayer(Player player) async {
    await _playerController.savePlayer(player);
    await setActivePlayer(player); 
  }

  Future<Season?> getCurrentSeasonFromDB() async {
    if (player == null) return null;
    final seasonId = player!.currentSeasonId;
    if (seasonId == null) return null;

    return _seasonController!.loadSeason(seasonId);
  }

  Future<void> setCurrentSeason(Season season) async {
    if (player == null) return;

    _season = season;
    await _playerController.setCurrentSeason(player!, season.id);
    _player = _player!..currentSeasonId = season.id;

    // Inicializar controladores dependientes
    _competitionController = createCompetitionController(
      player!.id,
      season.id,
    );
    _objectiveController = createObjectiveController(
      player!.id,
      season.id,
    );

    // Cargar competiciones y objetivos
    await loadCompetitions();
    await loadObjectives();

    // Crear competición de amistosos si no existe
    if (!competitions.any((competition) => competition.type.isFriendly)) {
      final friendly = Competition(
        name: 'Amistosos', 
        type: CompetitionType.friendly,
      );
      await _competitionController!.saveCompetition(friendly);
      await loadCompetitions();
    }

    notifyListeners();
  }

  Future<List<Season>> loadSeasons() async {
    if (_seasonController == null) return [];
    seasons = await _seasonController!.loadAllSeasons();
    notifyListeners();
    return seasons;
  }

  Future<void> saveSeason(Season season) async {
    if (_seasonController == null) return;
    await _seasonController!.saveSeason(season);

    // Actualizar lista local si estaba cargada
    final idx = seasons.indexWhere((s) => s.id == season.id);
    if (idx >= 0) {
      seasons[idx] = season;
    } else {
      seasons.add(season);
    }

    notifyListeners();
  }

  Future<void> deleteSeason(String seasonId) async {
    if (_seasonController == null) return;
    await _seasonController!.deleteSeason(seasonId);

    // Actualizar lista local
    seasons.removeWhere((season) => season.id == seasonId);

    // Limpiar estado si se borra temporada actual
    if (_season?.id == seasonId) {
      _season = null;
      _competition = null;
      competitions = [];
      objectives = [];
    }

    notifyListeners();
  }

  Future<void> loadCompetitions() async {
    if (_competitionController == null) return;
    competitions = await _competitionController!.loadAllCompetitions();
    notifyListeners();
  }

  Future<void> saveCompetition(Competition competition) async {
    if (_competitionController == null) return;
    await _competitionController!.saveCompetition(competition);
    await loadCompetitions();
  }

  Future<void> deleteCompetition(Competition competition) async {
    if (_competitionController == null) return;

    // Borrar los partidos de la competición
    final matchController = createMatchController(competition);
    await matchController.loadMatches();
    final matches = matchController.matches;
    for (final match in matches) {
      await matchController.deleteMatch(match.id);
    }

    // Borrar competición
    await _competitionController!.deleteCompetition(competition.id);

    // Limpiar estado si se borra competición seleccionada
    if (_competition?.id == competition.id) {
      _competition = null;
    }

    await loadCompetitions();
  }

  void selectCompetition(Competition? competition) {
    _competition = competition;
    notifyListeners();
  }

  Future<Map<String, double>> getStatsFromSelectedCompetition() async {
    // Si no hay competición seleccionada, devolver estadísticas de temporada
    if (_competition == null) {
      return _season?.stats ?? {};
    }

    return _competition!.stats;
  }

  Future<void> loadObjectives() async {
    if (_objectiveController == null) return;
    objectives = await _objectiveController!.loadAllObjectives();
    notifyListeners();
  }

  Future<void> saveObjective(Objective objective) async {
    if (_objectiveController == null) return;
    await _objectiveController!.saveObjective(objective);
    await loadObjectives();
  }

  Future<void> deleteObjective(String objectiveId) async {
    if (_objectiveController == null) return;
    await _objectiveController!.deleteObjective(objectiveId);
    await loadObjectives();
  }

  Future<void> saveMatch(Match match, Competition competition) async {
    if (player == null || currentSeason == null) return;
    final matchController = createMatchController(competition);
    await matchController.saveMatch(match);
    await loadCompetitions();
  }

  Future<void> deleteMatch(String matchId, Competition competition) async {
    if (player == null || currentSeason == null) return;
    final matchController = createMatchController(competition);
    await matchController.deleteMatch(matchId);
    await loadCompetitions();
  }
}
