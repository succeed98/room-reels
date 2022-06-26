import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:room_reels/src/core/models/chat_model.dart';

class ChatDataSource {
  ChatDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<ChatModel> get chatRef => chats.withConverter<ChatModel>(
        fromFirestore: (snapshot, _) => ChatModel.fromJson(snapshot.data()!),
        toFirestore: (chat, _) => chat.toJson(),
      );

  CollectionReference<Map<String, dynamic>> get chats =>
      _firestore.collection('chats');

  Stream<QuerySnapshot<Map<String, dynamic>>> get chatsStream =>
      chats.snapshots();

  Future<ChatModel> addChat(ChatModel chat) async {
    final id = chatRef.doc().id;
    chat = chat.copy(id: id);
    await chatRef.doc(chat.id).set(chat);

    return chat;
  }

  Future<void> deleteChat(String id) async {
    return await chatRef.doc(id).delete();
  }

  Future<ChatModel> getChat(String id) async {
    return await chatRef.doc(id).get().then((snapshot) => snapshot.data()!);
  }

  Future<ChatModel> getChatBySellerAndBuyer({
    required String seller,
    required String buyer,
  }) async {
    return await chatRef
        .where('seller', isEqualTo: seller)
        .where('buyer', isEqualTo: buyer)
        .get()
        .then((snapshot) => snapshot.docs.first.data());
  }

  Future<ChatModel> updateChat(ChatModel chat) async {
    await chatRef.doc(chat.id).update(chat.toJson());
    return chat;
  }
}
