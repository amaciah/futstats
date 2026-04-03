// migration_service.dart

import 'package:flutter/material.dart';
import 'package:futstats/models/competition.dart';
import 'package:futstats/models/match.dart';
import 'package:futstats/models/statistics.dart';
import 'package:futstats/services/firestore_paths.dart';
import 'package:futstats/services/firestore_service.dart';

// Representa un documento leído de Firestore
class MigrationDocument {
  const MigrationDocument({required this.id, required this.data});
  final String id;
  final Map<String, dynamic> data;
}

// Abstracción interna que aísla MigrationService de los tipos nativos
// de Firestore, permitiendo tests sin Firebase
@visibleForTesting
abstract class MigrationFirestoreAdapter {
  Future<bool> collectionHasDocuments(String path);
  Future<List<MigrationDocument>> getCollection(String path);
  Future<Map<String, dynamic>?> getDocument(String path, String id);
  Future<void> setDocument(String path, String id, Map<String, dynamic> data);
  Future<void> deleteDocument(String path, String id);
}

class _RealFirestoreAdapter implements MigrationFirestoreAdapter {
  _RealFirestoreAdapter() : _firestoreService = FirestoreService.instance;
  final FirestoreService _firestoreService;

  @override
  Future<bool> collectionHasDocuments(String path) async {
    final snapshot = await _firestoreService.getCollection(path);
    return snapshot.docs.isNotEmpty;
  }

  @override
  Future<List<MigrationDocument>> getCollection(String path) async {
    final snapshot = await _firestoreService.getCollection(path);
    return snapshot.docs
        .map((doc) => MigrationDocument(
              id: doc.id, 
              data: doc.data() as Map<String, dynamic>,
            ))
        .toList();
  }

  @override
  Future<Map<String, dynamic>?> getDocument(String path, String id) async {
    final doc = await _firestoreService.getDocument(path, id);
    return doc.exists ? doc.data() as Map<String, dynamic>? : null;
  }

  @override
  Future<void> setDocument(String path, String id, Map<String, dynamic> data) =>
      _firestoreService.setDocument(path, id, data);

  @override
  Future<void> deleteDocument(String path, String id) =>
      _firestoreService.deleteDocument(path, id);
}

class MigrationService {
  MigrationService({MigrationFirestoreAdapter? adapter})
      : _adapter = adapter ?? _RealFirestoreAdapter();

  final MigrationFirestoreAdapter _adapter;

  String _legacyMatchPath(String playerId, String seasonId) => 
      'players/$playerId/seasons/$seasonId/matches';
  String _legacyStatsPath(String playerId, String seasonId) => 
      'players/$playerId/seasons/$seasonId/statistics';


  // Detecta y ejecuta migraciones necesarias
  Future<void> migrateIfNeeded(String playerId) async {
    final seasons = await _adapter.getCollection(
        FirestorePaths.seasonCollectionPath(playerId));
    for (final season in seasons) {
      await _migrateSeasonIfNeeded(playerId, season.id);
    }
  }

  Future<void> _migrateSeasonIfNeeded(String playerId, String seasonId) async {

    // Comprobar si hay datos en rutas antiguas
    final legacyMatchPath = _legacyMatchPath(playerId, seasonId);
    final hasMatches = await _adapter.collectionHasDocuments(legacyMatchPath);
    
    final legacyStatsPath = _legacyStatsPath(playerId, seasonId);
    final hasStats = await _adapter.collectionHasDocuments(legacyStatsPath);

    if (!hasMatches && !hasStats) return; // Ya en v0.2 o sin datos

    if (hasMatches) {
      // Leer número de jornadas de la temporada en versión antigua
      final seasonsPath = FirestorePaths.seasonCollectionPath(playerId);
      final legacySeasonData = await _adapter.getDocument(seasonsPath, seasonId);
      final numMatchweeks = legacySeasonData?['matchweeks'] as int?;

      // Crear competición de liga para guardar los partidos huérfanos
      final legacyCompetition = Competition(
        name: 'Liga',
        type: CompetitionType.league,
        numMatchweeks: numMatchweeks,
      );
      final competitionsPath = FirestorePaths.competitionCollectionPath(
          playerId, seasonId);
      await _adapter.setDocument(
        competitionsPath, 
        legacyCompetition.id, 
        legacyCompetition.toMap(),
      );

      // Migrar partidos
      await _migrateMatches(playerId, seasonId, legacyCompetition.id);

      // Calcular estadísticas a partir de los partidos migrados
      await _recalculateStatsFromMatches(playerId, seasonId, legacyCompetition.id);
    }

    // Borrar estadísticas huérfanas
    if (hasStats) {
      await _deleteLegacyStats(playerId, seasonId);
    }
  }

  Future<void> _migrateMatches(
      String playerId, String seasonId, String competitionId) async {
    final legacyPath = _legacyMatchPath(playerId, seasonId);
    final newPath = FirestorePaths.matchCollectionPath(
        playerId, seasonId, competitionId);

    final docs = await _adapter.getCollection(legacyPath);
    for (final doc in docs) {
      // Escribir en nueva ruta
      await _adapter.setDocument(newPath, doc.id, doc.data);
      // Borrar de ruta antigua
      await _adapter.deleteDocument(legacyPath, doc.id);
    }
  }

  Future<void> _recalculateStatsFromMatches(
      String playerId, String seasonId, String competitionId) async {

    // Obtener partidos migrados
    final matchesPath = FirestorePaths.matchCollectionPath(
        playerId, seasonId, competitionId);
    final docs = await _adapter.getCollection(matchesPath);
    if (docs.isEmpty) return;
    final matches = docs.map((doc) => Match.fromMap(doc.data)).toList();

    // Calcular estadísticas agregadas
    final stats = StatFormulas.aggregateMatchStats(matches);
    StatFormulas.calculateAggregateStats(stats);

    // Guardar estadísticas en competición
    final competitionsPath = FirestorePaths.competitionCollectionPath(
        playerId, seasonId);
    await _adapter.setDocument(
      competitionsPath, 
      competitionId, 
      {'stats': stats},
    );

    // Guardar estadísticas en temporada
    final seasonsPath = FirestorePaths.seasonCollectionPath(playerId);
    await _adapter.setDocument(
      seasonsPath, 
      seasonId, 
      {'stats': stats},
    );
  }

  Future<void> _deleteLegacyStats(String playerId, String seasonId) async {
    final legacyPath = _legacyStatsPath(playerId, seasonId);
    final docs = await _adapter.getCollection(legacyPath);
    for (final doc in docs) {
      await _adapter.deleteDocument(legacyPath, doc.id);
    }
  }
}
