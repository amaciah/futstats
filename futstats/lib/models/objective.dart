import 'package:futstats/main.dart';
import 'package:uuid/uuid.dart';

enum ObjectiveType { positive, negative }

var uuid = const Uuid();

class Objective {
  Objective({
    String? id,
    required this.statId,
    required this.target,
    this.isPositive = true,
  }) : id = id ?? uuid.v4();

  final String id;
  final String statId; // ID de la estadística asociada
  final double target;
  final bool isPositive;

  Future<double> get stat async => await MyApp.statsRepo.getStatistic(statId);
  Future<bool> get isTargetMet async {
    var value = await stat;
    return isPositive ? value >= target : value <= target;
  }

  // Serialización para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'statId': statId,
      'target': target,
      'isPositive': isPositive,
    };
  }

  factory Objective.fromMap(Map<String, dynamic> map) {
    return Objective(
      id: map['id'],
      statId: map['statId'],
      target: map['target'],
      isPositive: map['isPositive'],
    );
  }
}
