import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatRepository {
  ChatRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String get _uid {
    final u = _auth.currentUser;
    if (u == null) throw Exception('Not signed in.');
    return u.uid;
  }

  CollectionReference<Map<String, dynamic>> _chatsCol() =>
      _db.collection('users').doc(_uid).collection('chats');

  CollectionReference<Map<String, dynamic>> messagesCol(String chatId) =>
      _chatsCol().doc(chatId).collection('messages');

  Stream<QuerySnapshot<Map<String, dynamic>>> chatsStream() {
    return _chatsCol().orderBy('updatedAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> messagesStream(String chatId) {
    return messagesCol(chatId)
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  Future<String?> getMostRecentChatId() async {
    final snap = await _chatsCol()
        .orderBy('updatedAt', descending: true)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    return snap.docs.first.id;
  }

  Future<String> createNewChat() async {
    final now = FieldValue.serverTimestamp();

    // We'll store date string for easy UI title formatting.
    final createdAtLocal = DateTime.now();
    final dateStr = _formatDate(createdAtLocal); // YYYY-MM-DD

    final doc = await _chatsCol().add({
      'title': '$dateStr — New chat',
      'createdAt': now,
      'updatedAt': now,
      'lastMessage': '',
      'titleGenerated': false, // important for your new behavior
      'dateStr': dateStr,
    });

    // Greeting
    await messagesCol(doc.id).add({
      'text': 'Hello! How can I help you today?',
      'isUser': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  Future<void> addMessage({
    required String chatId,
    required String text,
    required bool isUser,
  }) async {
    await messagesCol(chatId).add({
      'text': text,
      'isUser': isUser,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _chatsCol().doc(chatId).update({
      'updatedAt': FieldValue.serverTimestamp(),
      'lastMessage': text.length > 120 ? text.substring(0, 120) : text,
    });
  }

  Future<void> setTitle({
    required String chatId,
    required String title,
    bool? titleGenerated,
  }) async {
    final payload = <String, dynamic>{
      'title': title,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (titleGenerated != null) {
      payload['titleGenerated'] = titleGenerated;
    }
    await _chatsCol().doc(chatId).update(payload);
  }

  Future<Map<String, dynamic>?> getChatMeta(String chatId) async {
    final snap = await _chatsCol().doc(chatId).get();
    return snap.data();
  }

  String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}