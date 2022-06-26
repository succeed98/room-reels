import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

abstract class UserDataSource {
  /// Make call to Firebase 'users' collection for [UserModel]
  /// Throws [ServerException] if error occurs.
  Future<UserModel> getUser(String uid);
  Stream<UserModel> getUserStream(String uid);
  Future<UserModel> addUser(UserModel user);
  Future<UserModel> updateUser(UserModel user);
  Future<void> deleteUser(String uid);
}

class UserDataSourceImpl implements UserDataSource {
  UserDataSourceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<UserModel> get userRef => users.withConverter<UserModel>(
        fromFirestore: (snapshot, _) => UserModel.fromJson(snapshot.data()!),
        toFirestore: (user, _) => user.toJson(),
      );

  CollectionReference<Map<String, dynamic>> get users =>
      _firestore.collection('users');

  Stream<QuerySnapshot<Map<String, dynamic>>> get usersStream =>
      users.snapshots();

  @override
  Future<UserModel> addUser(UserModel user) async {
    await userRef.doc(user.uid).set(user);

    return user;
  }

  @override
  Future<void> deleteUser(String uid) async {
    return await userRef.doc(uid).delete();
  }

  @override
  Future<UserModel> getUser(String uid) async {
    return await userRef.doc(uid).get().then((snapshot) => snapshot.data()!);
  }

  @override
  Stream<UserModel> getUserStream(String uid) {
    return userRef
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs.first.data());
  }

  @override
  Future<UserModel> updateUser(UserModel user) async {
    await userRef.doc(user.uid).update(user.toJson());
    return user;
  }
}
