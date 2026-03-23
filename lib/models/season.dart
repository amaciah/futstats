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

  Future<void> setMatch(Match match) async {
    // Guardar partido en Firestore
    await MyApp.matchRepo.setMatch(match);
    // Actualizar estadísticas acumuladas
    updateSeasonStats();
  }

  Future<void> deleteMatch(Match match) async {
    // Eliminar partido en Firestore
    await MyApp.matchRepo.deleteMatch(match.id);
    // Actualizar estadísticas acumuladas
    updateSeasonStats();
  }

  void updateSeasonStats() async {
    final matchList = await matches;
    Map<String, double> stats = {};
    update(String id, double increment) {
      stats.update(id, (value) => value += increment,
          ifAbsent: () => increment);
    }

    for (var match in matchList) {
      // Actualizar estadísticas de participación
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
    }

    // Contar partidos jugados
    stats['games_played'] = matchList.length.toDouble();

    // Calcular estadísticas automáticas
    StatFormulas.calculateSeasonStats(stats);

    // Actualizar estadísticas en Firestore
    await MyApp.statsRepo.setSeasonStatistics(stats);
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
