import 'package:futstats/main.dart';
import 'package:futstats/models/match.dart';
import 'package:futstats/services/firestore_service.dart';

class MatchRepository {
  MatchRepository({
    required String seasonId,
  }) : collectionPath = '${MyApp.seasonRepo.collectionPath}/$seasonId/matches';

  final FirestoreService _firestoreService = FirestoreService();
  final String collectionPath;

  // Crear o actualizar un partido
  Future<void> setMatch(Match match) async => await _firestoreService
      .setDocument(collectionPath, match.id, match.toMap());

  // Obtener un partido de una temporada
  Future<Match?> getMatch(String matchId) async {
    var doc = await _firestoreService.getDocument(collectionPath, matchId);
    if (doc.exists) {
      return Match.fromMap(doc.data() as Map<String, dynamic>);
    } else {
      return null;
    }
  }

  // Eliminar un partido
  Future<void> deleteMatch(String matchId) async =>
      await _firestoreService.deleteDocument(collectionPath, matchId);

  // Obtener todos los partidos de una temporada
  Future<List<Match>> getAllMatches() async {
    var querySnapshot = await _firestoreService.getCollection(collectionPath);
    return querySnapshot.docs
        .map((doc) => Match.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
