import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../utils/constants.dart';

class PinScreen extends StatefulWidget {
  final bool isSetup;
  const PinScreen({super.key, this.isSetup = false});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  String _pin = '';
  String _confirmPin = '';
  bool _showError = false;
  String _errorMessage = '';
  bool _isConfirming = false;
  int _failedAttempts = 0;

  int _lockoutSeconds = 0;
  Timer? _lockoutTimer;

  @override
  void initState() {
    super.initState();
    if (!widget.isSetup) {
      _checkLockout();
    }
  }

  Future<void> _checkLockout() async {
    final appProvider = context.read<AppProvider>();
    final persistedFailedAttempts = await appProvider.securityService.getFailedAttempts();
    final remainingSeconds = await appProvider.securityService.getRemainingLockoutSeconds();

    if (!mounted) return;

    setState(() {
      _failedAttempts = persistedFailedAttempts;
      _lockoutSeconds = remainingSeconds;
    });

    _lockoutTimer?.cancel();
    if (_lockoutSeconds > 0) {
      _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        final seconds = await appProvider.securityService.getRemainingLockoutSeconds();
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (seconds <= 0) {
          timer.cancel();
          setState(() {
            _lockoutSeconds = 0;
            _failedAttempts = 0;
          });
          return;
        }

        setState(() => _lockoutSeconds = seconds);
      });
    }
  }

  void _onPinDigit(String digit) {
    if (_lockoutSeconds > 0) return;
    if (_pin.length < 6) {
      setState(() {
        _pin += digit;
        _showError = false;
      });
      if (_pin.length == 6) {
        if (_isConfirming) {
          _verifyConfirm();
        } else if (widget.isSetup) {
          _moveToConfirm();
        } else {
          _verifyPin();
        }
      }
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _showError = false;
      });
    }
  }

  void _moveToConfirm() {
    setState(() {
      _confirmPin = _pin;
      _isConfirming = true;
      _pin = '';
    });
  }

  void _verifyConfirm() async {
    if (_pin == _confirmPin) {
      final appProvider = context.read<AppProvider>();
      await appProvider.setPin(_pin);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } else {
      setState(() {
        _showError = true;
        _errorMessage = 'Mã PIN không khớp. Vui lòng thử lại.';
        _pin = '';
        _confirmPin = '';
        _isConfirming = false;
      });
    }
  }

  void _verifyPin() async {
    final appProvider = context.read<AppProvider>();
    final isValid = await appProvider.verifyPin(_pin);

    if (isValid) {
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } else {
      final failedAttempts = await appProvider.securityService.getFailedAttempts();
      final remainingAttempts = (5 - failedAttempts).clamp(0, 5);

      if (!mounted) return;
      setState(() {
        _showError = true;
        _pin = '';
        _failedAttempts = failedAttempts;
        _errorMessage = 'Mã PIN không đúng. Còn $remainingAttempts lần thử.';
      });

      if (failedAttempts >= 5) {
        await _checkLockout();
      }
    }
  }

  void _resetSetup() {
    setState(() {
      _pin = '';
      _confirmPin = '';
      _isConfirming = false;
      _showError = false;
    });
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.xxl),
              ),
              child: Icon(
                widget.isSetup ? Icons.lock_outline : Icons.lock,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Title
            Text(
              widget.isSetup
                  ? (_isConfirming ? 'Xác nhận mã PIN' : 'Tạo mã PIN bảo vệ')
                  : 'Nhập mã PIN',
              style: AppTypography.titleLg.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              widget.isSetup
                  ? 'Mã PIN sẽ bảo vệ dữ liệu tài chính của bạn'
                  : 'Vui lòng nhập mã PIN để mở khóa',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            // PIN Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _pin.length
                        ? AppColors.primary
                        : AppColors.outlineVariant,
                    border: Border.all(
                      color: index < _pin.length
                          ? AppColors.primary
                          : AppColors.outlineVariant,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.md),
            // Error message
            if (_showError)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  _errorMessage,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_lockoutSeconds > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  'Khóa trong $_lockoutSeconds giây',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            if (widget.isSetup && _isConfirming)
              TextButton(
                onPressed: _resetSetup,
                child: Text(
                  'Quay lại',
                  style: AppTypography.bodyMd.copyWith(color: AppColors.primary),
                ),
              ),
            const Spacer(flex: 2),
            // Number Pad
            _buildNumberPad(),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: [
          // Row 1: 1 2 3
          Row(
            children: [
              _buildDigitButton('1'),
              _buildDigitButton('2'),
              _buildDigitButton('3'),
            ],
          ),
          // Row 2: 4 5 6
          Row(
            children: [
              _buildDigitButton('4'),
              _buildDigitButton('5'),
              _buildDigitButton('6'),
            ],
          ),
          // Row 3: 7 8 9
          Row(
            children: [
              _buildDigitButton('7'),
              _buildDigitButton('8'),
              _buildDigitButton('9'),
            ],
          ),
          // Row 4: empty 0 delete
          Row(
            children: [
              const Expanded(child: SizedBox()),
              _buildDigitButton('0'),
              _buildDeleteButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDigitButton(String digit) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onPinDigit(digit),
        child: Container(
          height: 64,
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              digit,
              style: AppTypography.headlineMd.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Expanded(
      child: GestureDetector(
        onTap: _onDelete,
        child: Container(
          height: 64,
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.backspace_outlined,
              color: AppColors.onSurfaceVariant,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
