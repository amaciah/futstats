import 'package:futstats/main.dart';
import 'package:futstats/models/season.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

enum PlayerPosition { goalkeeper, defender, midfielder, attacker }

class Player {
  Player({
    String? id,
    required this.name,
    required this.birth,
    required this.position,
  }) : id = id ?? uuid.v4();

  final String id;
  final String name;
  final DateTime birth;
  final PlayerPosition position;

  late String _currentSeason;

  // Obtener las temporadas del jugador
  Future<List<Season>> get seasons async => MyApp.seasonRepo.getAllSeasons();

  // Obtener la temporada actual del jugador
  Future<Season?> get currentSeason async =>
      MyApp.seasonRepo.getSeason(_currentSeason);

  // Serialización para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'birth': birth.toIso8601String(),
      'position': position.name,
      'currentSeason': _currentSeason,
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'],
      name: map['name'],
      birth: DateTime.parse(map['birth']),
      position: PlayerPosition.values.byName(map['position']),
    ).._currentSeason = map['currentSeason'];
  }
}
