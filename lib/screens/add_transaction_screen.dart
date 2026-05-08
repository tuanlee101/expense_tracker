import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';

import '../providers/transaction_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  TransactionType _type = TransactionType.expense;
  TransactionCategory _category = TransactionCategory.food;
  final _amountController = TextEditingController(text: '0');
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _wallet = 'Ví Tiền mặt';
  bool _isSubmitting = false;

  final _amountFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _amountController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _amountController.text.length,
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  void _onAmountChanged(String value) {
    // Only allow digits
    final filtered = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (filtered.isEmpty) {
      _amountController.text = '0';
    } else {
      final number = int.parse(filtered);
      _amountController.text = number.toString();
    }
    _amountController.selection = TextSelection(
      baseOffset: _amountController.text.length,
      extentOffset: _amountController.text.length,
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      locale: const Locale('vi'),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    final amount = int.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      _showSnackBar('Vui lòng nhập số tiền hợp lệ');
      return;
    }

    setState(() => _isSubmitting = true);

    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _category.label,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
      amount: amount.toDouble(),
      type: _type,
      category: _category,
      date: _selectedDate,
      wallet: _wallet,
    );

    await context.read<TransactionProvider>().addTransaction(transaction);

    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.of(context).pop();
      _showSnackBar('Thêm giao dịch thành công!');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Thêm giao dịch',
          style: TextStyle(
            fontFamily: AppTypography.headlineFont,
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Income/Expense Toggle
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _type = TransactionType.expense),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: _type == TransactionType.expense
                              ? AppColors.surfaceContainerLowest
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          boxShadow: _type == TransactionType.expense
                              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                              : null,
                        ),
                        child: Text(
                          'Chi tiêu',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyLg.copyWith(
                            color: _type == TransactionType.expense
                                ? AppColors.onSurface
                                : AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _type = TransactionType.income),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: _type == TransactionType.income
                              ? AppColors.surfaceContainerLowest
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          boxShadow: _type == TransactionType.income
                              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                              : null,
                        ),
                        child: Text(
                          'Thu nhập',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyLg.copyWith(
                            color: _type == TransactionType.income
                                ? AppColors.onSurface
                                : AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            // Amount Input
            Column(
              children: [
                Text(
                  'Số tiền giao dịch',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.outline,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 200,
                      child: TextField(
                        controller: _amountController,
                        focusNode: _amountFocusNode,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: _onAmountChanged,
                        textAlign: TextAlign.center,
                        style: AppTypography.displayLg.copyWith(
                          color: AppColors.primary,
                          fontSize: 40,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '₫',
                        style: AppTypography.headlineMd.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 2,
                  color: AppColors.primaryContainer.withValues(alpha: 0.2),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            // Category Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hạng mục',
                  style: AppTypography.titleLg.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Xem tất cả',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildCategoryGrid(),
            const SizedBox(height: AppSpacing.lg),
            // Date Picker
            _buildInfoField(
              icon: Icons.calendar_today,
              label: 'Ngày giao dịch',
              value: Helpers.formatDateFull(_selectedDate),
              onTap: _selectDate,
            ),
            const SizedBox(height: AppSpacing.md),
            // Note Field
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: Colors.transparent),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes, color: AppColors.onSurfaceVariant, size: 20),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ghi chú',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.outline,
                          ),
                        ),
                        TextField(
                          controller: _noteController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            hintText: 'Nhập ghi chú cho giao dịch này...',
                            hintStyle: TextStyle(color: AppColors.outlineVariant),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: AppTypography.bodyLg.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Wallet Selector
            _buildInfoField(
              icon: Icons.account_balance_wallet,
              label: 'Từ ví',
              value: _wallet,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
                  ),
                  builder: (context) => _buildWalletPicker(),
                );
              },
              showArrow: true,
            ),
            const SizedBox(height: AppSpacing.xl),
            // Submit Button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  elevation: 4,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: AppColors.onPrimary,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle, fill: 1),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Lưu giao dịch',
                            style: AppTypography.bodyLg.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = TransactionCategory.values;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: AppSpacing.gutter,
        crossAxisSpacing: AppSpacing.gutter,
        childAspectRatio: 0.85,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        final isSelected = _category == cat;
        return GestureDetector(
          onTap: () => setState(() => _category = cat),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryContainer
                      : AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Icon(
                  _getCategoryIcon(cat.icon),
                  color: isSelected ? AppColors.onPrimaryContainer : AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                cat.label,
                style: AppTypography.labelSm.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : null,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoField({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
    bool showArrow = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.labelSm.copyWith(color: AppColors.outline),
                  ),
                  Text(
                    value,
                    style: AppTypography.bodyLg.copyWith(color: AppColors.onSurface),
                  ),
                ],
              ),
            ),
            if (showArrow)
              const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletPicker() {
    final wallets = ['Ví Tiền mặt', 'Ví Ngân hàng', 'Ví Tiết kiệm', 'Ví Đầu tư'];
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chọn ví',
            style: AppTypography.titleLg.copyWith(color: AppColors.onSurface),
          ),
          const SizedBox(height: AppSpacing.md),
          ...wallets.map((w) => ListTile(
                leading: const Icon(Icons.account_balance_wallet, color: AppColors.primary),
                title: Text(w, style: AppTypography.bodyLg.copyWith(color: AppColors.onSurface)),
                trailing: _wallet == w
                    ? const Icon(Icons.check_circle, color: AppColors.primary, fill: 1)
                    : null,
                onTap: () {
                  setState(() => _wallet = w);
                  Navigator.of(context).pop();
                },
              )),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'restaurant': return Icons.restaurant;
      case 'shopping_cart': return Icons.shopping_cart;
      case 'directions_car': return Icons.directions_car;
      case 'home': return Icons.home;
      case 'receipt': return Icons.receipt;
      case 'favorite': return Icons.favorite;
      case 'school': return Icons.school;
      case 'payments': return Icons.payments;
      case 'movie': return Icons.movie;
      default: return Icons.more_horiz;
    }
  }
}
