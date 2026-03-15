import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// UI側のコードを変更しないよう、プロバイダー名は既存のまま維持します
final firebaseStorageServiceProvider = Provider<SupabaseStorageService>((ref) {
  return SupabaseStorageService();
});

class SupabaseStorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String bucketName = 'circlelinks'; // 作成したバケット名

  String generateImagePath(String userId, String type) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'circles/$userId/${type}_$timestamp.jpg';
  }

  String generateDocumentPath(String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'documents/$userId/doc_$timestamp.pdf';
  }

  Future<String> uploadImage({
    Uint8List? bytes,
    File? imageFile,
    required String path,
  }) async {
    try {
      if (bytes != null) {
        // Webからのアップロード (Uint8List)
        await _supabase.storage.from(bucketName).uploadBinary(
              path,
              bytes,
              fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
            );
      } else if (imageFile != null) {
        // モバイルからのアップロード (File)
        await _supabase.storage.from(bucketName).upload(
              path,
              imageFile,
              fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
            );
      } else {
        throw Exception('画像データがありません');
      }

      // アップロードした画像の公開URLを取得して返す
      return _supabase.storage.from(bucketName).getPublicUrl(path);
      
    } catch (e) {
      print('🔥 Supabase Upload Error: $e');
      throw Exception('画像のアップロードに失敗しました: $e');
    }
  }

  Future<String> uploadDocument({
    Uint8List? bytes,
    File? documentFile,
    required String path,
  }) async {
    try {
      if (bytes != null) {
        await _supabase.storage.from(bucketName).uploadBinary(
              path,
              bytes,
              fileOptions: const FileOptions(contentType: 'application/pdf', upsert: true),
            );
      } else if (documentFile != null) {
        await _supabase.storage.from(bucketName).upload(
              path,
              documentFile,
              fileOptions: const FileOptions(contentType: 'application/pdf', upsert: true),
            );
      } else {
        throw Exception('ドキュメントデータがありません');
      }

      return _supabase.storage.from(bucketName).getPublicUrl(path);
    } catch (e) {
      print('🔥 Supabase Upload Error: $e');
      throw Exception('ドキュメントのアップロードに失敗しました: $e');
    }
  }

  // 他のファイルとの互換性のために削除メソッドも追加
  Future<void> deleteFile(String path) async {
    try {
      await _supabase.storage.from(bucketName).remove([path]);
    } catch (e) {
      print('🔥 Supabase Delete Error: $e');
      throw Exception('ファイルの削除に失敗しました: $e');
    }
  }
}