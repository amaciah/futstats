// match_controller.dart

import 'package:flutter/material.dart';

import 'package:futstats/controllers/competition_controller.dart';
import 'package:futstats/controllers/season_controller.dart';
import 'package:futstats/models/competition.dart';
import 'package:futstats/models/match.dart';
import 'package:futstats/models/season.dart';
import 'package:futstats/models/statistics.dart';
import 'package:futstats/services/repositories/match_repository.dart';

class MatchController extends ChangeNotifier {
  MatchController({
    required this.matchRepoFactory,
    required this.seasonController,
    required this.competitionController,
    required this.season,
    required this.competition,
  });

  final MatchRepository Function(String competitionId) matchRepoFactory;

  final SeasonController seasonController;
  final CompetitionController competitionController;
  Season season;
  Competition competition;

  // Cache en memoria
  List<Match> _matches = [];
  bool _loaded = false;

  List<Match> get matches => _matches;
  bool get isLoaded => _loaded;

  Future<void> loadMatches() async {
    _matches = await matchRepoFactory(competition.id).getAll();
    _loaded = true;
    notifyListeners();
  }

  Future<void> saveMatch(Match match) async {
    final matchRepo = matchRepoFactory(competition.id);
    await matchRepo.set(match);
    
    // Actualizar cache
    final index = _matches.indexWhere((m) => m.id == match.id);
    if (index >= 0) {
      _matches[index] = match;
    } else {
      _matches.add(match);
    }
    _matches.sort((m1, m2) => m1.compareTo(m2));

    // Recalcular estadísticas
    await _recalculateSeasonStats();
    await _recalculateCompetitionStats();

    notifyListeners();
  }

  Future<void> deleteMatch(String matchId) async {
    final matchRepo = matchRepoFactory(competition.id);
    await matchRepo.delete(matchId);
    
    // Actualizar cache
    _matches.removeWhere((m) => m.id == matchId);

    // Recalcular estadísticas
    await _recalculateSeasonStats();
    await _recalculateCompetitionStats();

    notifyListeners();
  }

  Map<String, double> _aggregateMatchStats(List<Match> matchList) {
    Map<String, double> stats = {};
    add(String id, double increment) {
      stats.update(id, (value) => value + increment,
          ifAbsent: () => increment);
    }

    for (var match in matchList) {
      // Actualizar estadísticas de participación
      add('goals_for', match.goalsFor.toDouble());
      add('goals_against', match.goalsAgainst.toDouble());
      add('clean_sheets', match.goalsAgainst == 0 ? 1 : 0);
      add('points', match.result.points.toDouble());
      switch (match.result) {
        case MatchResult.win:
          add('wins', 1);
          break;
        case MatchResult.draw:
          add('draws', 1);
          break;
        case MatchResult.loss:
          add('defeats', 1);
          break;
      }

      // Actualizar estadísticas manuales
      for (final statId in StatTemplates.manualStatIds) {
        add(statId, match.stats[statId] ?? 0);
      }
    }

    // Contar partidos jugados
    stats['games_played'] = matchList.length.toDouble();

    return stats;
  }


  Future<void> _recalculateCompetitionStats() async {
    // Obtener partidos de la competición
    final matchRepo = matchRepoFactory(competition.id);
    final competitionMatches = await matchRepo.getAll();

    // Calcular estadísticas agregadas
    final competitionStats = _aggregateMatchStats(competitionMatches);
    StatFormulas.calculateAggregateStats(competitionStats);

    // Actualizar competición
    competition = competition.copyWith(
      stats: competitionStats
    );
    await competitionController.saveCompetition(competition);
  }

  Future<void> _recalculateSeasonStats() async {
    // Obtener todas las competiciones de la temporada
    final competitions = await competitionController.loadAllCompetitions();

    // Obtener todos los partidos de la temporada
    List<Match> allMatches = [];
    for (final competition in competitions) {
      // Excluir amistosos
      if (competition.type.isFriendly) continue;
      final matchRepo = matchRepoFactory(competition.id);
      final competitionMatches = await matchRepo.getAll();
      allMatches.addAll(competitionMatches);
    }

    // Calcular estadísticas agregadas
    final seasonStats = _aggregateMatchStats(allMatches);
    StatFormulas.calculateAggregateStats(seasonStats);

    // Actualizar temporada
    season = Season(
      id: season.id,
      startDate: season.startDate,
      endDate: season.endDate,
      stats: seasonStats,
    );
    await seasonController.saveSeason(season);
  }
}
