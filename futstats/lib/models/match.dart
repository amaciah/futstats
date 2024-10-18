import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class Match {
  Match({
    String? id,
    required this.matchweek,
    required this.date,
    required this.opponent,
    required this.stats,
  }) : id = id ?? uuid.v4();

  final String id;
  final int matchweek;
  final DateTime date;
  final String opponent;
  final Map<String, double> stats;

  // Serialización para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'matchweek': matchweek,
      'date': date.toIso8601String(),
      'opponent': opponent,
      'stats': stats,
    };
  }

  factory Match.fromMap(Map<String, dynamic> map) {
    return Match(
      id: map['id'],
      matchweek: map['matchweek'],
      date: DateTime.parse(map['date']),
      opponent: map['opponent'],
      stats: Map<String, double>.from(map['stats']),
    );
  }
}
