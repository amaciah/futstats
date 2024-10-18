import 'package:futstats/models/match.dart';
import 'package:futstats/services/firestore_service.dart';

class MatchRepository {
  final FirestoreService _firestoreService = FirestoreService();

  // Crear o actualizar un partido
  Future<void> setMatch(String playerId, String seasonId, Match match) async =>
      await _firestoreService.setDocument(
          'players/$playerId/seasons/$seasonId/matches',
          match.id,
          match.toMap());

  // Obtener un partido de una temporada
  Future<Match?> getMatch(
      String playerId, String seasonId, String matchId) async {
    var doc = await _firestoreService.getDocument(
        'players/$playerId/seasons/$seasonId/matches', matchId);
    if (doc.exists) {
      return Match.fromMap(doc.data() as Map<String, dynamic>);
    } else {
      return null;
    }
  }

  // Eliminar un partido
  Future<void> deleteMatch(
          String playerId, String seasonId, String matchId) async =>
      await _firestoreService.deleteDocument(
          'players/$playerId/seasons/$seasonId/matches', matchId);

  // Obtener todos los partidos de una temporada
  Future<List<Match>> getAllMatches(String playerId, String seasonId) async {
    var querySnapshot = await _firestoreService
        .getCollection('players/$playerId/seasons/$seasonId/matches');
    return querySnapshot.docs
        .map((doc) => Match.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
