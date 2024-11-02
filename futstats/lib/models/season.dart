import 'package:futstats/main.dart';
import 'package:futstats/models/match.dart';
import 'package:futstats/models/objective.dart';
import 'package:futstats/models/statistics.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class Season {
  Season({
    String? id,
    required this.startDate,
    required this.endDate,
    required this.numMatchweeks,
  }) : id = id ?? uuid.v4();

  final String id;
  final int startDate;
  final int endDate;
  final int numMatchweeks; // Número de jornadas en la temporada

  String get date =>
      startDate == endDate ? '$startDate' : '$startDate-$endDate';

  // Obtener los partidos de la temporada
  Future<List<Match>> get matches async =>
      await MyApp.matchRepo.getAllMatches();

  // Obtener las estadísticas acumuladas de la temporada
  Future<Map<String, double>> get statistics async =>
      await MyApp.statsRepo.getSeasonStatistics();

  // Obtener los objetivos de la temporada
  Future<List<Objective>> get objectives async =>
      await MyApp.objRepo.getAllObjectives();

  Future<void> addMatch(Match match) async {
    // Guardar partido en Firestore
    await MyApp.matchRepo.setMatch(match);
    // Actualizar estadísticas acumuladas
    updateSeasonStats(match);
  }

  Future<void> deleteMatch(Match match) async {
    // Actualizar estadísticas acumuladas
    updateSeasonStats(match, isMatchRemoved: true);
    // Eliminar partido en Firestore
    await MyApp.matchRepo.deleteMatch(match.id);
  }

  Future<void> updateMatch({
    required Match oldMatch,
    required Match newMatch,
  }) async {
    // Actualizar estadísticas acumuladas
    updateSeasonStats(oldMatch, isMatchRemoved: true);
    updateSeasonStats(newMatch);
    // Actualizar partido en Firestore
    await MyApp.matchRepo.setMatch(newMatch);
  }

  void updateSeasonStats(Match match, {bool isMatchRemoved = false}) async {
    final Function(String, double) update = isMatchRemoved
        ? MyApp.statsRepo.decrementStatistic
        : MyApp.statsRepo.incrementStatistic;

    // Actualizar estadísticas de participación
    update('games_played', 1);
    update('goals_for', match.goalsFor.toDouble());
    update('goals_against', match.goalsAgainst.toDouble());
    update('clean_sheets', match.goalsAgainst == 0 ? 1 : 0);
    update('points', match.result.points.toDouble());
    switch (match.result) {
      case MatchResult.win:
        update('wins', 1);
        break;
      case MatchResult.draw:
        update('draws', 1);
        break;
      case MatchResult.loss:
        update('defeats', 1);
        break;
    }

    // Actualizar estadísticas manuales
    for (var statId in StatTemplates.manualStatIds) {
      update(statId, match.stats[statId] ?? 0);
    }

    // Calcular estadísticas automáticas
    StatFormulas.calculateSeasonStats(await statistics);
  }

  // Serialización para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start': startDate,
      'end': endDate,
      'matchweeks': numMatchweeks,
    };
  }

  factory Season.fromMap(Map<String, dynamic> map) {
    return Season(
      id: map['id'],
      startDate: map['start'],
      endDate: map['end'],
      numMatchweeks: map['matchweeks'],
    );
  }
}
