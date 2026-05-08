import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart' as model;
import '../providers/transaction_provider.dart';
import '../providers/asset_provider.dart';
import '../providers/bill_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<TransactionProvider, AssetProvider, BillProvider>(
      builder: (context, txProvider, assetProvider, billProvider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.marginMobile,
            0,
            AppSpacing.marginMobile,
            AppSpacing.xl,
          ),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.md),
              _buildSafeSpendingCard(txProvider),
              const SizedBox(height: AppSpacing.md),
              _buildQuickSummaryRow(txProvider, assetProvider, billProvider),
              const SizedBox(height: AppSpacing.md),
              _buildBillsOverview(billProvider),
              const SizedBox(height: AppSpacing.md),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 900;

                  if (isNarrow) {
                    return Column(
                      children: [
                        _buildWeeklyChart(txProvider),
                        const SizedBox(height: AppSpacing.md),
                        _buildRecentTransactions(txProvider),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 7,
                        child: _buildWeeklyChart(txProvider),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        flex: 5,
                        child: _buildRecentTransactions(txProvider),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSafeSpendingCard(TransactionProvider provider) {
    final safeAmount = provider.safeSpendingDaily;
    final isSafe = provider.totalExpenseToday <= safeAmount;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Chi tiêu an toàn mỗi ngày',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: isSafe
                      ? AppColors.secondaryContainer
                      : AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSafe ? Icons.check_circle : Icons.warning_amber_rounded,
                      size: 14,
                      color: isSafe
                          ? AppColors.onSecondaryContainer
                          : AppColors.onErrorContainer,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isSafe ? 'An toàn' : 'Vượt mức',
                      style: AppTypography.labelSm.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSafe
                            ? AppColors.onSecondaryContainer
                            : AppColors.onErrorContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            Helpers.formatCurrency(safeAmount),
            style: AppTypography.displayLg.copyWith(
              color: AppColors.primary,
              fontSize: 40,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Bạn có thể chi tiêu thêm tối đa mức này trong hôm nay.',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSummaryRow(TransactionProvider txProvider, AssetProvider assetProvider, BillProvider billProvider) {
    return Row(
      children: [
        Expanded(
          child: _buildMiniCard(
            icon: Icons.trending_down,
            iconBgColor: AppColors.errorContainer,
            iconColor: AppColors.onErrorContainer,
            label: 'Chi hôm nay',
            value: '-${Helpers.formatCurrency(txProvider.totalExpenseToday)}',
            valueColor: AppColors.error,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildMiniCard(
            icon: Icons.calendar_month,
            iconBgColor: AppColors.primaryFixed,
            iconColor: AppColors.onPrimaryFixed,
            label: 'Chi tháng này',
            value: Helpers.formatCurrency(txProvider.totalExpenseThisMonth),
            valueColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildMiniCard(
            icon: Icons.account_balance,
            iconBgColor: AppColors.secondaryFixed,
            iconColor: AppColors.onSecondaryFixed,
            label: 'Tổng tài sản',
            value: Helpers.formatCurrencyShort(assetProvider.totalAssets),
            valueColor: AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: AppTypography.labelSm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.bodyLg.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillsOverview(BillProvider billProvider) {
    final upcomingBills = billProvider.upcomingBills;
    final overdueBills = billProvider.overdueBills;
    final paidThisMonth = billProvider.paidThisMonth;
    final totalUpcomingAmount = upcomingBills.fold<double>(0, (sum, bill) => sum + bill.amount);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng quan hóa đơn',
            style: AppTypography.titleLg.copyWith(color: AppColors.onSurface),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _buildBillStatChip(
                icon: Icons.warning_amber_rounded,
                label: 'Quá hạn',
                value: '${overdueBills.length}',
                color: AppColors.error,
              ),
              _buildBillStatChip(
                icon: Icons.schedule,
                label: 'Sắp đến hạn',
                value: '${upcomingBills.length}',
                color: AppColors.primary,
              ),
              _buildBillStatChip(
                icon: Icons.check_circle,
                label: 'Đã thanh toán',
                value: '${paidThisMonth.length}',
                color: AppColors.secondary,
              ),
              _buildBillStatChip(
                icon: Icons.payments_outlined,
                label: 'Sắp thanh toán',
                value: Helpers.formatCurrencyShort(totalUpcomingAmount),
                color: AppColors.onSurface,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '$label: ',
            style: AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant),
          ),
          Text(
            value,
            style: AppTypography.labelSm.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(TransactionProvider provider) {
    final weekData = provider.weeklySpending;
    final weekLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final maxValue = weekData.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Xu hướng 7 ngày',
                style: AppTypography.titleLg.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                'Xem báo cáo',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final value = weekData[index];
                final height = maxValue > 0 ? (value / maxValue) : 0.0;
                final isToday = index == DateTime.now().weekday - 1;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (value > 0)
                          Text(
                            Helpers.formatCurrencyShort(value),
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 9,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Container(
                          height: (height * 120).clamp(4, 120),
                          decoration: BoxDecoration(
                            color: isToday
                                ? AppColors.primaryContainer
                                : AppColors.surfaceContainerHigh,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          weekLabels[index],
                          style: AppTypography.labelSm.copyWith(
                            color: isToday
                                ? AppColors.primary
                                : AppColors.onSurfaceVariant,
                            fontWeight: isToday ? FontWeight.bold : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(TransactionProvider provider) {
    final recent = provider.transactions.take(4).toList();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Giao dịch gần đây',
                style: AppTypography.titleLg.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...recent.map((t) => _buildTransactionItem(t)),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(model.TransactionModel t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Helpers.getCategoryBgColor(t.category.name),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Icon(
                  _getCategoryIcon(t.category.icon),
                  color: Helpers.getCategoryColor(t.category.name),
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.title,
                      style: AppTypography.bodyMd.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      Helpers.formatDate(t.date),
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                t.type == model.TransactionType.expense
                    ? '-${Helpers.formatCurrency(t.amount)}'
                    : '+${Helpers.formatCurrency(t.amount)}',
                style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.bold,
                  color: t.type == model.TransactionType.expense
                      ? AppColors.error
                      : AppColors.secondary,
                ),
              ),
            ],
          ),
        ),
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
