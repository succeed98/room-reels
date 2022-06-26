import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datasources/storage_datasource.dart';

final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final firestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final firebaseStorageProvider = Provider<firebase_storage.FirebaseStorage>(
    (ref) => firebase_storage.FirebaseStorage.instance);

final storageProvider = Provider<StorageDataSourceImpl>(
    (ref) => StorageDataSourceImpl(ref.watch(firebaseStorageProvider)));
