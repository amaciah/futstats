import 'package:uuid/uuid.dart';

var uuid = const Uuid();

enum PlayerPosition { goalkeeper, defender, midfielder, attacker }

class Player {
  Player({
    String? id,
    required this.name,
    required this.position,
  }) : id = id ?? uuid.v4();

  final String id;
  final String name;
  final PlayerPosition position;

  // Serialización para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'position': position.name,
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'],
      name: map['name'],
      position: PlayerPosition.values.byName(map['position']),
    );
  }
}
