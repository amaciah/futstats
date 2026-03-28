// competition.dart

import 'package:uuid/uuid.dart';

var uuid = Uuid();

enum CompetitionType {
  league,
  cup,
  tournament,
  friendly;

  String get label {
    switch (this) {
      case CompetitionType.league:
        return 'Liga';
      case CompetitionType.cup:
        return 'Copa';
      case CompetitionType.tournament:
        return 'Torneo';
      case CompetitionType.friendly:
        return 'Amistoso';
    }
  }
  
  bool get isLeague => this == CompetitionType.league;
  bool get isCup => this == CompetitionType.cup;
  bool get isTournament => this == CompetitionType.tournament;
  bool get isFriendly => this == CompetitionType.friendly;

}

class Competition {
  Competition({
    String? id,
    required this.name,
    required this.type,
    this.numMatchweeks,
    this.numRounds,
    this.hasGroups = false,
    this.hasKnockouts = false,
    Map<String, double>? stats,
  }) : id = id ?? uuid.v4(),
       stats = stats ?? {};

  final String id;
  final String name;
  final CompetitionType type;

  final int? numMatchweeks; // Solo liga
  final int? numRounds;     // Solo copa y torneo
  final bool hasGroups;     // Solo torneo
  final bool hasKnockouts;  // Solo torneo

  final Map<String, double> stats;

  bool get requiresMatchweek => type.isLeague;
  bool get requiresRound => type.isCup || type.isTournament;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'numMatchweeks': numMatchweeks,
      'rounds': numRounds,
      'hasGroups': hasGroups,
      'hasKnockouts': hasKnockouts,
      'stats': stats,
    };
  }

  factory Competition.fromMap(Map<String, dynamic> map) {
    return Competition(
      id: map['id'],
      name: map['name'],
      type: CompetitionType.values.byName(map['type']),
      numMatchweeks: map['numMatchweeks'],
      numRounds: map['rounds'],
      hasGroups: map['hasGroups'] ?? false,
      hasKnockouts: map['hasKnockouts'] ?? false,
      stats: Map<String, double>.from(map['stats'] ?? {}),
    );
  }

  Competition copyWith({required Map<String, double> stats}) {
    return Competition(
      id: id,
      name: name,
      type: type,
      numMatchweeks: numMatchweeks,
      numRounds: numRounds,
      hasGroups: hasGroups,
      hasKnockouts: hasKnockouts,
      stats: stats,
    );
  }
}
