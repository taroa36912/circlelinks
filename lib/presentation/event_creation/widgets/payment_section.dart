import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PaymentSection extends StatefulWidget {
  final double? costPerPerson;
  final Function(double?) onCostChanged;
  final bool payPayEnabled;
  final Function(bool) onPayPayToggled;
  final String paymentMethod;
  final Function(String) onPaymentMethodChanged;

  const PaymentSection({
    super.key,
    required this.costPerPerson,
    required this.onCostChanged,
    required this.payPayEnabled,
    required this.onPayPayToggled,
    required this.paymentMethod,
    required this.onPaymentMethodChanged,
  });

  @override
  State<PaymentSection> createState() => _PaymentSectionState();
}

class _PaymentSectionState extends State<PaymentSection> {
  final TextEditingController _costController = TextEditingController();

  final List<Map<String, dynamic>> paymentMethods = [
    {
      'id': 'cash',
      'name': '現金',
      'icon': 'payments',
      'description': '当日現金で集金',
    },
    {
      'id': 'paypay',
      'name': 'PayPay',
      'icon': 'qr_code',
      'description': 'PayPayで事前決済',
    },
    {
      'id': 'bank_transfer',
      'name': '銀行振込',
      'icon': 'account_balance',
      'description': '指定口座への振込',
    },
    {
      'id': 'mixed',
      'name': '複数対応',
      'icon': 'credit_card',
      'description': '現金・PayPay両方対応',
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.costPerPerson != null) {
      _costController.text = widget.costPerPerson!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '支払い設定',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
            ),
            SizedBox(height: 3.h),

            // Cost Per Person
            TextField(
              controller: _costController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '一人当たりの費用',
                hintText: '例：3000',
                prefixIcon: Icon(
                  Icons.help_outline,
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
                suffixText: '円',
                helperText: '空欄の場合は無料イベント',
              ),
              onChanged: (value) {
                final cost = double.tryParse(value);
                widget.onCostChanged(cost);
              },
            ),
            SizedBox(height: 3.h),

            // Payment Method Selection
            Text(
              '支払い方法',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
            ),
            SizedBox(height: 1.h),

            Column(
              children: paymentMethods.map((method) {
                final isSelected = widget.paymentMethod == method['id'];

                return Container(
                  margin: EdgeInsets.only(bottom: 1.h),
                  child: GestureDetector(
                    onTap: () => widget.onPaymentMethodChanged(method['id']),
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primaryContainer
                                .withValues(alpha: 0.3)
                            : AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.outline,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10.w,
                            height: 10.w,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.lightTheme.colorScheme.primary
                                      .withValues(alpha: 0.1)
                                  : AppTheme.outline.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: CustomIconWidget(
                              iconName: method['icon'],
                              color: isSelected
                                  ? AppTheme.lightTheme.colorScheme.primary
                                  : AppTheme.textSecondary,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  method['name'],
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: isSelected
                                            ? AppTheme.textPrimary
                                            : AppTheme.textSecondary,
                                      ),
                                ),
                                Text(
                                  method['description'],
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          CustomIconWidget(
                            iconName: isSelected
                                ? 'radio_button_checked'
                                : 'radio_button_unchecked',
                            color: isSelected
                                ? AppTheme.lightTheme.colorScheme.primary
                                : AppTheme.textSecondary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            // PayPay Integration Toggle (if PayPay is selected)
            if (widget.paymentMethod == 'paypay' ||
                widget.paymentMethod == 'mixed') ...[
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primaryContainer
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'qr_code_scanner',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 20,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'PayPay自動決済',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                        Switch(
                          value: widget.payPayEnabled,
                          onChanged: widget.onPayPayToggled,
                          activeThumbColor: AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      widget.payPayEnabled
                          ? 'メンバーはPayPayで事前決済できます'
                          : 'PayPay決済を有効にすると自動集金が可能です',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],

            // Cost Calculation Preview
            if (widget.costPerPerson != null && widget.costPerPerson! > 0) ...[
              SizedBox(height: 3.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '費用計算プレビュー',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    SizedBox(height: 1.h),
                    _buildCostRow('一人当たり',
                        '¥${widget.costPerPerson!.toStringAsFixed(0)}'),
                    _buildCostRow('10人参加の場合',
                        '¥${(widget.costPerPerson! * 10).toStringAsFixed(0)}'),
                    _buildCostRow('20人参加の場合',
                        '¥${(widget.costPerPerson! * 20).toStringAsFixed(0)}'),
                    _buildCostRow('30人参加の場合',
                        '¥${(widget.costPerPerson! * 30).toStringAsFixed(0)}'),
                  ],
                ),
              ),
            ],

            // Payment Instructions
            if (widget.paymentMethod.isNotEmpty) ...[
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.secondaryContainer
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.secondary
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'info',
                          color: AppTheme.lightTheme.colorScheme.secondary,
                          size: 18,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          '支払い方法の説明',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color:
                                    AppTheme.lightTheme.colorScheme.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      _getPaymentInstructions(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCostRow(String label, String amount) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          Text(
            amount,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
          ),
        ],
      ),
    );
  }

  String _getPaymentInstructions() {
    switch (widget.paymentMethod) {
      case 'cash':
        return 'イベント当日に現金で集金します。お釣りのないようご準備ください。';
      case 'paypay':
        return 'PayPayでの事前決済となります。QRコードを読み取って支払いを完了してください。';
      case 'bank_transfer':
        return '指定の銀行口座への振込となります。振込手数料は各自負担でお願いします。';
      case 'mixed':
        return '現金またはPayPayでの支払いが可能です。事前決済を希望する方はPayPayをご利用ください。';
      default:
        return '';
    }
  }
}
