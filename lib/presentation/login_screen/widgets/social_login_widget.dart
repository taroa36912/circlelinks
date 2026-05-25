import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SocialLoginWidget extends StatelessWidget {
  // Googleログイン用のコールバック関数
  final Future<void> Function() onGoogleLogin;
  // 1. LINEログイン用のコールバック関数を追加
  final Future<void> Function() onLineLogin;
  /// Whether to show the LINE login button. Defaults to true.
  final bool showLineLogin;

  const SocialLoginWidget({
    super.key,
    required this.onGoogleLogin,
    required this.onLineLogin, // 2. コンストラクタで必須にする
    this.showLineLogin = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider with "OR" text
        Row(
          children: [
            Expanded(
              child: Divider(
                color: AppTheme.lightTheme.colorScheme.outline,
                thickness: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'または',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: AppTheme.lightTheme.colorScheme.outline,
                thickness: 1,
              ),
            ),
          ],
        ),

        SizedBox(height: 3.h),

        // Google Login Button
        SizedBox(
          width: double.infinity,
          height: 6.h,
          child: OutlinedButton.icon(
            onPressed: onGoogleLogin, // 親から渡されたGoogleログイン関数
            icon: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                // ローカルアセットを使用
                'assets/images/g-logo.png',
                width: 20,
                height: 20,
                fit: BoxFit.contain,
              ),
            ),
            label: Text(
              'Googleでログイン',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: AppTheme.lightTheme.colorScheme.outline,
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // LINE Login Button (hidden on unsupported platforms)        
        if (showLineLogin)
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: OutlinedButton.icon(
              // 3. onPressed を親から渡された onLineLogin に変更
              onPressed: onLineLogin,
              icon: Image.asset(
                'assets/images/l-logo.png',
                width: 20,
                height: 20,
              ),
              label: Text(
                'LINEでログイン',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
