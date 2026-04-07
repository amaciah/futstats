// test/helpers/in_memory_migration_adapter.dart

import 'package:futstats/services/migration_service.dart';

/// Implementación en memoria de MigrationFirestoreAdapter.
/// Simula merge (SetOptions(merge: true)) igual que Firestore.
class InMemoryMigrationAdapter implements MigrationFirestoreAdapter {
  // path → docId → campos
  final Map<String, Map<String, Map<String, dynamic>>> _store = {};

  // ─── Siembra de datos ──────────────────────────────────────────────────────

  void seedDocument(String path, String id, Map<String, dynamic> data) {
    _store.putIfAbsent(path, () => {})[id] = Map<String, dynamic>.from(data);
  }

  // ─── Inspección para assertions ────────────────────────────────────────────

  bool documentExists(String path, String id) =>
      _store[path]?.containsKey(id) ?? false;

  bool collectionIsEmpty(String path) =>
      !(_store[path]?.isNotEmpty ?? false);

  int collectionSize(String path) => _store[path]?.length ?? 0;

  Map<String, dynamic>? getDocumentSync(String path, String id) {
    final doc = _store[path]?[id];
    return doc != null ? Map<String, dynamic>.from(doc) : null;
  }

  /// Devuelve todos los documentos de una colección con su id inyectado.
  List<Map<String, dynamic>> getCollectionSync(String path) =>
      _store[path]
          ?.entries
          .map((e) => <String, dynamic>{'id': e.key, ...e.value})
          .toList() ??
      [];

  // ─── MigrationFirestoreAdapter ─────────────────────────────────────────────

  @override
  Future<bool> collectionHasDocuments(String path) async =>
      _store[path]?.isNotEmpty ?? false;

  @override
  Future<List<MigrationDocument>> getCollection(String path) async =>
      _store[path]
          ?.entries
          .map((e) => MigrationDocument(
                id: e.key,
                data: Map<String, dynamic>.from(e.value),
              ))
          .toList() ??
      [];

  @override
  Future<Map<String, dynamic>?> getDocument(String path, String id) async {
    final doc = _store[path]?[id];
    return doc != null ? Map<String, dynamic>.from(doc) : null;
  }

  @override
  Future<void> setDocument(
      String path, String id, Map<String, dynamic> data) async {
    // Merge — igual que SetOptions(merge: true) en Firestore
    final existing = _store.putIfAbsent(path, () => {})[id] ?? {};
    _store[path]![id] = {...existing, ...data};
  }

  @override
  Future<void> deleteDocument(String path, String id) async {
    _store[path]?.remove(id);
  }
}
