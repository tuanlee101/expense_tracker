import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'constants.dart';

class Helpers {
  static String formatCurrency(double amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)} đ';
  }

  static String formatCurrencyShort(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)} tỷ đ';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(0)} tr đ';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k đ';
    }
    return '${amount.toInt()} đ';
  }

  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hôm nay, ${DateFormat('HH:mm').format(date)}';
    } else if (dateOnly == yesterday) {
      return 'Hôm qua';
    } else if (dateOnly.isAfter(today.subtract(const Duration(days: 7)))) {
      final weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
      return weekdays[date.weekday - 1];
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  static String formatDateFull(DateTime date) {
    final months = [
      'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
      'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12',
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  static Color getCategoryColor(String categoryName) {
    switch (categoryName) {
      case 'food':
        return AppColors.primary;
      case 'shopping':
        return AppColors.secondary;
      case 'transport':
        return AppColors.tertiary;
      case 'housing':
        return AppColors.primaryContainer;
      case 'bills':
        return AppColors.error;
      case 'health':
        return const Color(0xFFe91e63);
      case 'education':
        return const Color(0xFF9c27b0);
      case 'salary':
        return AppColors.secondary;
      case 'entertainment':
        return const Color(0xFFff9800);
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  static Color getCategoryBgColor(String categoryName) {
    switch (categoryName) {
      case 'food':
        return AppColors.primaryFixed;
      case 'shopping':
        return AppColors.secondaryFixed;
      case 'transport':
        return AppColors.tertiaryContainer.withValues(alpha: 0.2);
      case 'housing':
        return AppColors.primaryContainer.withValues(alpha: 0.2);
      case 'bills':
        return AppColors.errorContainer;
      case 'health':
        return const Color(0xFFfce4ec);
      case 'education':
        return const Color(0xFFf3e5f5);
      case 'salary':
        return AppColors.secondaryFixed;
      case 'entertainment':
        return const Color(0xFFfff3e0);
      default:
        return AppColors.surfaceContainerHighest;
    }
  }
}
