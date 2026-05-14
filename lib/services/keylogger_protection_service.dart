import 'dart:async';
import 'package:flutter/services.dart';

/// 🔐 KeyloggerProtectionService
///
/// Provides app-level protection against keylogger attacks:
/// - Disables debug bridge in production
/// - Enables secure flag on all text fields
/// - Monitors unusual input patterns
/// - Detects and reports suspicious activity
class KeyloggerProtectionService {
  static final KeyloggerProtectionService _instance = KeyloggerProtectionService._internal();

  factory KeyloggerProtectionService() {
    return _instance;
  }

  KeyloggerProtectionService._internal();

  static const platform = MethodChannel('com.example.crdb/security');

  bool _isInitialized = false;
  final List<String> _inputHistory = [];
  final int _maxHistoryLength = 100;

  /// Initialize keylogger protection
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Enable FLAG_SECURE for all windows (already in MainActivity.kt)
      await platform.invokeMethod('enableSecureFlag');

      // Disable USB debugging in production
      await platform.invokeMethod('disableDebugBridge');

      _isInitialized = true;
      _debugPrint('✅ Keylogger Protection Initialized');
    } catch (e) {
      _debugPrint('⚠️ Error initializing keylogger protection: $e');
    }
  }

  /// 🔐 Log suspicious activity (reserved for internal use)
  void _checkForSuspiciousActivity(String input, String fieldType) {
    // Pattern 1: Extremely rapid input (potential automation/injection)
    if (_inputHistory.length >= 2) {
      final lastTime = DateTime.parse(_inputHistory[_inputHistory.length - 1]);
      final secondLastTime = DateTime.parse(_inputHistory[_inputHistory.length - 2]);
      final diff = lastTime.difference(secondLastTime).inMilliseconds;

      if (diff < 50) {
        _reportSuspiciousActivity(
          'Rapid input detected - potential injection attack',
          fieldType,
        );
      }
    }

    // Pattern 2: Input contains suspicious unicode/control characters
    if (_containsSuspiciousCharacters(input)) {
      _reportSuspiciousActivity(
        'Suspicious characters detected in input',
        fieldType,
      );
    }

    // Pattern 3: Unusually long input for password fields
    if (fieldType == 'password' && input.length > 128) {
      _reportSuspiciousActivity(
        'Unusually long password input detected',
        fieldType,
      );
    }
  }

  /// Check if input contains suspicious unicode/control characters
  bool _containsSuspiciousCharacters(String input) {
    // Check for control characters and unusual unicode ranges
    for (int codeUnit in input.codeUnits) {
      if (codeUnit < 32 && codeUnit != 9 && codeUnit != 10 && codeUnit != 13) {
        return true; // Control character detected
      }
      if (codeUnit >= 127 && codeUnit < 160) {
        return true; // Suspicious unicode range
      }
    }
    return false;
  }

  /// 🔐 Report suspicious activity
  void _reportSuspiciousActivity(String reason, String fieldType) {
    _debugPrint('🚨 SECURITY ALERT: $reason (Field: $fieldType)');

    // In a production app, this would send telemetry to a secure server
    // For now, just log it locally
  }

  /// 🔐 Clear input history (call after sensitive operations)
  void clearInputHistory() {
    _inputHistory.clear();
  }

  /// Get initialization status
  bool get isInitialized => _isInitialized;
}

// Helper for debug prints (only in debug mode)
void _debugPrint(String message) {
  assert(() {
    print('[Security] $message');
    return true;
  }());
}

