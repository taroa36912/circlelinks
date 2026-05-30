import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SocialLoginWidget extends StatelessWidget {
  // Googleログイン用のコールバック関数
  final Future<void> Function() onGoogleLogin;

  // LINEログイン用のコールバック関数
  final Future<void> Function() onLineLogin;

  /// Whether to show the LINE login button. Defaults to true.
  final bool showLineLogin;

  const SocialLoginWidget({
    super.key,
    required this.onGoogleLogin,
    required this.onLineLogin,
    this.showLineLogin = true,
  });

  static const double _buttonHeight = 52;
  static const double _iconSize = 20;

  TextStyle? _buttonTextStyle(BuildContext context) {
    return AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
      color: AppTheme.lightTheme.colorScheme.onSurface,
      fontWeight: FontWeight.w500,
      height: 1.2,
    );
  }

  ButtonStyle _outlinedButtonStyle() {
    return OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(_buttonHeight),
      fixedSize: const Size.fromHeight(_buttonHeight),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      side: BorderSide(
        color: AppTheme.lightTheme.colorScheme.outline,
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      alignment: Alignment.center,
    );
  }

  Widget _buttonLabel(BuildContext context, String text) {
    return Flexible(
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        strutStyle: const StrutStyle(
          fontSize: 16,
          height: 1.2,
          forceStrutHeight: true,
        ),
        style: _buttonTextStyle(context),
      ),
    );
  }

  Widget _socialButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required Widget icon,
    required String label,
  }) {
    return SizedBox(
      width: double.infinity,
      height: _buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: _outlinedButtonStyle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: _iconSize,
              height: _iconSize,
              child: Center(child: icon),
            ),
            const SizedBox(width: 12),
            _buttonLabel(context, label),
          ],
        ),
      ),
    );
  }

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
        _socialButton(
          context: context,
          onPressed: onGoogleLogin,
          icon: Image.asset(
            'assets/images/g-logo.png',
            width: _iconSize,
            height: _iconSize,
            fit: BoxFit.contain,
          ),
          label: 'Googleでログイン',
        ),

        SizedBox(height: 2.h),

        // LINE Login Button
        if (showLineLogin)
          _socialButton(
            context: context,
            onPressed: onLineLogin,
            icon: Image.asset(
              'assets/images/l-logo.png',
              width: _iconSize,
              height: _iconSize,
              fit: BoxFit.contain,
            ),
            label: 'LINEでログイン',
          ),
      ],
    );
  }
}
