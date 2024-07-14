import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

class StorageService {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  StorageService();

  Future<void> deleteUserPfp(String pfpURL) async {
    try {
      Reference photoRef = _firebaseStorage.refFromURL(pfpURL);
      await photoRef.delete();
    } catch (e) {
      if (kDebugMode) print("Error deleting profile picture: $e");
    }
  }

  Future<String?> uploadUserPfp({
    required File file,
    required String uid,
  }) async {
    Reference fileRef = _firebaseStorage
        .ref('users/pfps')
        .child('$uid${p.extension(file.path)}');
    UploadTask task = fileRef.putFile(file);
    return task.then((p) {
      if (p.state == TaskState.success) {
        return fileRef.getDownloadURL();
      }
      return null;
    });
  }

  Future<String?> uploadImageToChat(
      {required File file, required String chatID}) async {
    Reference fileRef = _firebaseStorage
        .ref('chat/$chatID')
        .child('${DateTime.now().toIso8601String()}${p.extension(file.path)}');
    UploadTask task = fileRef.putFile(file);
    return task.then((p) {
      if (p.state == TaskState.success) {
        return fileRef.getDownloadURL();
      }
      return null;
    });
  }

  Future<String?> uploadStory({
    required File file,
    required String uid,
  }) async {
    try {
      Reference fileRef = _firebaseStorage
          .ref('users/videos')
          .child('$uid${p.extension(file.path)}');
      UploadTask task = fileRef.putFile(file);
      return await task.then((p) async {
        if (p.state == TaskState.success) {
          return await fileRef.getDownloadURL();
        }
        return null;
      });
    } catch (e) {
      if (kDebugMode) print("Error uploading video: $e");
      return null;
    }
  }
}
