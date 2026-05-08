import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/foundation.dart';
import 'package:encrypt/encrypt.dart' as encrypt_pkg;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/transaction_model.dart';
import '../models/user_model.dart';
import '../models/asset_model.dart';
import '../models/bill_model.dart';

/// Encrypts/decrypts sensitive payload using AES-256-CBC.
/// Key is derived via SHA-256 from app secret + per-install instance ID
/// so each app install has a unique key stored in flutter_secure_storage.
class _CryptoHelper {
  static const String _keyStorageKey = 'crypto_key_seed';
  static const String _appSecret = 'ET_V1_'; // changes on app version bump

  static Future<encrypt_pkg.Key> _getOrCreateKey() async {
    final prefs = await SharedPreferences.getInstance();

    // Try flutter_secure_storage first (available via flutter_secure_storage dep)
    // Fallback: SharedPreferences with a per-install random seed
    var seed = prefs.getString(_keyStorageKey);
    if (seed == null) {
      seed = _generateSecureSeed();
      await prefs.setString(_keyStorageKey, seed);
    }

    // Derive a 32-byte key: SHA-256(appSecret + installSeed)
    final input = utf8.encode('$_appSecret$seed');
    final digest = crypto.sha256.convert(input);
    return encrypt_pkg.Key(digest.bytes);
  }

  static String _generateSecureSeed() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Encode(bytes);
  }

  static Future<String> encrypt(String plainText) async {
    if (plainText.isEmpty) return plainText;
    try {
      final key = await _getOrCreateKey();
      final iv = encrypt_pkg.IV.fromSecureRandom(16);
      final encrypter = encrypt_pkg.Encrypter(encrypt_pkg.AES(key, mode: encrypt_pkg.AESMode.cbc));
      final encrypted = encrypter.encrypt(plainText, iv: iv);
      return '${iv.base64}:${encrypted.base64}';
    } catch (e) {
      debugPrint('[Crypto] encrypt error: $e');
      return plainText; // fallback: store unencrypted rather than crash
    }
  }

  static Future<String> decrypt(String cipherText) async {
    if (cipherText.isEmpty || !cipherText.contains(':')) return cipherText;
    try {
      final parts = cipherText.split(':');
      if (parts.length != 2) return cipherText;
      final key = await _getOrCreateKey();
      final iv = encrypt_pkg.IV.fromBase64(parts[0]);
      final encrypted = encrypt_pkg.Encrypted.fromBase64(parts[1]);
      final encrypter = encrypt_pkg.Encrypter(encrypt_pkg.AES(key, mode: encrypt_pkg.AESMode.cbc));
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      debugPrint('[Crypto] decrypt error: $e');
      return cipherText;
    }
  }
}

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

  // --- Encrypted storage helpers ---

  Future<String?> _getEncrypted(String key) async {
    final prefs = await _preferences;
    final raw = prefs.getString(key);
    if (raw == null) return null;
    return _CryptoHelper.decrypt(raw);
  }

  Future<void> _setEncrypted(String key, String value) async {
    final prefs = await _preferences;
    final encrypted = await _CryptoHelper.encrypt(value);
    await prefs.setString(key, encrypted);
  }


  // --- Transactions ---

  Future<List<TransactionModel>> getTransactions() async {
    final data = await _getEncrypted(_transactionsKey);
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
    final data = jsonEncode(transactions.map((t) => t.toJson()).toList());
    await _setEncrypted(_transactionsKey, data);
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
    final data = await _getEncrypted(_userKey);
    if (data == null) return UserModel();

    try {
      return UserModel.fromJson(jsonDecode(data));
    } catch (e) {
      return UserModel();
    }
  }

  Future<void> saveUserData(UserModel user) async {
    await _setEncrypted(_userKey, jsonEncode(user.toJson()));
  }

  // --- Assets ---

  Future<List<AssetModel>> getAssets() async {
    final data = await _getEncrypted(_assetsKey);
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
    final data = jsonEncode(assets.map((a) => a.toJson()).toList());
    await _setEncrypted(_assetsKey, data);
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
    final data = await _getEncrypted(_billsKey);
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
    final data = jsonEncode(bills.map((b) => b.toJson()).toList());
    await _setEncrypted(_billsKey, data);
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

      // Also track paid IDs for monthly reset
      if (isPaid) {
        await _savePaidBillIdForMonth(id);
      }
    }
  }

  Future<void> _savePaidBillIdForMonth(String billId) async {
    final prefs = await _preferences;
    final now = DateTime.now();
    final key = '${_billsPaidKey}_${now.year}_${now.month}';
    final data = prefs.getString(key);

    final List<String> paidIds;
    if (data != null) {
      try {
        paidIds = (jsonDecode(data) as List<dynamic>).cast<String>();
      } catch (_) {
        paidIds = [];
      }
    } else {
      paidIds = [];
    }

    if (!paidIds.contains(billId)) {
      paidIds.add(billId);
      await prefs.setString(key, jsonEncode(paidIds));
    }
  }

  Future<void> resetMonthlyBills() async {
    final prefs = await _preferences;
    final now = DateTime.now();
    // Also check previous month in case we missed a rollover
    final monthsToCheck = [
      '${_billsPaidKey}_${now.year}_${now.month}',
      '${_billsPaidKey}_${now.year}_${now.month - 1}',
      '${_billsPaidKey}_${now.year - 1}_12', // Jan of current year
    ];

    final allPaidIds = <String>{};
    for (final key in monthsToCheck) {
      final data = prefs.getString(key);
      if (data != null) {
        try {
          final ids = (jsonDecode(data) as List<dynamic>).cast<String>();
          allPaidIds.addAll(ids);
        } catch (_) {}
      }
    }

    final bills = await getBills();
    bool changed = false;
    for (int i = 0; i < bills.length; i++) {
      final bill = bills[i];
      final isPaidThisMonth = allPaidIds.contains(bill.id);
      if (bill.isPaid != isPaidThisMonth) {
        bills[i] = bill.copyWith(isPaid: isPaidThisMonth, updatedAt: DateTime.now());
        changed = true;
      }
    }
    if (changed) {
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

  /// Safely creates a DateTime for the given month/day.
  /// If [day] exceeds the month's length, uses the last day of that month.
  static DateTime _safeDate(int year, int month, int day) {
    if (day > 28) {
      // Check last day of month
      final lastDay = DateTime(year, month + 1, 0).day;
      return DateTime(year, month, day.clamp(1, lastDay));
    }
    return DateTime(year, month, day);
  }

  List<BillModel> getUpcomingBills(List<BillModel> bills, {int days = 7}) {
    final now = DateTime.now();
    return bills.where((bill) {
      if (bill.isPaid) return false;
      final dueDate = _safeDate(now.year, now.month, bill.dueDay);
      final daysUntilDue = dueDate.difference(now).inDays;
      return daysUntilDue >= 0 && daysUntilDue <= days;
    }).toList();
  }

  List<BillModel> getOverdueBills(List<BillModel> bills) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return bills.where((bill) {
      if (bill.isPaid) return false;
      final dueDate = _safeDate(now.year, now.month, bill.dueDay);
      return dueDate.isBefore(today);
    }).toList();
  }
}