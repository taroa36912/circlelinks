import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_line_sdk/flutter_line_sdk.dart'; // LINE SDK
import 'package:cloud_functions/cloud_functions.dart'; // 👈 Cloud Functions (修正済み)
import 'package:flutter/services.dart'; // PlatformException

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isGoogleSigningIn = false; // 多重実行防止フラグ
  // 👇 FirebaseFunctionsの初期化 (修正済み)
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'asia-northeast1');

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

  Future<UserCredential?> signInWithGoogle() async {
    // 多重実行防止: 前回の処理が完了していない場合は即リターン
    if (_isGoogleSigningIn) return null;
    _isGoogleSigningIn = true;
    try {
      if (kIsWeb) {
        // --- ✅ Webの場合 ---
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        return await _auth.signInWithPopup(googleProvider);
      } else {
        // --- 📱 モバイル (Android/iOS) の場合 ---
        // 前回の未完了セッションが残っていると "Pending promise was never set" が発生するため
        // signIn前に一度サインアウトしてstale stateをクリアする
        await _googleSignIn.signOut();

        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          return null; // ユーザーがキャンセルした場合
        }
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        return await _auth.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Googleログインに失敗しました: ${e.toString()}';
    } finally {
      _isGoogleSigningIn = false; // 処理完了後に必ずフラグをリセット
    }
  }

  // --- signInWithLine メソッド ---
  Future<UserCredential?> signInWithLine() async {
    if (kIsWeb) {
      throw 'LINEログインは現在モバイルアプリのみサポートされています。';
    }

    try {
      // 1. LINEログインを実行し、IDトークンを取得
      final result =
          await LineSDK.instance.login(scopes: ["profile", "openid", "email"]);
      final idToken = result.accessToken.idToken;

      if (idToken == null) {
        throw 'LINE IDトークンが取得できませんでした。';
      }

      // 2. Cloud Functionsを呼び出してカスタムトークンを取得
      final callable = _functions.httpsCallable('verifyLineToken');
      final response =
          await callable.call<Map<String, dynamic>>({'idToken': idToken});
      final customToken = response.data['customToken'] as String?;

      if (customToken == null) {
        throw 'Firebaseカスタムトークンが取得できませんでした。Cloud Functionsのログを確認してください。';
      }

      // 3. カスタムトークンでFirebaseにサインイン
      UserCredential userCredential =
          await _auth.signInWithCustomToken(customToken);
      return userCredential;
    } on FirebaseFunctionsException catch (e) {
      // 👈 Functionsエラーを先にキャッチ (修正済み)
      print('Cloud Functions error: ${e.code} ${e.message}');
      throw 'Firebaseとの連携に失敗しました (${e.code})。しばらくしてから再試行してください。';
    } on PlatformException catch (e) {
      // 👈 次にPlatformException
      if (e.code == 'CANCEL') {
        print('ユーザーがLINEログインをキャンセルしました。');
        return null;
      } else if (e.code == 'AUTHENTICATION_AGENT_ERROR') {
        print('LINEアプリとの連携に問題が発生しました: ${e.message}');
        throw 'LINEアプリとの連携に問題が発生しました。LINEアプリが最新か確認してください。';
      } else {
        print('LINE SDK PlatformException: ${e.code} ${e.message}');
        throw 'LINEログイン中にエラーが発生しました (${e.code})';
      }
    } catch (e) {
      // 👈 最後にその他のエラー
      print('signInWithLine generic error: ${e.toString()}');
      throw 'LINEログインに失敗しました: ${e.toString()}';
    }
  }
  // --- End of signInWithLine method ---

  Future<void> signOut() async {
    await _auth.signOut();
    try {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
        await LineSDK.instance.logout();
      }
    } catch (e) {
      print("Sign out error (may be expected): $e");
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
      case 'user-not-found':
        return 'このメールアドレスに対応するユーザーが見つかりません。';
      case 'wrong-password':
        return 'パスワードが正しくありません。';
      case 'email-already-in-use':
        return 'このメールアドレスは既に使用されています。';
      case 'auth/popup-closed-by-user':
        return 'ログインウィンドウが閉じられました。';
      case 'auth/cancelled-popup-request':
        return 'ログインリクエストがキャンセルされました。';
      case 'invalid-custom-token':
        return '認証連携が無効です。';
      case 'custom-token-mismatch':
        return '認証情報が一致しません。';
      default:
        return '認証エラーが発生しました: ${e.message}';
    }
  }
}

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});
