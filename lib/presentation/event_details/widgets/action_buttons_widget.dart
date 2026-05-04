import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ActionButtonsWidget extends StatefulWidget {
  final Map<String, dynamic> eventData;
  final String currentUserStatus;
  final Function(String) onStatusChanged;

  const ActionButtonsWidget({
    super.key,
    required this.eventData,
    required this.currentUserStatus,
    required this.onStatusChanged,
  });

  @override
  State<ActionButtonsWidget> createState() => _ActionButtonsWidgetState();
}

class _ActionButtonsWidgetState extends State<ActionButtonsWidget> {
  bool _isProcessingPayment = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRSVPButtons(),
            SizedBox(height: 2.h),
            _buildPaymentSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildRSVPButtons() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildRSVPDropdown(),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: _buildQuickActionButton(),
        ),
      ],
    );
  }

  Widget _buildRSVPDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.lightTheme.colorScheme.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: PopupMenuButton<String>(
        onSelected: (value) {
          widget.onStatusChanged(value);
          _showStatusUpdateFeedback(value);
        },
        itemBuilder: (context) => [
          _buildPopupMenuItem('attending', 'Attending', 'check_circle',
              AppTheme.lightTheme.colorScheme.tertiary),
          _buildPopupMenuItem(
              'late', 'Attending Late', 'schedule', AppTheme.warning),
          _buildPopupMenuItem('first_party', 'First Party Only', 'local_bar',
              AppTheme.lightTheme.colorScheme.secondary),
          _buildPopupMenuItem('undecided', 'Undecided', 'help_outline',
              AppTheme.lightTheme.colorScheme.outline),
          _buildPopupMenuItem(
              'not_attending', 'Not Attending', 'cancel', AppTheme.error),
        ],
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: _getStatusIcon(widget.currentUserStatus),
                color: _getStatusColor(widget.currentUserStatus),
                size: 20,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  _getStatusText(widget.currentUserStatus),
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: _getStatusColor(widget.currentUserStatus),
                  ),
                  // 💡 修正: 文字が長すぎる場合は「...」で省略してエラーを防ぐ
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              CustomIconWidget(
                iconName: 'keyboard_arrow_down',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(
      String value, String text, String iconName, Color color) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: color,
            size: 20,
          ),
          SizedBox(width: 3.w),
          Text(
            text,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: value == widget.currentUserStatus ? color : null,
              fontWeight:
                  value == widget.currentUserStatus ? FontWeight.w500 : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton() {
    return ElevatedButton(
      onPressed: () => _showQuickActions(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.lightTheme.colorScheme.primaryContainer,
        foregroundColor: AppTheme.lightTheme.colorScheme.onPrimaryContainer,
        padding: EdgeInsets.symmetric(vertical: 3.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: CustomIconWidget(
        iconName: 'more_horiz',
        color: AppTheme.lightTheme.colorScheme.onPrimaryContainer,
        size: 24,
      ),
    );
  }

  Widget _buildPaymentSection() {
    final paymentStatus =
        widget.eventData['paymentStatus'] as String? ?? 'pending';
    final amount = widget.eventData['amount'] as String? ?? '¥3,500';

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: _getPaymentBackgroundColor(paymentStatus),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getPaymentBorderColor(paymentStatus),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: _getPaymentIconColor(paymentStatus),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: _getPaymentIcon(paymentStatus),
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          // 💡 修正: Expandedの割合(flex)を指定し、ボタンとスペースを分け合うようにした
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getPaymentStatusText(paymentStatus),
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: _getPaymentTextColor(paymentStatus),
                  ),
                  overflow: TextOverflow.ellipsis, // 💡 はみ出し防止
                ),
                Text(
                  amount,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis, // 💡 はみ出し防止
                ),
              ],
            ),
          ),
          if (paymentStatus == 'pending') ...[
            SizedBox(width: 2.w),
            // 💡 修正: ボタンもExpandedで囲み、画面を突き破らないようにした
            Expanded(
              flex: 2,
              child: _isProcessingPayment
                  ? Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 6.w,
                        height: 6.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _processPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppTheme.lightTheme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 1.5.h), // 余白を調整
                      ),
                      // 💡 修正: スマホが細すぎる場合は文字を自動縮小させる
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Pay Now'),
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }

  String _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'attending':
        return 'check_circle';
      case 'late':
        return 'schedule';
      case 'first_party':
        return 'local_bar';
      case 'not_attending':
        return 'cancel';
      default:
        return 'help_outline';
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'attending':
        return 'Attending';
      case 'late':
        return 'Attending Late';
      case 'first_party':
        return 'First Party Only';
      case 'not_attending':
        return 'Not Attending';
      default:
        return 'Undecided';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'attending':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'late':
        return AppTheme.warning;
      case 'first_party':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'not_attending':
        return AppTheme.error;
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }

  String _getPaymentIcon(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'check';
      case 'fronted':
        return 'account_balance_wallet';
      default:
        return 'payment';
    }
  }

  String _getPaymentStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'Payment Complete';
      case 'fronted':
        return 'Payment Fronted';
      default:
        return 'Payment Pending';
    }
  }

  Color _getPaymentBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppTheme.lightTheme.colorScheme.tertiaryContainer;
      case 'fronted':
        return AppTheme.lightTheme.colorScheme.secondaryContainer;
      default:
        return AppTheme.warning.withValues(alpha: 0.1);
    }
  }

  Color _getPaymentBorderColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'fronted':
        return AppTheme.lightTheme.colorScheme.secondary;
      default:
        return AppTheme.warning;
    }
  }

  Color _getPaymentIconColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'fronted':
        return AppTheme.lightTheme.colorScheme.secondary;
      default:
        return AppTheme.warning;
    }
  }

  Color _getPaymentTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppTheme.lightTheme.colorScheme.onTertiaryContainer;
      case 'fronted':
        return AppTheme.lightTheme.colorScheme.onSecondaryContainer;
      default:
        return AppTheme.warning;
    }
  }

  void _showStatusUpdateFeedback(String status) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status updated to ${_getStatusText(status)}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              margin: EdgeInsets.only(bottom: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Quick Actions',
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
            SizedBox(height: 3.h),
            _buildQuickActionItem(
                'add_to_photos', 'Add Photos', () => Navigator.pop(context)),
            _buildQuickActionItem(
                'comment', 'View Comments', () => Navigator.pop(context)),
            _buildQuickActionItem(
                'receipt', 'Expense Details', () => Navigator.pop(context)),
            _buildQuickActionItem('contact_phone', 'Contact Organizer',
                () => Navigator.pop(context)),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(
      String iconName, String title, VoidCallback onTap) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: iconName,
        color: AppTheme.lightTheme.colorScheme.primary,
        size: 24,
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyLarge,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessingPayment = true);

    try {
      final rawAmount = widget.eventData['amount'] as String? ?? '';
      final cleanedAmount = rawAmount.replaceAll(RegExp(r'[^0-9]'), '');
      final amount = int.tryParse(cleanedAmount) ?? 0;

      if (amount <= 0) {
        throw Exception('Invalid payment amount.');
      }

      final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
          .httpsCallable('createStripePaymentIntent');
      final result = await callable.call(<String, dynamic>{
        'amount': amount,
      });

      final data = result.data as Map<String, dynamic>?;
      final clientSecret = data?['clientSecret'] as String?;

      if (clientSecret == null || clientSecret.isEmpty) {
        throw Exception('Unable to retrieve Stripe client secret.');
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'CircleLinks',
          style: ThemeMode.light,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Payment processed successfully via Stripe'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
          ),
        );
      }
    } on StripeException catch (error) {
      final message = error.error.localizedMessage ??
          error.error.message ??
          'Stripe payment failed or was canceled.';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
      }
    }
  }
}
