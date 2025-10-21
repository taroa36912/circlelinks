import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage({
    File? imageFile,
    Uint8List? bytes,
    required String path,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      
      if (kIsWeb && bytes != null) {
        final uploadTask = await ref.putData(bytes);
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        return downloadUrl;
      } else if (!kIsWeb && imageFile != null) {
        final uploadTask = await ref.putFile(imageFile);
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        return downloadUrl;
      } else {
        throw Exception('画像データが見つかりません');
      }

    } catch (e) {
      throw Exception('画像のアップロードに失敗しました: $e');
    }
  }

  Future<String> uploadDocument({
    File? documentFile,
    Uint8List? bytes,
    required String path,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      
      if (kIsWeb && bytes != null) {
        final uploadTask = await ref.putData(bytes);
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        return downloadUrl;
      } else if (!kIsWeb && documentFile != null) {
        final uploadTask = await ref.putFile(documentFile);
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        return downloadUrl;
      } else {
        throw Exception('ドキュメントデータが見つかりません');
      }

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
