import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

// 必要なRiverpodやFirebaseAuthServiceのインポートを確認
import '../../core/app_export.dart'; 
import './widgets/biometric_prompt_widget.dart';
import './widgets/login_form_widget.dart';
import './widgets/social_login_widget.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  final bool _showBiometricPrompt = false; // Note: This seems unused currently
  late AnimationController _logoAnimationController;
  late AnimationController _formAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<Offset> _formSlideAnimation;
  late Animation<double> _formOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _formAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0,)
        .animate(CurvedAnimation(parent: _logoAnimationController, curve: Curves.elasticOut,));
    _formSlideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero,)
        .animate(CurvedAnimation(parent: _formAnimationController, curve: Curves.easeOutCubic,));
    _formOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0,)
        .animate(CurvedAnimation(parent: _formAnimationController, curve: Curves.easeInOut,));
  }

  void _startAnimations() {
    _logoAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _formAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _formAnimationController.dispose();
    super.dispose();
  }

  // --- Email/Password Login Handler ---
  Future<void> _handleLogin(String email, String password) async {
    // ⬇️ フォーカスを外す処理を追加 (IMEエラー対策) ⬇️
    FocusScope.of(context).unfocus(); 

    setState(() { _isLoading = true; });

    try {
      final authService = ref.read(firebaseAuthServiceProvider);
      await authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      HapticFeedback.lightImpact();
      if (mounted) {
        // ログイン成功後にスピナーを消す (任意だが安全)
        setState(() { _isLoading = false; });
        Navigator.pushReplacementNamed(context, '/circle-discovery');
      }
    } catch (e) {
      setState(() { _isLoading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ログインに失敗しました: $e'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            // ... (SnackBarAction) ...
          ),
        );
      }
    } finally {
      // 念のため、成功時・失敗時どちらでも isLoading を false にする
      if (mounted && _isLoading) {
        setState(() { _isLoading = false; });
      }
    }
  }

  // --- Google Login Handler ---
  Future<void> _handleGoogleLogin() async {
    // ⬇️ フォーカスを外す処理を追加 (IMEエラー対策) ⬇️
    FocusScope.of(context).unfocus(); 

    setState(() { _isLoading = true; });

    try {
      final authService = ref.read(firebaseAuthServiceProvider);
      final userCredential = await authService.signInWithGoogle();

      if (userCredential != null) {
        HapticFeedback.lightImpact();
        if (mounted) {
           // ログイン成功後にスピナーを消す
           setState(() { _isLoading = false; });
           Navigator.pushReplacementNamed(context, '/circle-discovery');
        }
      } else {
        // User cancelled sign-in
        setState(() { _isLoading = false; });
      }
    } catch (e) {
      setState(() { _isLoading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Googleログインに失敗しました: $e'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
             // ... (SnackBarAction) ...
          ),
        );
      }
    } finally {
       if (mounted && _isLoading) {
         setState(() { _isLoading = false; });
       }
    }
  }

  // --- ⬇️ LINE Login Handler (新規追加) ⬇️ ---
  Future<void> _handleLineLogin() async {
    // フォーカスを外す処理を追加 (IMEエラー対策)
    FocusScope.of(context).unfocus(); 

    setState(() { _isLoading = true; });
    
    try {
      final authService = ref.read(firebaseAuthServiceProvider);
      // FirebaseAuthService の signInWithLine を呼び出す
      final userCredential = await authService.signInWithLine(); 

      if (userCredential != null) {
        // ログイン成功
        HapticFeedback.lightImpact(); 
        if (mounted) {
          // ログイン成功後にスピナーを消す
          setState(() { _isLoading = false; });
          Navigator.pushReplacementNamed(context, '/circle-discovery');
        }
      } else {
        // ユーザーがキャンセルした場合 (signInWithLineがnullを返す想定)
        setState(() { _isLoading = false; });
      }
    } catch (e) {
      // エラー発生時
      setState(() { _isLoading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('LINEログインに失敗しました: $e'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
             action: SnackBarAction( // 必要に応じて閉じるアクションを追加
               label: '閉じる',
               textColor: Colors.white,
               onPressed: () {
                 ScaffoldMessenger.of(context).hideCurrentSnackBar();
               },
             ),
          ),
        );
      }
    } finally {
       // 念のため、成功時・失敗時どちらでも isLoading を false にする
       if (mounted && _isLoading) {
         setState(() { _isLoading = false; });
       }
    }
  }
  // --- ⬆️ End of LINE Login Handler ⬆️ ---

  // --- Biometric Handlers (現状未使用の可能性) ---
  void _handleBiometricSuccess() {
    HapticFeedback.heavyImpact();
    Navigator.pushReplacementNamed(context, '/circle-discovery');
  }

  void _skipBiometric() {
    Navigator.pushReplacementNamed(context, '/circle-discovery');
  }

  // --- Navigation ---
  void _navigateToSignUp() {
    Navigator.pushNamed(context, '/circle-registration');
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // Main Login Content
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 8.h),
                      // ... (CircleLink Logo Animation) ...
                       AnimatedBuilder(
                        animation: _logoAnimationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoScaleAnimation.value,
                            child: Column(
                              children: [
                                // ... (Logo Container, Text, etc.) ...
                                Container( /* ... Logo ... */ ),
                                SizedBox(height: 2.h),
                                Text( 'CircleLink', /* ... style ... */ ),
                                SizedBox(height: 1.h),
                                Text( '大学サークル管理アプリ', /* ... style ... */ ),
                              ],
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 6.h),

                      // Login Form
                      AnimatedBuilder(
                        animation: _formAnimationController,
                        builder: (context, child) {
                          return SlideTransition(
                            position: _formSlideAnimation,
                            child: FadeTransition(
                              opacity: _formOpacityAnimation,
                              child: LoginFormWidget(
                                onLogin: _handleLogin,
                                isLoading: _isLoading,
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 4.h),

                      // Social Login Options
                      AnimatedBuilder(
                        animation: _formAnimationController,
                        builder: (context, child) {
                          return SlideTransition(
                            position: _formSlideAnimation,
                            child: FadeTransition(
                              opacity: _formOpacityAnimation,
                              // ⬇️ SocialLoginWidgetに onLineLogin を渡す ⬇️
                              child: SocialLoginWidget(
                                onGoogleLogin: _handleGoogleLogin,
                                onLineLogin: _handleLineLogin, // 👈 修正済み
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 4.h),

                      // Sign Up Link
                      AnimatedBuilder(
                        animation: _formAnimationController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _formOpacityAnimation,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text( 'CircleLinkが初めてですか？ ', /* ... style ... */ ),
                                GestureDetector(
                                  onTap: _navigateToSignUp,
                                  child: Text( 'サインアップ', /* ... style ... */ ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),
            ),

            // Biometric Prompt Overlay (現状未使用)
            if (_showBiometricPrompt)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: BiometricPromptWidget(
                    onBiometricSuccess: _handleBiometricSuccess,
                    onSkip: _skipBiometric,
                  ),
                ),
              ),

             // Loading Indicator Overlay
             if (_isLoading)
               Container(
                 color: Colors.black.withValues(alpha: 0.3),
                 child: const Center(
                   child: CircularProgressIndicator(),
                 ),
               ),
          ],
        ),
      ),
    );
  }
}