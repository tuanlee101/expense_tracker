import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import '../services/data_service.dart';

class TransactionProvider extends ChangeNotifier {
  final DataService _dataService = DataService();
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String _searchQuery = '';
  TransactionCategory? _filterCategory;
  TransactionType? _filterType;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  TransactionCategory? get filterCategory => _filterCategory;
  TransactionType? get filterType => _filterType;

  List<TransactionModel> get filteredTransactions {
    var result = _transactions;
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((t) =>
              t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (t.note?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                  false))
          .toList();
    }
    if (_filterCategory != null) {
      result = result.where((t) => t.category == _filterCategory).toList();
    }
    if (_filterType != null) {
      result = result.where((t) => t.type == _filterType).toList();
    }
    return result;
  }

  double get totalIncomeThisMonth {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.type == TransactionType.income &&
            t.date.month == now.month &&
            t.date.year == now.year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpenseThisMonth {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            t.date.month == now.month &&
            t.date.year == now.year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpenseToday {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            t.date.year == now.year &&
            t.date.month == now.month &&
            t.date.day == now.day)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get safeSpendingDaily {
    // Fallback: 50% monthly income / 30 days when user budget is unavailable
    final monthlyIncome = totalIncomeThisMonth;
    if (monthlyIncome <= 0) return 450000;
    final safeAmount = (monthlyIncome * 0.5) / 30;
    return safeAmount > 0 ? safeAmount : 450000;
  }

  Map<String, double> get categoryBreakdown {
    final map = <String, double>{};
    for (final t in _transactions.where(
        (t) => t.type == TransactionType.expense && _isCurrentMonth(t.date))) {
      map[t.category.label] = (map[t.category.label] ?? 0) + t.amount;
    }
    return map;
  }

  List<MapEntry<String, double>> get topCategories {
    final entries = categoryBreakdown.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.take(5).toList();
  }

  bool _isCurrentMonth(DateTime date) {
    final now = DateTime.now();
    return date.month == now.month && date.year == now.year;
  }

  List<double> get weeklySpending {
    final now = DateTime.now();
    final weekData = <double>[0, 0, 0, 0, 0, 0, 0];
    final monday = now.subtract(Duration(days: now.weekday - 1));

    for (final t in _transactions.where((t) => t.type == TransactionType.expense)) {
      if (t.date.isAfter(monday.subtract(const Duration(days: 1))) &&
          t.date.isBefore(monday.add(const Duration(days: 7)))) {
        final dayIndex = t.date.weekday - 1;
        weekData[dayIndex] += t.amount;
      }
    }
    return weekData;
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();
    _transactions = await _dataService.getTransactions();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _dataService.addTransaction(transaction);
    await loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    await _dataService.deleteTransaction(id);
    await loadTransactions();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _dataService.updateTransaction(transaction);
    await loadTransactions();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterCategory(TransactionCategory? category) {
    _filterCategory = category;
    notifyListeners();
  }

  void setFilterType(TransactionType? type) {
    _filterType = type;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterCategory = null;
    _filterType = null;
    notifyListeners();
  }
}
