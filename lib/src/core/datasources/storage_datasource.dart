import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;

abstract class StorageDataSource {
  Future<String> uploadFile({required String bucket, required String filePath});
  Future<String> downloadFile({required String fileURL});
}

class StorageDataSourceImpl implements StorageDataSource {
  StorageDataSourceImpl(this._firestoreStorage);

  final FirebaseStorage _firestoreStorage;

  @override
  Future<String> downloadFile({required String fileURL}) async {
    return await _firestoreStorage.ref(fileURL).getDownloadURL();
  }

  @override
  Future<String> uploadFile(
      {required String bucket, required String filePath}) async {
    File imageFile = File(filePath);

    final fileURL = '$bucket/${path.basename(filePath)}';

    await _firestoreStorage.ref().child(fileURL).putFile(imageFile);

    return await downloadFile(fileURL: fileURL);
  }
}
