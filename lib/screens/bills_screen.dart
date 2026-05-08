import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bill_model.dart';
import '../providers/bill_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class BillsScreen extends StatelessWidget {
  const BillsScreen({super.key});

  DateTime _getDueDateForCurrentMonth(int dueDay) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, dueDay);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BillProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCards(provider),
              const SizedBox(height: AppSpacing.md),
              _buildSectionTitle('Sắp đến hạn'),
              const SizedBox(height: AppSpacing.sm),
              ...provider.upcomingBills.map((b) => _buildBillItem(context, provider, b)),
              const SizedBox(height: AppSpacing.md),
              _buildSectionTitle('Quá hạn'),
              const SizedBox(height: AppSpacing.sm),
              ...provider.overdueBills.map((b) => _buildBillItem(context, provider, b)),
              const SizedBox(height: AppSpacing.md),
              _buildSectionTitle('Tất cả hóa đơn'),
              const SizedBox(height: AppSpacing.sm),
              ...provider.bills.map((b) => _buildBillItem(context, provider, b)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(BillProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            'Tổng tháng',
            Helpers.formatCurrency(provider.totalMonthlyBills),
            AppColors.primaryContainer,
            AppColors.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _summaryCard(
            'Đã thanh toán',
            '${provider.paidCount}',
            AppColors.secondaryContainer,
            AppColors.onSecondaryContainer,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _summaryCard(
            'Chưa thanh toán',
            '${provider.unpaidCount}',
            AppColors.errorContainer,
            AppColors.onErrorContainer,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(String label, String value, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.labelSm.copyWith(color: fg)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.bodyLg.copyWith(
              color: fg,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: AppTypography.titleLg.copyWith(color: AppColors.onSurface),
    );
  }

  Widget _buildBillItem(BuildContext context, BillProvider provider, BillModel bill) {
    final dueDate = _getDueDateForCurrentMonth(bill.dueDay);
    final isOverdue = !bill.isPaid && dueDate.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isOverdue
              ? AppColors.error.withValues(alpha: 0.5)
              : AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _categoryColor(bill.category).withValues(alpha: 0.15),
          child: Icon(_categoryIcon(bill.category), color: _categoryColor(bill.category)),
        ),
        title: Text(
          bill.name,
          style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Hạn: ngày ${bill.dueDay}',
          style: AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              Helpers.formatCurrency(bill.amount),
              style: AppTypography.bodyMd.copyWith(
                fontWeight: FontWeight.bold,
                color: bill.isPaid ? AppColors.secondary : AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            GestureDetector(
              onTap: () => provider.markBillPaid(bill.id, !bill.isPaid),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: bill.isPaid ? AppColors.secondaryContainer : AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  bill.isPaid ? 'Đã trả' : 'Chưa trả',
                  style: AppTypography.labelSm.copyWith(
                    color: bill.isPaid ? AppColors.onSecondaryContainer : AppColors.onErrorContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(BillCategory category) {
    switch (category) {
      case BillCategory.electricity:
        return Icons.bolt;
      case BillCategory.water:
        return Icons.water_drop;
      case BillCategory.rent:
        return Icons.home;
      case BillCategory.internet:
        return Icons.wifi;
      case BillCategory.subscription:
        return Icons.subscriptions;
      case BillCategory.installment:
        return Icons.credit_card;
      case BillCategory.other:
        return Icons.receipt_long;
    }
  }

  Color _categoryColor(BillCategory category) {
    switch (category) {
      case BillCategory.electricity:
        return const Color(0xFFFFC107);
      case BillCategory.water:
        return const Color(0xFF2196F3);
      case BillCategory.rent:
        return const Color(0xFFFF9800);
      case BillCategory.internet:
        return const Color(0xFF00BCD4);
      case BillCategory.subscription:
        return const Color(0xFFE91E63);
      case BillCategory.installment:
        return const Color(0xFF9C27B0);
      case BillCategory.other:
        return const Color(0xFF795548);
    }
  }
}