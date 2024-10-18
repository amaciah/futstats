import 'package:uuid/uuid.dart';
import 'match.dart';
import 'objective.dart';

var uuid = const Uuid();

class Season {
  Season({
    String? id,
    required this.year,
    this.matches = const [],
    this.seasonStats = const {},
    this.objectives = const [],
  }) : id = id ?? uuid.v4();

  final String id;
  final String year;
  final List<Match> matches;
  final Map<String, double> seasonStats;
  final List<Objective> objectives;

  // Serialización para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'year': year,
      'matches': matches.map((match) => match.toMap()).toList(),
      'seasonStats': seasonStats,
      'objectives': objectives.map((objective) => objective.toMap()).toList(),
    };
  }

  factory Season.fromMap(Map<String, dynamic> map) {
    return Season(
      id: map['id'],
      year: map['year'],
      matches: List<Match>.from(
          map['matches'].map((matchMap) => Match.fromMap(matchMap))),
      seasonStats: Map<String, double>.from(map['seasonStats']),
      objectives: List<Objective>.from(
          map['objectives'].map((objMap) => Objective.fromMap(objMap))),
    );
  }
}
