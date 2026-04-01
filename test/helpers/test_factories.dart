import 'package:futstats/models/competition.dart';
import 'package:futstats/models/match.dart';
import 'package:futstats/models/objective.dart';
import 'package:futstats/models/player.dart';
import 'package:futstats/models/season.dart';

class TestFactories {
  static Player player({
    String id = 'player-1',
    String name = 'Jugador Test',
    String? currentSeasonId,
  }) {
    final p = Player(
      id: id,
      name: name,
      birth: DateTime(1995, 6, 15),
      position: PlayerPosition.midfielder,
    );
    p.currentSeasonId = currentSeasonId;
    return p;
  }

  static Season season({
    String id = 'season-1',
    int startDate = 2024,
    int endDate = 2025,
    Map<String, double>? stats,
  }) =>
      Season(
        id: id,
        startDate: startDate,
        endDate: endDate,
        stats: stats ?? {},
      );

  static Competition competition({
    String id = 'comp-1',
    String name = 'Liga Test',
    CompetitionType type = CompetitionType.league,
    int numMatchweeks = 10,
    Map<String, double>? stats,
  }) =>
      Competition(
        id: id,
        name: name,
        type: type,
        numMatchweeks: numMatchweeks,
        stats: stats ?? {},
      );

  static Competition friendly({
    String id = 'comp-friendly',
    String name = 'Amistosos',
  }) =>
      Competition(
        id: id,
        name: name,
        type: CompetitionType.friendly,
      );

  static Objective objective({
    String id = 'obj-1',
    String statId = 'goals',
    double target = 10,
    bool isPositive = true,
  }) =>
      Objective(
        id: id,
        statId: statId,
        target: target,
        isPositive: isPositive,
      );

  static Match match({
    String id = 'match-1',
    int goalsFor = 2,
    int goalsAgainst = 1,
    int? matchweek = 1,
  }) =>
      Match(
        id: id,
        date: DateTime(2025, 1, 1),
        opponent: 'Rival FC',
        goalsFor: goalsFor,
        goalsAgainst: goalsAgainst,
        matchweek: matchweek,
        stats: {'goals': goalsFor.toDouble()},
      );
}
