// services/firestore_paths.dart

class FirestorePaths {
  // Jugadores
  static String playerCollectionPath() => 'players';
  static String playerPath(String playerId) => '${playerCollectionPath()}/$playerId';

  // Temporadas
  static String seasonCollectionPath(String playerId) => '${playerPath(playerId)}/seasons';
  static String seasonPath(String playerId, String seasonId) =>
      '${seasonCollectionPath(playerId)}/$seasonId';

  // Competiciones
  static String competitionCollectionPath(String playerId, String seasonId) =>
      '${seasonPath(playerId, seasonId)}/competitions';
  static String competitionPath(String playerId, String seasonId, String competitionId) =>
      '${competitionCollectionPath(playerId, seasonId)}/$competitionId';

  // Objetivos
  static String objectiveCollectionPath(String playerId, String seasonId) =>
      '${seasonPath(playerId, seasonId)}/objectives';

  // Partidos
  static String matchCollectionPath(String playerId, String seasonId, String competitionId) =>
      '${competitionPath(playerId, seasonId, competitionId)}/matches';
}
