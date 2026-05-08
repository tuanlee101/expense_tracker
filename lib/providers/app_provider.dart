import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/data_service.dart';
import '../services/security_service.dart';

class AppProvider extends ChangeNotifier {
  final DataService _dataService = DataService();
  final SecurityService _securityService = SecurityService();

  UserModel _user = UserModel();
  bool _isDarkMode = false;
  bool _isAuthenticated = false;
  bool _isPinSetup = false;
  bool _isBiometricEnabled = false;
  int _currentTabIndex = 0;

  UserModel get user => _user;
  bool get isDarkMode => _isDarkMode;
  bool get isAuthenticated => _isAuthenticated;
  bool get isPinSetup => _isPinSetup;
  bool get isBiometricEnabled => _isBiometricEnabled;
  int get currentTabIndex => _currentTabIndex;
  SecurityService get securityService => _securityService;

  Future<void> initialize() async {
    _isPinSetup = await _securityService.isPinSet();
    _isBiometricEnabled = await _securityService.isBiometricEnabled();
    _user = await _dataService.getUserData();
    notifyListeners();
  }

  Future<void> setPin(String pin) async {
    await _securityService.setPin(pin);
    _isPinSetup = true;
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<bool> verifyPin(String pin) async {
    final isValid = await _securityService.verifyPin(pin);
    if (isValid) {
      _isAuthenticated = true;
      notifyListeners();
    }
    return isValid;
  }

  Future<bool> changePin(String oldPin, String newPin) async {
    final success = await _securityService.changePin(oldPin, newPin);
    if (success) {
      notifyListeners();
    }
    return success;
  }

  Future<void> lock() async {
    await _securityService.lock();
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> unlock() async {
    await _securityService.unlock();
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> toggleBiometric(bool enabled) async {
    await _securityService.setBiometricEnabled(enabled);
    _isBiometricEnabled = enabled;
    notifyListeners();
  }

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  Future<void> updateUser(UserModel user) async {
    _user = user;
    await _dataService.saveUserData(user);
    notifyListeners();
  }

  Future<void> updateUserName(String name) async {
    _user = _user.copyWith(name: name);
    await _dataService.saveUserData(_user);
    notifyListeners();
  }

  Future<void> updateTotalAssets(double amount) async {
    _user = _user.copyWith(totalAssets: amount);
    await _dataService.saveUserData(_user);
    notifyListeners();
  }

  Future<void> updateMonthlyFixedCost(double amount) async {
    _user = _user.copyWith(monthlyFixedCost: amount);
    await _dataService.saveUserData(_user);
    notifyListeners();
  }

  Future<void> updateSafeBudget(double amount) async {
    _user = _user.copyWith(safeBudget: amount);
    await _dataService.saveUserData(_user);
    notifyListeners();
  }
}
