import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BodyCheckService {
  BodyCheckService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError("No logged-in user (FirebaseAuth.currentUser is null).");
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('users').doc(_uid).collection('body_checks');

  Map<String, int> _onlyNonZero(Map<String, int> input) {
    final out = <String, int>{};
    input.forEach((k, v) {
      if (v > 0) out[k] = v;
    });
    return out;
  }

  Map<String, dynamic> _statsFrom(
    Map<String, int> front,
    Map<String, int> back,
    Map<String, int> side,
  ) {
    int maxPain = 0;
    int low = 0, moderate = 0, high = 0;

    void scan(Map<String, int> m) {
      for (final v in m.values) {
        if (v > maxPain) maxPain = v;
        if (v == 1) low++;
        if (v == 2) moderate++;
        if (v == 3) high++;
      }
    }

    scan(front);
    scan(back);
    scan(side);

    return {
      'maxPain': maxPain,
      'countLow': low,
      'countModerate': moderate,
      'countHigh': high,
    };
  }

  Future<String> createEntry({
    required Map<String, int> frontPain,
    required Map<String, int> backPain,
    Map<String, int>? sidePain,
  }) async {
    final front = _onlyNonZero(frontPain);
    final back = _onlyNonZero(backPain);
    final side = _onlyNonZero(sidePain ?? {});

    if (front.isEmpty && back.isEmpty && side.isEmpty) {
      throw StateError("No pain data to save.");
    }

    final stats = _statsFrom(front, back, side);

    final doc = await _col.add({
      'createdAt': FieldValue.serverTimestamp(),
      'front': front,
      'back': back,
      'side': side,
      ...stats,
    });

    return doc.id;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamEntries() {
    return _col.orderBy('createdAt', descending: true).snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getEntry(String entryId) {
    return _col.doc(entryId).get();
  }
}