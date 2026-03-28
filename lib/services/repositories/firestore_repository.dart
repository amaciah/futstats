// firestore_repository.dart

import 'package:futstats/services/firestore_service.dart';

abstract class FirestoreRepository<T> {
  final FirestoreService _firestoreService;
  final String collectionPath;

  FirestoreRepository(this.collectionPath) : _firestoreService = FirestoreService.instance;

  // Métodos abstractos para almacenar y recuperar modelos
  T fromMap(Map<String, dynamic> map);
  Map<String, dynamic> toMap(T model);
  String getDocumentId(T model);

  // Métodos para interactuar con Firestore
  Future<void> set(T model) async => 
      await _firestoreService.setDocument(collectionPath, getDocumentId(model), toMap(model));

  Future<T?> get(String id) async {
    var doc = await _firestoreService.getDocument(collectionPath, id);
    return doc.exists ? fromMap(doc.data() as Map<String, dynamic>) : null;
  }

  Future<void> delete(String id) async => 
      await _firestoreService.deleteDocument(collectionPath, id);

  Future<List<T>> getAll() async {
    var query = await _firestoreService.getCollection(collectionPath);
    return query.docs
       .map((doc) => fromMap(doc.data() as Map<String, dynamic>))
       .toList();
  }
}
