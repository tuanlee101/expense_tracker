import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';

import '../providers/transaction_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class AddTransactionScreen extends StatefulWidget {
  /// Pass an existing transaction to open in edit mode.
  final TransactionModel? existingTransaction;

  const AddTransactionScreen({super.key, this.existingTransaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  late TransactionType _type;
  late TransactionCategory _category;
  final _amountController = TextEditingController(text: '0');
  final _noteController = TextEditingController();
  final _titleController = TextEditingController();
  late DateTime _selectedDate;
  late String _wallet;
  bool _isSubmitting = false;

  final _amountFocusNode = FocusNode();

  bool get _isEditing => widget.existingTransaction != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      final t = widget.existingTransaction!;
      _type = t.type;
      _category = t.category;
      _amountController.text = t.amount.toInt().toString();
      _noteController.text = t.note ?? '';
      _titleController.text = t.title;
      _selectedDate = t.date;
      _wallet = t.wallet;
    } else {
      _type = TransactionType.expense;
      _category = TransactionCategory.food;
      _selectedDate = DateTime.now();
      _wallet = 'Ví Tiền mặt';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _amountController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _amountController.text.length,
      );
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _titleController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  void _onAmountChanged(String value) {
    final filtered = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (filtered.isEmpty) {
      _amountController.text = '0';
    } else {
      _amountController.text = filtered;
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

    final provider = context.read<TransactionProvider>();

    if (_isEditing) {
      final updated = widget.existingTransaction!.copyWith(
        title: _titleController.text.isNotEmpty
            ? _titleController.text
            : _category.label,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
        amount: amount.toDouble(),
        type: _type,
        category: _category,
        date: _selectedDate,
        wallet: _wallet,
      );
      await provider.updateTransaction(updated);
    } else {
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
      await provider.addTransaction(transaction);
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.of(context).pop();
      _showSnackBar(
        _isEditing ? 'Cập nhật giao dịch thành công!' : 'Thêm giao dịch thành công!',
      );
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
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
        title: Text(
          _isEditing ? 'Sửa giao dịch' : 'Thêm giao dịch',
          style: const TextStyle(
            fontFamily: AppTypography.headlineFont,
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
        centerTitle: false,
        actions: _isEditing
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: () => _confirmDelete(),
                  tooltip: 'Xóa giao dịch',
                ),
              ]
            : null,
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
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                  )
                                ]
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
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                  )
                                ]
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
                  style: AppTypography.labelSm.copyWith(color: AppColors.outline),
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

            // Title Field (edit mode only)
            if (_isEditing) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tiêu đề',
                      style: AppTypography.labelSm.copyWith(color: AppColors.outline),
                    ),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: _category.label,
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
              const SizedBox(height: AppSpacing.md),
            ],

            // Category Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hạng mục',
                  style: AppTypography.titleLg.copyWith(color: AppColors.onSurface),
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
                          style: AppTypography.labelSm.copyWith(color: AppColors.outline),
                        ),
                        TextField(
                          controller: _noteController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'Nhập ghi chú cho giao dịch này...',
                            hintStyle: const TextStyle(color: AppColors.outlineVariant),
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
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppRadius.xxl),
                    ),
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
                    : Text(
                        _isEditing ? 'Cập nhật' : 'Thêm giao dịch',
                        style: AppTypography.bodyLg.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
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
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
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
                  color: isSelected
                      ? AppColors.onPrimaryContainer
                      : AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                cat.label,
                style: AppTypography.labelSm.copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
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
    final wallets = [
      'Ví Tiền mặt',
      'Ví Ngân hàng',
      'Ví Tiết kiệm',
      'Ví Đầu tư',
    ];

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
                leading: const Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.primary,
                ),
                title: Text(
                  w,
                  style: AppTypography.bodyLg.copyWith(color: AppColors.onSurface),
                ),
                trailing: _wallet == w
                    ? const Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        fill: 1,
                      )
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

  Future<void> _confirmDelete() async {
    final t = widget.existingTransaction!;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: const Text('Xóa giao dịch'),
        content: Text('Bạn có chắc muốn xóa "${t.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      await context.read<TransactionProvider>().deleteTransaction(t.id);
      if (mounted) {
        Navigator.of(context).pop();
        _showSnackBar('Đã xóa giao dịch');
      }
    }
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'directions_car':
        return Icons.directions_car;
      case 'home':
        return Icons.home;
      case 'receipt':
        return Icons.receipt;
      case 'favorite':
        return Icons.favorite;
      case 'school':
        return Icons.school;
      case 'payments':
        return Icons.payments;
      case 'movie':
        return Icons.movie;
      default:
        return Icons.more_horiz;
    }
  }
}