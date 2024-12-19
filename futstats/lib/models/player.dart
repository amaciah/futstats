import 'package:futstats/main.dart';
import 'package:futstats/models/season.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

enum PlayerPosition {
  goalkeeper,
  defender,
  midfielder,
  attacker;

  // Getter para obtener la etiqueta
  String get label {
    switch (this) {
      case PlayerPosition.goalkeeper:
        return 'Portero';
      case PlayerPosition.defender:
        return 'Defensor';
      case PlayerPosition.midfielder:
        return 'Centrocampista';
      case PlayerPosition.attacker:
        return 'Atacante';
    }
  }
}

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

  String? _currentSeason;

  // Obtener las temporadas del jugador
  Future<List<Season>> get seasons async =>
      await MyApp.seasonRepo.getAllSeasons();

  // Obtener la temporada actual del jugador
  Future<Season?> get currentSeason async => _currentSeason == null
      ? null
      : await MyApp.seasonRepo.getSeason(_currentSeason!);

  Future<void> setCurrentSeason(String seasonId) async {
    _currentSeason = seasonId;
    await _savePlayer();
  }

  Future<void> _savePlayer() async => await MyApp.playerRepo.setPlayer(this);

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
