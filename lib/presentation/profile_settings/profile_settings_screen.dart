import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Uint8List
import 'package:sizer/sizer.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../core/app_export.dart';
import '../../core/models/user_model.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  // Controllers
  late TextEditingController _userNameController;
  late TextEditingController _emailController;
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();

  UserModel? _userModel;
  User? _firebaseUser;
  bool _isLoading = false;

  // Image picking
  File? _imageFile;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController();
    _emailController = TextEditingController();

    // ⬇️ --- 修正: 画面描画完了後にデータロードを実行 --- ⬇️
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
    // ⬆️ --------------------------------------------- ⬆️
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    final authService = ref.read(firebaseAuthServiceProvider);
    _firebaseUser = authService.currentUser;

    if (_firebaseUser == null) {
      // 描画完了後なので安全に pop できる
      Navigator.pop(context);
      return;
    }

    final firestoreService = ref.read(firestoreServiceProvider);
    try {
      // 1. ユーザー情報の取得を試みる
      final userDoc = await firestoreService.getUser(_firebaseUser!.uid);

      if (mounted) {
        setState(() {
          _userModel = userDoc;

          if (userDoc != null) {
            // Firestoreにデータがある場合
            _userNameController.text = userDoc.userName;
            _emailController.text = userDoc.email;
          } else {
            // Firestoreにデータがない場合 (Auth情報から補完)
            _userNameController.text = _firebaseUser!.displayName ??
                _firebaseUser!.email?.split('@').first ??
                '';
            _emailController.text = _firebaseUser!.email ?? '';
          }
        });
      }
    } catch (e) {
      // エラーが出ても画面は閉じず、ログだけ出す
      if (mounted) {
        print("ProfileSettings: データ読み込みエラー (正常な場合もあり) $e");

        // 最低限 Auth情報で埋める
        setState(() {
          _userNameController.text = _firebaseUser!.displayName ??
              _firebaseUser!.email?.split('@').first ??
              '';
          _emailController.text = _firebaseUser!.email ?? '';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- 画像選択 ---
  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageFile = File(pickedFile.path);
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      _showErrorSnackBar('画像の選択に失敗しました');
    }
  }

  // --- 再認証ダイアログ ---
  Future<String?> _showReauthDialog() async {
    String? password;
    await showDialog(
      context: context,
      builder: (context) {
        final passCtrl = TextEditingController();
        return AlertDialog(
          title: const Text('再認証'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('セキュリティのため、現在のパスワードを入力してください。'),
              SizedBox(height: 2.h),
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '現在のパスワード',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('キャンセル')),
            ElevatedButton(
              onPressed: () {
                password = passCtrl.text;
                Navigator.pop(context);
              },
              child: const Text('確認'),
            ),
          ],
        );
      },
    );
    return password;
  }

  // --- 1. 基本プロフィール更新 (画像・ユーザー名) ---
  Future<void> _updateBasicProfile() async {
    if (_firebaseUser == null) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final storageService = ref.read(firebaseStorageServiceProvider);
      final firestoreService = ref.read(firestoreServiceProvider);

      String? newImageUrl = _userModel?.profileImageUrl;

      // 画像アップロード
      if (kIsWeb && _imageBytes != null) {
        final path =
            storageService.generateImagePath(_firebaseUser!.uid, 'profile');
        newImageUrl =
            await storageService.uploadImage(bytes: _imageBytes!, path: path);
      } else if (!kIsWeb && _imageFile != null) {
        final path =
            storageService.generateImagePath(_firebaseUser!.uid, 'profile');
        newImageUrl = await storageService.uploadImage(
            imageFile: _imageFile!, path: path);
      }

      // 更新データ
      final String newUserName = _userNameController.text.trim();
      final String email = _emailController.text.trim();

      if (_userModel != null) {
        // 更新
        final updatedUser = _userModel!.copyWith(
          userName: newUserName,
          profileImageUrl: newImageUrl,
          updatedAt: DateTime.now(),
        );
        await firestoreService.updateUser(updatedUser);
      } else {
        // 新規作成
        final role = UserModel.roleFromEmail(
            email.isNotEmpty ? email : (_firebaseUser!.email ?? ''));
        final accountType = UserModel.accountTypeFromRole(role);
        final newUser = UserModel(
          id: _firebaseUser!.uid,
          email: email.isNotEmpty ? email : (_firebaseUser!.email ?? ''),
          userName: newUserName,
          profileImageUrl: newImageUrl,
          role: role,
          accountType: accountType,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await firestoreService.createUser(newUser);
      }

      // AuthのDisplayName/PhotoURLも更新
      try {
        await _firebaseUser!.updateDisplayName(newUserName);
        if (newImageUrl != null) {
          await _firebaseUser!.updatePhotoURL(newImageUrl);
        }
      } catch (e) {
        print("Auth profile update failed: $e");
      }

      _showSuccessSnackBar('プロフィールを更新しました');

      // データを再ロード
      _loadUserData();
    } catch (e) {
      _showErrorSnackBar('更新に失敗しました: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- 2. メールアドレス変更 ---
  Future<void> _updateEmail() async {
    if (_firebaseUser == null) return;
    final newEmail = _emailController.text.trim();

    if (newEmail == _firebaseUser!.email) return;
    if (newEmail.isEmpty || !newEmail.contains('@')) {
      _showErrorSnackBar('有効なメールアドレスを入力してください');
      return;
    }

    final password = await _showReauthDialog();
    if (password == null || password.isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final credential = EmailAuthProvider.credential(
          email: _firebaseUser!.email!, password: password);
      await _firebaseUser!.reauthenticateWithCredential(credential);

      await _firebaseUser!.verifyBeforeUpdateEmail(newEmail);

      _showSuccessSnackBar('新しいメールアドレスに確認メールを送信しました。リンクをクリックして変更を完了してください。');
    } catch (e) {
      _showErrorSnackBar('メールアドレスの変更に失敗しました: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- 3. パスワード変更 ---
  Future<void> _updatePassword() async {
    if (_newPasswordController.text.isEmpty) {
      _showErrorSnackBar('新しいパスワードを入力してください');
      return;
    }
    if (_newPasswordController.text != _confirmNewPasswordController.text) {
      _showErrorSnackBar('パスワードが一致しません');
      return;
    }
    if (_newPasswordController.text.length < 6) {
      _showErrorSnackBar('パスワードは6文字以上で入力してください');
      return;
    }

    final currentPassword = _currentPasswordController.text;
    if (currentPassword.isEmpty) {
      _showErrorSnackBar('現在のパスワードを入力してください');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final credential = EmailAuthProvider.credential(
          email: _firebaseUser!.email!, password: currentPassword);
      await _firebaseUser!.reauthenticateWithCredential(credential);

      await _firebaseUser!.updatePassword(_newPasswordController.text);

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmNewPasswordController.clear();

      _showSuccessSnackBar('パスワードを変更しました');
    } catch (e) {
      _showErrorSnackBar('パスワードの変更に失敗しました: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- 4. アカウント削除 ---
  Future<void> _deleteAccount() async {
    final password = await _showReauthDialog();
    if (password == null || password.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final credential = EmailAuthProvider.credential(
          email: _firebaseUser!.email!, password: password);
      await _firebaseUser!.reauthenticateWithCredential(credential);

      await _firebaseUser!.delete();

      if (mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      }
    } catch (e) {
      _showErrorSnackBar('アカウントの削除に失敗しました: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール設定'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      backgroundColor: theme.colorScheme.surface,
      body: _isLoading && _userModel == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(6.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isLoading) const LinearProgressIndicator(),
                  SizedBox(height: 2.h),

                  // --- 1. プロフィール画像 ---
                  Center(
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 12.w,
                            backgroundColor:
                                theme.colorScheme.outline.withOpacity(0.3),
                            backgroundImage: _imageBytes != null
                                ? MemoryImage(_imageBytes!)
                                : (_imageFile != null
                                    ? FileImage(_imageFile!)
                                    : (_userModel?.profileImageUrl != null
                                        ? NetworkImage(
                                                _userModel!.profileImageUrl!)
                                            as ImageProvider
                                        : null)),
                            child: (_imageBytes == null &&
                                    _imageFile == null &&
                                    _userModel?.profileImageUrl == null)
                                ? Icon(Icons.person,
                                    size: 12.w, color: Colors.grey)
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4.h),

                  // --- 2. 基本情報設定 ---
                  Text('基本情報',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: 2.h),
                  TextFormField(
                    controller: _userNameController,
                    decoration: const InputDecoration(
                      labelText: 'ユーザー名',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateBasicProfile,
                      child: const Text('プロフィール情報を更新'),
                    ),
                  ),

                  Divider(height: 6.h),

                  // --- 3. メールアドレス設定 ---
                  Text('メールアドレス変更',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: 2.h),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: '新しいメールアドレス',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _updateEmail,
                      child: const Text('メールアドレスを変更'),
                    ),
                  ),

                  Divider(height: 6.h),

                  // --- 4. パスワード変更 ---
                  Text('パスワード変更',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: 2.h),
                  TextFormField(
                    controller: _currentPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: '現在のパスワード',
                      prefixIcon: Icon(Icons.lock_open),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: '新しいパスワード',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  TextFormField(
                    controller: _confirmNewPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: '新しいパスワード (確認)',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _updatePassword,
                      child: const Text('パスワードを変更'),
                    ),
                  ),

                  Divider(height: 6.h),

                  // --- 5. アカウント削除 ---
                  Text('危険な操作',
                      style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.error)),
                  SizedBox(height: 2.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.errorContainer,
                        foregroundColor: theme.colorScheme.onErrorContainer,
                      ),
                      onPressed: _isLoading
                          ? null
                          : () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('アカウント削除'),
                                  content: const Text(
                                      '本当にアカウントを削除しますか？この操作は取り消せません。'),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('キャンセル')),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _deleteAccount();
                                        },
                                        child: const Text('削除する',
                                            style:
                                                TextStyle(color: Colors.red))),
                                  ],
                                ),
                              );
                            },
                      child: const Text('アカウントを削除'),
                    ),
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
    );
  }
}
