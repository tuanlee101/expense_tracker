import 'package:flutter/foundation.dart';
import '../models/bill_model.dart';
import '../services/data_service.dart';

class BillProvider extends ChangeNotifier {
  final DataService _dataService = DataService();

  List<BillModel> _bills = [];
  bool _isLoading = false;

  List<BillModel> get bills => _bills;
  bool get isLoading => _isLoading;

  double get totalMonthlyBills => _dataService.getTotalMonthlyBills(_bills);

  List<BillModel> get upcomingBills => _dataService.getUpcomingBills(_bills);
  List<BillModel> get overdueBills => _dataService.getOverdueBills(_bills);
  List<BillModel> get paidThisMonth => _bills.where((b) => b.isPaid).toList();

  int get paidCount => _bills.where((b) => b.isPaid).length;
  int get unpaidCount => _bills.where((b) => !b.isPaid).length;

  Future<void> loadBills() async {
    _isLoading = true;
    notifyListeners();

    _bills = await _dataService.getBills();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addBill(BillModel bill) async {
    _bills.add(bill);
    await _dataService.saveBills(_bills);
    notifyListeners();
  }

  Future<void> updateBill(BillModel bill) async {
    final index = _bills.indexWhere((b) => b.id == bill.id);
    if (index != -1) {
      _bills[index] = bill;
      await _dataService.saveBills(_bills);
      notifyListeners();
    }
  }

  Future<void> deleteBill(String id) async {
    _bills.removeWhere((b) => b.id == id);
    await _dataService.saveBills(_bills);
    notifyListeners();
  }

  Future<void> markBillPaid(String id, bool isPaid) async {
    await _dataService.markBillPaid(id, isPaid);
    final index = _bills.indexWhere((b) => b.id == id);
    if (index != -1) {
      _bills[index] = _bills[index].copyWith(isPaid: isPaid);
      notifyListeners();
    }
  }

  List<BillModel> getBillsByCategory(BillCategory category) {
    return _bills.where((b) => b.category == category).toList();
  }
}