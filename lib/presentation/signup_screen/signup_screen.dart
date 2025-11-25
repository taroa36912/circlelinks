import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import '../../core/models/user_model.dart'; // UserModel

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController(); // 👈 追加
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _userNameController.dispose(); // 👈 追加
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final authService = ref.read(firebaseAuthServiceProvider);
      final firestoreService = ref.read(firestoreServiceProvider);

      // 1. Authでアカウント作成
      final credential = await authService.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (credential != null && credential.user != null) {
        // 2. Firestoreにユーザー情報 (UserModel) を作成
        final newUser = UserModel(
          id: credential.user!.uid,
          email: _emailController.text.trim(),
          userName: _userNameController.text.trim(), // 👈 入力された名前を使用
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await firestoreService.createUser(newUser);

        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.circleDiscovery);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('サインアップに失敗しました: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  // ... (バリデーションメソッドは変更なし) ...
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'メールアドレスを入力してください';
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
      return '有効なメールアドレスを入力してください';
    }
    return null;
  }
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'パスワードを入力してください';
    if (value.length < 6) return 'パスワードは6文字以上で入力してください';
    return null;
  }
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'パスワード（確認）を入力してください';
    if (value != _passwordController.text) return 'パスワードが一致しません';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('アカウント作成'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(6.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 2.h),
              Text('CircleLinkへようこそ', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600,),),
              SizedBox(height: 1.h),
              Text('まずは個人用アカウントを作成しましょう。', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant,),),
              SizedBox(height: 4.h),

              // ⬇️ ユーザー名入力フィールド (追加) ⬇️
              TextFormField(
                controller: _userNameController,
                decoration: const InputDecoration(
                  labelText: 'ユーザー名',
                  hintText: '例: 山田 太郎',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => value == null || value.isEmpty ? 'ユーザー名を入力してください' : null,
              ),
              SizedBox(height: 2.h),
              // ⬆️ ---------------------- ⬆️

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'メールアドレス', hintText: 'example@university.ac.jp', prefixIcon: Icon(Icons.email)),
                validator: _validateEmail,
              ),
              SizedBox(height: 2.h),
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'パスワード',
                  hintText: '6文字以上で入力',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                    onPressed: () { setState(() { _isPasswordVisible = !_isPasswordVisible; }); },
                  ),
                ),
                validator: _validatePassword,
              ),
              SizedBox(height: 2.h),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_isPasswordVisible,
                decoration: const InputDecoration(labelText: 'パスワード（確認）', prefixIcon: Icon(Icons.lock_outline)),
                validator: _validateConfirmPassword,
              ),
              SizedBox(height: 5.h),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSignUp,
                style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 2.h)),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('アカウントを作成'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}