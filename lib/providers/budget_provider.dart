import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart' as intl;
import '../models/budget_model.dart';
import '../models/transaction_model.dart';
import '../services/data_service.dart';

/// Spending progress info for one budget line.
class BudgetProgress {
  final BudgetModel budget;
  final double spent;
  final double remaining;
  final double percent;

  BudgetProgress({
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.percent,
  });

  bool get isOverBudget => percent >= 100;
  bool get isWarning => percent >= 80 && percent < 100;
  bool get isSafe => percent < 80;
}

class Helpers {
  static String formatCurrency(double amount) {
    final formatter = intl.NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)}₫';
  }

  static String formatCurrencyShort(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B₫';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M₫';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K₫';
    }
    final formatter = intl.NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)}₫';
  }
}

class BudgetProvider extends ChangeNotifier {
  final DataService _dataService = DataService();

  List<BudgetModel> _budgets = [];
  bool _isLoading = false;
  List<TransactionModel> _monthTransactions = [];

  List<BudgetModel> get budgets => _budgets;
  bool get isLoading => _isLoading;

  BudgetModel? budgetFor(TransactionCategory category) {
    try {
      return _budgets.firstWhere(
        (b) => b.category == category && b.isEnabled,
      );
    } catch (_) {
      return null;
    }
  }

  List<BudgetProgress> get progressList =>
      _budgets.map(_computeProgress).toList();

  List<BudgetProgress> get activeProgress =>
      _budgets.where((b) => b.isEnabled).map(_computeProgress).toList();

  /// Overall spending vs total budget limits across enabled budgets.
  double get totalBudgeted => _budgets
      .where((b) => b.isEnabled)
      .fold(0.0, (sum, b) => sum + b.limit);

  double get totalSpent => activeProgress.fold(0.0, (sum, p) => sum + p.spent);

  double get budgetUsagePercent =>
      totalBudgeted > 0 ? (totalSpent / totalBudgeted) * 100 : 0;

  String get monthEndForecast {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = daysInMonth - now.day;
    if (daysLeft <= 0) return 'Hôm nay là cuối tháng.';

    final active = activeProgress;
    if (active.isEmpty) return 'Chưa có ngân sách nào.';

    double overBudgetTotal = 0;
    double withinBudgetRemaining = 0;

    for (final p in active) {
      if (p.isOverBudget) {
        overBudgetTotal += p.spent - p.budget.limit;
      } else {
        withinBudgetRemaining += p.remaining;
      }
    }

    if (overBudgetTotal > 0 && withinBudgetRemaining > 0) {
      if (overBudgetTotal <= withinBudgetRemaining) {
        return 'Còn $daysLeft ngày — ổn, dư các mục khác bù được cho mục đã vượt.';
      } else {
        return 'Còn $daysLeft ngày — đang vượt ${Helpers.formatCurrency(overBudgetTotal - withinBudgetRemaining)} so với tổng ngân sách.';
      }
    } else if (overBudgetTotal > 0) {
      return 'Còn $daysLeft ngày — đang vượt tổng ${Helpers.formatCurrency(overBudgetTotal)}.';
    } else {
      return 'Còn $daysLeft ngày — còn ${Helpers.formatCurrency(withinBudgetRemaining)} có thể chi tiêu.';
    }
  }

  BudgetProgress _computeProgress(BudgetModel budget) {
    final now = DateTime.now();
    final spent = _monthTransactions
        .where((t) =>
            t.type == TransactionType.expense &&
            t.category == budget.category &&
            t.date.month == now.month &&
            t.date.year == now.year)
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    final remaining = budget.limit - spent;
    final percent = budget.limit > 0 ? (spent / budget.limit) * 100 : 0.0;

    return BudgetProgress(
      budget: budget,
      spent: spent,
      remaining: remaining > 0 ? remaining : 0,
      percent: percent.clamp(0, 999),
    );
  }

  /// Call this whenever transactions change.
  void syncTransactions(List<TransactionModel> transactions) {
    _monthTransactions = transactions;
    notifyListeners();
  }

  Future<void> loadBudgets() async {
    _isLoading = true;
    notifyListeners();
    _budgets = await _dataService.getBudgets();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setBudget(BudgetModel budget) async {
    final idx = _budgets.indexWhere((b) => b.category == budget.category);
    if (idx != -1) {
      _budgets[idx] = budget;
    } else {
      _budgets.add(budget);
    }
    await _dataService.saveBudgets(_budgets);
    notifyListeners();
  }

  Future<void> removeBudget(String id) async {
    _budgets.removeWhere((b) => b.id == id);
    await _dataService.saveBudgets(_budgets);
    notifyListeners();
  }

  Future<void> toggleBudget(String id, bool enabled) async {
    final idx = _budgets.indexWhere((b) => b.id == id);
    if (idx != -1) {
      _budgets[idx] = _budgets[idx].copyWith(isEnabled: enabled);
      await _dataService.saveBudgets(_budgets);
      notifyListeners();
    }
  }

  Future<void> setBudgetLimit(String id, double limit) async {
    final idx = _budgets.indexWhere((b) => b.id == id);
    if (idx != -1) {
      _budgets[idx] = _budgets[idx].copyWith(limit: limit);
      await _dataService.saveBudgets(_budgets);
      notifyListeners();
    }
  }
}