import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtener referencia a una colección
  CollectionReference collection(String path) => _db.collection(path);

  // Crear o actualizar un documento
  Future<void> setDocument(String path, String id, Map<String, dynamic> data) =>
      _db.collection(path).doc(id).set(data, SetOptions(merge: true));

  // Leer un documento
  Future<DocumentSnapshot> getDocument(String path, String id) =>
      _db.collection(path).doc(id).get();

  // Eliminar un documento
  Future<void> deleteDocument(String path, String id) =>
      _db.collection(path).doc(id).delete();

  // Obtener una colección completa
  Future<QuerySnapshot> getCollection(String path) =>
      _db.collection(path).get();

  // Obtener documentos que cumplen una condición
  Future<QuerySnapshot> queryCollection(
          String path, String field, dynamic value) =>
      _db.collection(path).where(field, isEqualTo: value).get();
}
