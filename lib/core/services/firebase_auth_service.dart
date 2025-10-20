import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// 1. kIsWebをインポートするために foundation を追加
import 'package:flutter/foundation.dart' show kIsWeb;

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // 2. signInWithGoogleメソッドを kIsWeb で分岐
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // --- ✅ Webの場合 ---
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        return await _auth.signInWithPopup(googleProvider);
      } else {
        // --- 📱 モバイル (Android/iOS) の場合 ---
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          return null; // ユーザーがキャンセルした場合
        }

        // Google認証情報を取得
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Firebase認証情報を作成
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Firebaseにサインイン
        return await _auth.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      // Firebase関連のエラーをキャッチ
      throw _handleAuthException(e);
    } catch (e) {
      // その他のエラー（ポップアップが閉じられた等）
      throw 'Googleログインに失敗しました: ${e.toString()}';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    // GoogleSignInのサインアウトは、Webでは不要な場合もあるが、モバイルでは必須
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      // ... (既存の case ... )
      case 'user-not-found':
        return 'このメールアドレスに対応するユーザーが見つかりません。';
      case 'wrong-password':
        return 'パスワードが正しくありません。';
      case 'email-already-in-use':
        return 'このメールアドレスは既に使用されています。';
      // ... (中略) ...

      // Web (signInWithPopup) 固有のエラーを追加
      case 'auth/popup-closed-by-user':
        return 'ログインウィンドウが閉じられました。';
      case 'auth/cancelled-popup-request':
        return 'ログインリクエストがキャンセルされました。';
        
      default:
        return '認証エラーが発生しました: ${e.message}';
    }
  }
}

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});