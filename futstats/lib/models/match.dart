import 'package:flutter/material.dart';
import 'package:futstats/models/statistics.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

enum MatchResult {
  win,
  draw,
  loss;

  // Getter para obtener los puntos
  int get points {
    switch (this) {
      case MatchResult.win:
        return 3;
      case MatchResult.draw:
        return 1;
      case MatchResult.loss:
        return 0;
    }
  }

  // Getter para obtener el color
  Color get color {
    switch (this) {
      case MatchResult.win:
        return Colors.green;
      case MatchResult.draw:
        return Colors.grey;
      case MatchResult.loss:
        return Colors.red;
    }
  }
}

class Match {
  Match({
    String? id,
    required this.matchweek,
    required this.date,
    required this.opponent,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.stats,
  }) : id = id ?? uuid.v4() {
    StatFormulas.calculateMatchStats(stats);
  }

  final String id;
  final int matchweek;
  final DateTime date;
  final String opponent;
  final int goalsFor;
  final int goalsAgainst;
  final Map<String, double> stats;

  MatchResult get result {
    switch (goalsFor - goalsAgainst) {
      case > 0:
        return MatchResult.win;
      case < 0:
        return MatchResult.loss;
      default:
        return MatchResult.draw;
    }
  }

  // Serialización para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'matchweek': matchweek,
      'date': date.toIso8601String(),
      'opponent': opponent,
      'goalsFor': goalsFor,
      'goalsAgainst': goalsAgainst,
      'stats': stats,
    };
  }

  factory Match.fromMap(Map<String, dynamic> map) {
    return Match(
      id: map['id'],
      matchweek: map['matchweek'],
      date: DateTime.parse(map['date']),
      opponent: map['opponent'],
      goalsFor: map['goalsFor'],
      goalsAgainst: map['goalsAgainst'],
      stats: Map<String, double>.from(map['stats']),
    );
  }
}
