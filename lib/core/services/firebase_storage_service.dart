import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage({
    required File imageFile,
    required String path,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('画像のアップロードに失敗しました: $e');
    }
  }

  Future<String> uploadDocument({
    required File documentFile,
    required String path,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(documentFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('ドキュメントのアップロードに失敗しました: $e');
    }
  }

  Future<void> deleteFile(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.delete();
    } catch (e) {
      throw Exception('ファイルの削除に失敗しました: $e');
    }
  }

  String generateImagePath(String userId, String type) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'circles/$userId/${type}_$timestamp.jpg';
  }

  String generateDocumentPath(String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'circles/$userId/verification_document_$timestamp.pdf';
  }
}

final firebaseStorageServiceProvider = Provider<FirebaseStorageService>((ref) {
  return FirebaseStorageService();
});

