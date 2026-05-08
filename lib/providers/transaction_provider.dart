import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';
import '../services/data_service.dart';

class TransactionProvider extends ChangeNotifier {
  final DataService _dataService = DataService();
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String _searchQuery = '';
  TransactionCategory? _filterCategory;
  TransactionType? _filterType;
  DateTime? _filterDateStart;
  DateTime? _filterDateEnd;
  String? _filterWallet;
  UserModel _user = UserModel();

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  TransactionCategory? get filterCategory => _filterCategory;
  TransactionType? get filterType => _filterType;
  DateTime? get filterDateStart => _filterDateStart;
  DateTime? get filterDateEnd => _filterDateEnd;
  String? get filterWallet => _filterWallet;

  /// All unique wallet names from transactions.
  List<String> get wallets =>
      _transactions.map((t) => t.wallet).toSet().toList()..sort();

  List<TransactionModel> get filteredTransactions {
    var result = _transactions;

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((t) {
        return t.title.toLowerCase().contains(query) ||
            t.category.label.toLowerCase().contains(query) ||
            (t.note?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    if (_filterCategory != null) {
      result = result.where((t) => t.category == _filterCategory).toList();
    }

    if (_filterType != null) {
      result = result.where((t) => t.type == _filterType).toList();
    }

    if (_filterDateStart != null) {
      result = result
          .where((t) => t.date.isAfter(_filterDateStart!.subtract(const Duration(days: 1))))
          .toList();
    }

    if (_filterDateEnd != null) {
      result = result.where((t) => t.date.isBefore(_filterDateEnd!.add(const Duration(days: 1)))).toList();
    }

    if (_filterWallet != null) {
      result = result.where((t) => t.wallet == _filterWallet).toList();
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
    // Priority 1: explicit user safe budget (monthly) -> daily
    if (_user.safeBudget > 0) {
      return _user.safeBudget / 30;
    }

    // Priority 2: remaining budget after fixed cost
    final remaining = totalIncomeThisMonth - _user.monthlyFixedCost;
    if (remaining > 0) {
      return remaining / 30;
    }

    // Priority 3: conservative fallback from income
    final monthlyIncome = totalIncomeThisMonth;
    if (monthlyIncome > 0) {
      final safeAmount = (monthlyIncome * 0.5) / 30;
      if (safeAmount > 0) return safeAmount;
    }

    // Last resort fallback
    return 450000;
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

  void setFilterDateRange(DateTime? start, DateTime? end) {
    _filterDateStart = start;
    _filterDateEnd = end;
    notifyListeners();
  }

  void setFilterWallet(String? wallet) {
    _filterWallet = wallet;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterCategory = null;
    _filterType = null;
    _filterDateStart = null;
    _filterDateEnd = null;
    _filterWallet = null;
    notifyListeners();
  }

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  /// Generate CSV content for export.
  String getCsvContent({List<TransactionModel>? transactions}) {
    final items = transactions ?? filteredTransactions;
    final buf = StringBuffer();
    // Excel-friendly UTF-8 BOM
    buf.write('\uFEFF');
    buf.writeln('Ngày,Loại,Hạng mục,Danh mục,Số tiền,Ví,Ghi chú');

    for (final t in items) {
      final date = DateFormat('dd/MM/yyyy').format(t.date);
      final type = t.type == TransactionType.expense ? 'Chi tiêu' : 'Thu nhập';
      final amount = t.type == TransactionType.expense
          ? '-${_formatCsvNum(t.amount)}'
          : _formatCsvNum(t.amount);
      final note = (t.note ?? '').replaceAll('"', '""');
      final wallet = t.wallet;
      buf.writeln('$date,$type,${t.category.label},${t.title},"$amount",$wallet,"$note"');
    }

    return buf.toString();
  }

  static String _formatCsvNum(double n) {
    // Format without grouping separators, with dot as decimal
    return n.toStringAsFixed(0);
  }
}
