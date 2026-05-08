import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityService {
  static const String _pinHashKey = 'security_pin_hash';
  static const String _pinSaltKey = 'security_pin_salt';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _isLockedKey = 'is_locked';
  static const String _lockoutTimeKey = 'lockout_time';
  static const String _failedAttemptsKey = 'failed_attempts';
  static const int _maxFailedAttempts = 5;
  static const int _lockoutDurationMinutes = 5;

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Encode(bytes);
  }

  String _hashPin(String pin, String salt) {
    final bytes = utf8.encode(pin + salt);
    return sha256.convert(bytes).toString();
  }

  Future<bool> isPinSet() async {
    final prefs = await _preferences;
    return prefs.containsKey(_pinHashKey);
  }

  Future<void> setPin(String pin) async {
    final prefs = await _preferences;
    final salt = _generateSalt();
    final hash = _hashPin(pin, salt);
    await prefs.setString(_pinHashKey, hash);
    await prefs.setString(_pinSaltKey, salt);
    await prefs.setBool(_isLockedKey, true);
  }

  Future<bool> verifyPin(String pin) async {
    final prefs = await _preferences;
    final hash = prefs.getString(_pinHashKey);
    final salt = prefs.getString(_pinSaltKey);

    if (hash == null || salt == null) return false;

    final isValid = _hashPin(pin, salt) == hash;

    if (!isValid) {
      await _recordFailedAttempt();
    } else {
      await _resetFailedAttempts();
      await prefs.setBool(_isLockedKey, false);
    }

    return isValid;
  }

  Future<bool> changePin(String oldPin, String newPin) async {
    final isValid = await verifyPin(oldPin);
    if (!isValid) return false;
    await setPin(newPin);
    return true;
  }

  Future<void> _recordFailedAttempt() async {
    final prefs = await _preferences;
    final attempts = (prefs.getInt(_failedAttemptsKey) ?? 0) + 1;
    await prefs.setInt(_failedAttemptsKey, attempts);

    if (attempts >= _maxFailedAttempts) {
      await prefs.setInt(
          _lockoutTimeKey, DateTime.now().millisecondsSinceEpoch);
    }
  }

  Future<void> _resetFailedAttempts() async {
    final prefs = await _preferences;
    await prefs.setInt(_failedAttemptsKey, 0);
    await prefs.remove(_lockoutTimeKey);
  }

  Future<bool> isLocked() async {
    final prefs = await _preferences;
    final lockoutTime = prefs.getInt(_lockoutTimeKey);
    if (lockoutTime == null) {
      return prefs.getBool(_isLockedKey) ?? false;
    }

    final lockoutDate = DateTime.fromMillisecondsSinceEpoch(lockoutTime);
    final now = DateTime.now();
    if (now.difference(lockoutDate).inMinutes >= _lockoutDurationMinutes) {
      await _resetFailedAttempts();
      return false;
    }
    return true;
  }

  Future<int> getFailedAttempts() async {
    final prefs = await _preferences;
    return prefs.getInt(_failedAttemptsKey) ?? 0;
  }

  Future<int> getRemainingLockoutSeconds() async {
    final prefs = await _preferences;
    final lockoutTime = prefs.getInt(_lockoutTimeKey);
    if (lockoutTime == null) return 0;

    final lockoutDate = DateTime.fromMillisecondsSinceEpoch(lockoutTime);
    final now = DateTime.now();
    final remaining =
        _lockoutDurationMinutes * 60 - now.difference(lockoutDate).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  Future<bool> isBiometricEnabled() async {
    final prefs = await _preferences;
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await _preferences;
    await prefs.setBool(_biometricEnabledKey, enabled);
  }

  Future<void> lock() async {
    final prefs = await _preferences;
    await prefs.setBool(_isLockedKey, true);
  }

  Future<void> unlock() async {
    final prefs = await _preferences;
    await prefs.setBool(_isLockedKey, false);
  }

  Future<void> clearAll() async {
    final prefs = await _preferences;
    await prefs.remove(_pinHashKey);
    await prefs.remove(_pinSaltKey);
    await prefs.remove(_biometricEnabledKey);
    await prefs.remove(_isLockedKey);
    await prefs.remove(_lockoutTimeKey);
    await prefs.remove(_failedAttemptsKey);
  }
}
