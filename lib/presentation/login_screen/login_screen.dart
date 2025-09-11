import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/biometric_prompt_widget.dart';
import './widgets/login_form_widget.dart';
import './widgets/social_login_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _showBiometricPrompt = false;
  late AnimationController _logoAnimationController;
  late AnimationController _formAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<Offset> _formSlideAnimation;
  late Animation<double> _formOpacityAnimation;

  // Mock credentials for testing
  final Map<String, String> _mockCredentials = {
    'student@tokyo.ac.jp': 'student123',
    'admin@university.ac.jp': 'admin123',
    'circle@waseda.ac.jp': 'circle123',
  };

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

    _logoScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _formOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formAnimationController,
      curve: Curves.easeInOut,
    ));
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

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate authentication delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock authentication logic
      final email = 'student@tokyo.ac.jp'; // This would come from form
      final password = 'student123'; // This would come from form

      if (_mockCredentials.containsKey(email) &&
          _mockCredentials[email] == password) {
        // Provide haptic feedback for successful login
        HapticFeedback.lightImpact();

        // Show biometric prompt for first-time login
        if (mounted) {
          setState(() {
            _isLoading = false;
            _showBiometricPrompt = true;
          });
        }
      } else {
        throw Exception('Invalid credentials');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('ログインに失敗しました。メールアドレスとパスワードを確認してください。'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: '閉じる',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    }
  }

  void _handleBiometricSuccess() {
    HapticFeedback.heavyImpact();
    Navigator.pushReplacementNamed(context, '/circle-discovery');
  }

  void _skipBiometric() {
    Navigator.pushReplacementNamed(context, '/circle-discovery');
  }

  void _navigateToSignUp() {
    // Navigate to sign up screen (not implemented)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('サインアップ機能は準備中です'),
        duration: Duration(seconds: 2),
      ),
    );
  }

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

                      // CircleLink Logo
                      AnimatedBuilder(
                        animation: _logoAnimationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoScaleAnimation.value,
                            child: Column(
                              children: [
                                Container(
                                  width: 25.w,
                                  height: 25.w,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppTheme.lightTheme.colorScheme.primary,
                                        AppTheme
                                            .lightTheme.colorScheme.secondary,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme
                                            .lightTheme.colorScheme.primary
                                            .withValues(alpha: 0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: CustomIconWidget(
                                      iconName: 'link',
                                      color: Colors.white,
                                      size: 12.w,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'CircleLink',
                                  style: AppTheme
                                      .lightTheme.textTheme.headlineLarge
                                      ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurface,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  '大学サークル管理アプリ',
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
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
                              child: const SocialLoginWidget(),
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
                                Text(
                                  'CircleLinkが初めてですか？ ',
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _navigateToSignUp,
                                  child: Text(
                                    'サインアップ',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
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

            // Biometric Prompt Overlay
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
          ],
        ),
      ),
    );
  }
}