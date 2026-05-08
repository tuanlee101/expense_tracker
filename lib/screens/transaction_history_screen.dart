import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'add_transaction_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            // Search + Export bar
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.marginMobile,
                AppSpacing.sm,
                AppSpacing.marginMobile,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => provider.setSearchQuery(value),
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm giao dịch...',
                          hintStyle: TextStyle(
                            color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.outline,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    provider.setSearchQuery('');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.md,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    onPressed: () => _exportCsv(context, provider),
                    icon: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: const Icon(
                        Icons.ios_share,
                        color: AppColors.onSecondaryContainer,
                        size: 20,
                      ),
                    ),
                    tooltip: 'Xuất CSV',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Filter Chips (horizontal scroll)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.marginMobile,
                ),
                children: [
                  _buildFilterChip(
                    label: 'Tháng này',
                    icon: Icons.calendar_month,
                    isSelected: provider.filterDateStart == null &&
                        provider.filterCategory == null &&
                        provider.filterType == null &&
                        provider.filterWallet == null,
                    onTap: () => provider.clearFilters(),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _buildFilterChip(
                    label: 'Chi tiêu',
                    icon: Icons.trending_down,
                    isSelected: provider.filterType == TransactionType.expense,
                    onTap: () => provider.setFilterType(
                      provider.filterType == TransactionType.expense
                          ? null
                          : TransactionType.expense,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _buildFilterChip(
                    label: 'Thu nhập',
                    icon: Icons.trending_up,
                    isSelected: provider.filterType == TransactionType.income,
                    onTap: () => provider.setFilterType(
                      provider.filterType == TransactionType.income
                          ? null
                          : TransactionType.income,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _buildFilterChip(
                    label: 'Hạng mục',
                    icon: Icons.category,
                    isSelected: provider.filterCategory != null,
                    onTap: () => _showCategoryFilter(provider),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _buildFilterChip(
                    label: 'Ngày',
                    icon: Icons.date_range,
                    isSelected:
                        provider.filterDateStart != null || provider.filterDateEnd != null,
                    onTap: () => _showDateRangePicker(provider),
                  ),
                  if (provider.wallets.length > 1) ...[
                    const SizedBox(width: AppSpacing.sm),
                    _buildFilterChip(
                      label: provider.filterWallet ?? 'Ví',
                      icon: Icons.account_balance_wallet,
                      isSelected: provider.filterWallet != null,
                      onTap: () => _showWalletFilter(provider),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Transaction List
            Expanded(
              child: provider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : provider.filteredTransactions.isEmpty
                      ? _buildEmptyState()
                      : _buildTransactionList(provider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondaryContainer
              : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? AppColors.onSecondaryContainer
                  : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.labelSm.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.onSecondaryContainer
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryFilter(TransactionProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chọn hạng mục',
              style: AppTypography.titleLg.copyWith(color: AppColors.onSurface),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                ActionChip(
                  label: Text('Tất cả', style: AppTypography.labelSm),
                  onPressed: () {
                    provider.setFilterCategory(null);
                    Navigator.of(ctx).pop();
                  },
                  backgroundColor: provider.filterCategory == null
                      ? AppColors.primaryContainer
                      : AppColors.surfaceContainerHigh,
                ),
                ...TransactionCategory.values.map((cat) => ActionChip(
                      avatar: Icon(
                        _getCategoryIcon(cat.icon),
                        size: 16,
                        color: provider.filterCategory == cat
                            ? AppColors.onPrimaryContainer
                            : AppColors.primary,
                      ),
                      label: Text(cat.label, style: AppTypography.labelSm),
                      onPressed: () {
                        provider.setFilterCategory(cat);
                        Navigator.of(ctx).pop();
                      },
                      backgroundColor: provider.filterCategory == cat
                          ? AppColors.primaryContainer
                          : AppColors.surfaceContainerHigh,
                    )),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Future<void> _showDateRangePicker(TransactionProvider provider) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: provider.filterDateStart != null && provider.filterDateEnd != null
          ? DateTimeRange(
              start: provider.filterDateStart!,
              end: provider.filterDateEnd!,
            )
          : null,
      locale: const Locale('vi'),
    );

    if (picked != null) {
      provider.setFilterDateRange(picked.start, picked.end);
    }
  }

  void _showWalletFilter(TransactionProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      builder: (ctx) => Padding(
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
            ...provider.wallets.map((w) => ListTile(
                  leading: const Icon(
                    Icons.account_balance_wallet,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    w,
                    style: AppTypography.bodyLg.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                  trailing: provider.filterWallet == w
                      ? const Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                          fill: 1,
                        )
                      : null,
                  onTap: () {
                    provider.setFilterWallet(
                      provider.filterWallet == w ? null : w,
                    );
                    Navigator.of(ctx).pop();
                  },
                )),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Future<void> _exportCsv(BuildContext context, TransactionProvider provider) async {
    try {
      final csvContent = provider.getCsvContent();
      final dir = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${dir.path}/expense_tracker_$timestamp.csv');
      await file.writeAsString(csvContent, encoding: utf8);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/csv')],
        text: 'Báo cáo giao dịch Expense Tracker',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xuất CSV thất bại: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Không tìm thấy giao dịch nào',
              style: AppTypography.headlineMd.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Thử điều chỉnh bộ lọc hoặc từ khóa tìm kiếm.',
              style: AppTypography.bodyLg.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(TransactionProvider provider) {
    final transactions = provider.filteredTransactions;
    final grouped = <String, List<TransactionModel>>{};
    final groupTotals = <String, double>{};

    for (final t in transactions) {
      final key = _getGroupKey(t.date);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(t);
      groupTotals[key] = (groupTotals[key] ?? 0) +
          (t.type == TransactionType.expense ? -t.amount : t.amount);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final key = grouped.keys.elementAt(index);
        final items = grouped[key]!;
        final total = groupTotals[key]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    key.toUpperCase(),
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.outline,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    total >= 0
                        ? '+${Helpers.formatCurrency(total)}'
                        : Helpers.formatCurrency(total.abs()),
                    style: AppTypography.labelSm.copyWith(
                      fontWeight: FontWeight.bold,
                      color: total >= 0 ? AppColors.secondary : AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
            ...items.map((t) => _buildTransactionItem(t, provider)),
          ],
        );
      },
    );
  }

  String _getGroupKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Hôm nay';
    if (dateOnly == yesterday) return 'Hôm qua';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Widget _buildTransactionItem(TransactionModel t, TransactionProvider provider) {
    return Dismissible(
      key: Key(t.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context, t),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.errorContainer,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.error),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          onTap: () => _editTransaction(context, t),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Helpers.getCategoryBgColor(t.category.name),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Icon(
                    _getCategoryIcon(t.category.icon),
                    color: Helpers.getCategoryColor(t.category.name),
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.category.label,
                        style: AppTypography.bodyLg.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      if (t.note != null && t.note!.isNotEmpty)
                        Text(
                          t.note!,
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      Text(
                        t.wallet,
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      t.type == TransactionType.expense
                          ? '- ${Helpers.formatCurrency(t.amount)}'
                          : '+ ${Helpers.formatCurrency(t.amount)}',
                      style: AppTypography.bodyLg.copyWith(
                        fontWeight: FontWeight.bold,
                        color: t.type == TransactionType.expense
                            ? AppColors.error
                            : AppColors.secondary,
                      ),
                    ),
                    Text(
                      Helpers.formatDate(t.date),
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, TransactionModel t) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: const Text('Xóa giao dịch'),
        content: Text('Bạn có chắc muốn xóa giao dịch "${t.category.label}"?'),
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

    if (result == true) {
      if (context.mounted) {
        context.read<TransactionProvider>().deleteTransaction(t.id);
      }
      return true;
    }
    return false;
  }

  void _editTransaction(BuildContext context, TransactionModel t) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(existingTransaction: t),
      ),
    );
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