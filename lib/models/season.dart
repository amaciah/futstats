// season.dart

import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class Season {
  Season({
    String? id,
    required this.startDate,
    required this.endDate,
    Map<String, double>? stats,
  }) : id = id ?? uuid.v4(),
       stats = stats ?? {};

  final String id;
  final int startDate;
  final int endDate;
  final Map<String, double> stats;

  String get date =>
      startDate == endDate ? '$startDate' : '$startDate-$endDate';

  // Serialización para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start': startDate,
      'end': endDate,
      'stats': stats,
    };
  }

  factory Season.fromMap(Map<String, dynamic> map) {
    return Season(
      id: map['id'],
      startDate: map['start'],
      endDate: map['end'],
      stats: Map<String, double>.from(map['stats'] ?? {}),
    );
  }
}
