import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';
import '../models/asset_model.dart';
import '../models/bill_model.dart';

class DataService {
  static const String _transactionsKey = 'transactions';
  static const String _userKey = 'user_data';
  static const String _assetsKey = 'assets';
  static const String _billsKey = 'bills';
  static const String _billsPaidKey = 'bills_paid_month';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // --- Transactions ---

  Future<List<TransactionModel>> getTransactions() async {
    final prefs = await _preferences;
    final data = prefs.getString(_transactionsKey);
    if (data == null) return _getDefaultTransactions();

    try {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      return _getDefaultTransactions();
    }
  }

  Future<void> saveTransactions(List<TransactionModel> transactions) async {
    final prefs = await _preferences;
    final data = jsonEncode(transactions.map((t) => t.toJson()).toList());
    await prefs.setString(_transactionsKey, data);
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final transactions = await getTransactions();
    transactions.insert(0, transaction);
    await saveTransactions(transactions);
  }

  Future<void> deleteTransaction(String id) async {
    final transactions = await getTransactions();
    transactions.removeWhere((t) => t.id == id);
    await saveTransactions(transactions);
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final transactions = await getTransactions();
    final index = transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      transactions[index] = transaction;
      await saveTransactions(transactions);
    }
  }

  List<TransactionModel> _getDefaultTransactions() {
    final now = DateTime.now();
    return [
      TransactionModel(
        id: '1',
        title: 'Ăn trưa - Phở Thìn',
        amount: 65000,
        type: TransactionType.expense,
        category: TransactionCategory.food,
        date: DateTime(now.year, now.month, now.day, 12, 30),
      ),
      TransactionModel(
        id: '2',
        title: 'Grab',
        amount: 42000,
        type: TransactionType.expense,
        category: TransactionCategory.transport,
        date: DateTime(now.year, now.month, now.day, 8, 15),
      ),
      TransactionModel(
        id: '3',
        title: 'Lương tháng 10',
        amount: 15000000,
        type: TransactionType.income,
        category: TransactionCategory.salary,
        date: DateTime(now.year, now.month, now.day - 1, 17, 0),
        note: 'Công ty TechSoft',
      ),
      TransactionModel(
        id: '4',
        title: 'Siêu thị WinMart',
        amount: 210000,
        type: TransactionType.expense,
        category: TransactionCategory.shopping,
        date: DateTime(now.year, now.month, now.day - 1, 10, 30),
      ),
      TransactionModel(
        id: '5',
        title: 'Bữa trưa văn phòng',
        amount: 85000,
        type: TransactionType.expense,
        category: TransactionCategory.food,
        date: DateTime(now.year, now.month, now.day - 2, 12, 0),
      ),
      TransactionModel(
        id: '6',
        title: 'Siêu thị WinMart',
        amount: 365000,
        type: TransactionType.expense,
        category: TransactionCategory.shopping,
        date: DateTime(now.year, now.month, now.day - 2, 8, 15),
      ),
    ];
  }

  // --- User Data ---

  Future<UserModel> getUserData() async {
    final prefs = await _preferences;
    final data = prefs.getString(_userKey);
    if (data == null) return UserModel();

    try {
      return UserModel.fromJson(jsonDecode(data));
    } catch (e) {
      return UserModel();
    }
  }

  Future<void> saveUserData(UserModel user) async {
    final prefs = await _preferences;
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  // --- Assets ---

  Future<List<AssetModel>> getAssets() async {
    final prefs = await _preferences;
    final data = prefs.getString(_assetsKey);
    if (data == null) return _getDefaultAssets();

    try {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList
          .map((e) => AssetModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return _getDefaultAssets();
    }
  }

  Future<void> saveAssets(List<AssetModel> assets) async {
    final prefs = await _preferences;
    final data = jsonEncode(assets.map((a) => a.toJson()).toList());
    await prefs.setString(_assetsKey, data);
  }

  Future<void> addAsset(AssetModel asset) async {
    final assets = await getAssets();
    assets.add(asset);
    await saveAssets(assets);
  }

  Future<void> updateAsset(AssetModel asset) async {
    final assets = await getAssets();
    final index = assets.indexWhere((a) => a.id == asset.id);
    if (index != -1) {
      assets[index] = asset;
      await saveAssets(assets);
    }
  }

  Future<void> deleteAsset(String id) async {
    final assets = await getAssets();
    assets.removeWhere((a) => a.id == id);
    await saveAssets(assets);
  }

  List<AssetModel> _getDefaultAssets() {
    return [
      AssetModel(id: '1', name: 'Techcombank', balance: 850000000, type: AssetType.bankAccount),
      AssetModel(id: '2', name: 'MB Bank', balance: 250000000, type: AssetType.bankAccount),
      AssetModel(id: '3', name: 'Ví tiền mặt', balance: 15000000, type: AssetType.cash),
      AssetModel(id: '4', name: 'Thẻ Visa Techcombank', balance: -5000000, type: AssetType.creditCard),
      AssetModel(id: '5', name: 'Sổ tiết kiệm', balance: 150000000, type: AssetType.savings),
    ];
  }

  double getTotalAssets(List<AssetModel> assets) {
    return assets.fold(0.0, (sum, asset) => sum + asset.balance);
  }

  // --- Bills ---

  Future<List<BillModel>> getBills() async {
    final prefs = await _preferences;
    final data = prefs.getString(_billsKey);
    if (data == null) return _getDefaultBills();

    try {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList
          .map((e) => BillModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return _getDefaultBills();
    }
  }

  Future<void> saveBills(List<BillModel> bills) async {
    final prefs = await _preferences;
    final data = jsonEncode(bills.map((b) => b.toJson()).toList());
    await prefs.setString(_billsKey, data);
  }

  Future<void> addBill(BillModel bill) async {
    final bills = await getBills();
    bills.add(bill);
    await saveBills(bills);
  }

  Future<void> updateBill(BillModel bill) async {
    final bills = await getBills();
    final index = bills.indexWhere((b) => b.id == bill.id);
    if (index != -1) {
      bills[index] = bill;
      await saveBills(bills);
    }
  }

  Future<void> deleteBill(String id) async {
    final bills = await getBills();
    bills.removeWhere((b) => b.id == id);
    await saveBills(bills);
  }

  Future<void> markBillPaid(String id, bool isPaid) async {
    final bills = await getBills();
    final index = bills.indexWhere((b) => b.id == id);
    if (index != -1) {
      bills[index] = bills[index].copyWith(isPaid: isPaid, updatedAt: DateTime.now());
      await saveBills(bills);
    }
  }

  Future<void> resetMonthlyBills() async {
    final prefs = await _preferences;
    final now = DateTime.now();
    final key = '${_billsPaidKey}_${now.year}_${now.month}';
    final data = prefs.getString(key);
    
    if (data != null) {
      final List<dynamic> paidIds = jsonDecode(data);
      final bills = await getBills();
      for (var bill in bills) {
        if (!paidIds.contains(bill.id)) {
          final index = bills.indexWhere((b) => b.id == bill.id);
          if (index != -1) {
            bills[index] = bills[index].copyWith(isPaid: false);
          }
        }
      }
      await saveBills(bills);
    }
  }

  List<BillModel> _getDefaultBills() {
    return [
      BillModel(id: '1', name: 'Tiền điện', amount: 1200000, dueDay: 5, category: BillCategory.electricity, isPaid: false),
      BillModel(id: '2', name: 'Tiền nước', amount: 350000, dueDay: 10, category: BillCategory.water, isPaid: true),
      BillModel(id: '3', name: 'Tiền nhà', amount: 15000000, dueDay: 1, category: BillCategory.rent, isPaid: false),
      BillModel(id: '4', name: 'Internet FPT', amount: 350000, dueDay: 15, category: BillCategory.internet, isPaid: true),
      BillModel(id: '5', name: 'Netflix', amount: 268000, dueDay: 20, category: BillCategory.subscription, isPaid: false),
      BillModel(id: '6', name: 'Trả góp xe', amount: 8500000, dueDay: 25, category: BillCategory.installment, isPaid: false),
    ];
  }

  double getTotalMonthlyBills(List<BillModel> bills) {
    return bills.fold(0.0, (sum, bill) => sum + bill.amount);
  }

  List<BillModel> getUpcomingBills(List<BillModel> bills, {int days = 7}) {
    final now = DateTime.now();
    return bills.where((bill) {
      if (bill.isPaid) return false;
      final dueDate = DateTime(now.year, now.month, bill.dueDay);
      final daysUntilDue = dueDate.difference(now).inDays;
      return daysUntilDue >= 0 && daysUntilDue <= days;
    }).toList();
  }

  List<BillModel> getOverdueBills(List<BillModel> bills) {
    final now = DateTime.now();
    return bills.where((bill) {
      if (bill.isPaid) return false;
      final dueDate = DateTime(now.year, now.month, bill.dueDay);
      return dueDate.isBefore(DateTime(now.year, now.month, now.day));
    }).toList();
  }
}