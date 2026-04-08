import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/table_session.dart';

class FirestoreSessionSyncService {
  FirestoreSessionSyncService(this._db);

  final FirebaseFirestore _db;

  Future<void> upsertSession({
    required Session session,
    required String placeName,
    String? placeLocation,
  }) async {
    await _db.collection('sessions').doc(session.sessionId).set({
      'sessionId': session.sessionId,
      'tableNumber': session.tableNumber,
      'placeId': session.placeId,
      'placeName': placeName,
      'placeLocation': placeLocation,
      'users': session.users,
      'isActive': session.isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> upsertTable({
    required TableModel table,
    required String placeName,
  }) async {
    await _db
        .collection('places')
        .doc(table.placeId)
        .collection('tables')
        .doc(table.tableNumber)
        .set({
          'tableNumber': table.tableNumber,
          'placeId': table.placeId,
          'placeName': placeName,
          'status': table.status,
          'sessionId': table.sessionId,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  Future<void> upsertOrderItem({
    required String sessionId,
    required Map<String, dynamic> orderItem,
  }) async {
    final key = (orderItem['name']?.toString() ?? 'item')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')
        .toLowerCase();
    await _db
        .collection('sessions')
        .doc(sessionId)
        .collection('orders')
        .doc(key)
        .set(orderItem, SetOptions(merge: true));
  }

  Stream<Session> watchSession(String sessionId) {
    return _db
        .collection('sessions')
        .doc(sessionId)
        .snapshots()
        .where((d) => d.exists)
        .map((doc) {
          final data = doc.data()!;
          return Session(
            sessionId: data['sessionId']?.toString() ?? doc.id,
            tableNumber: data['tableNumber']?.toString() ?? '',
            placeId: data['placeId']?.toString() ?? '',
            users: List<String>.from(data['users'] ?? const []),
            isActive: data['isActive'] == true,
          );
        });
  }

  Stream<List<Map<String, dynamic>>> watchOrders(String sessionId) {
    return _db
        .collection('sessions')
        .doc(sessionId)
        .collection('orders')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }
}
