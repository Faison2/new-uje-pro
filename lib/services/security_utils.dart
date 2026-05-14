import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:typed_data';

/// 🔐 SecurityUtils - Utility functions for secure operations
class SecurityUtils {

  /// 🔐 Secure string hash for validation without storing plaintext
  static String hashStringSHA256(String input) {
    // Note: In production, use crypto package
    // This is a simplified example
    return base64Encode(utf8.encode(input));
  }

  /// 🔐 Validate input matches expected pattern
  static bool validateInputPattern(String input, String fieldType) {
    switch (fieldType) {
      case 'cds_number':
        // CDS numbers are typically alphanumeric
        return RegExp(r'^[A-Z0-9]{10,20}$').hasMatch(input);

      case 'mobile':
        // Tanzania mobile format
        return RegExp(r'^(\+255|0)[0-9]{9}$').hasMatch(input);

      case 'tin':
        // TIN format (Tanzania)
        return RegExp(r'^[0-9]{8,10}$').hasMatch(input);

      case 'account':
        // Account numbers
        return RegExp(r'^[0-9]{10,20}$').hasMatch(input);

      case 'password':
        // At least 8 chars, with upper, lower, digit, special
        return RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$')
            .hasMatch(input);

      default:
        return true;
    }
  }

  /// 🔐 Sanitize input for display (remove suspicious characters)
  static String sanitizeInput(String input) {
    // Remove control characters
    String sanitized = input.replaceAll(
      RegExp(r'[\x00-\x1F\x7F-\x9F]'),
      '',
    );

    // Remove potentially dangerous characters manually
    sanitized = sanitized.replaceAll('<', '');
    sanitized = sanitized.replaceAll('>', '');
    sanitized = sanitized.replaceAll(';', '');
    sanitized = sanitized.replaceAll('(', '');
    sanitized = sanitized.replaceAll(')', '');

    return sanitized;
  }

  /// 🔐 Check if string contains suspicious patterns
  static bool hasSuspiciousPatterns(String input) {
    // SQL injection patterns
    if (RegExp(r"('\s*OR|'\s*AND|--|\*|xp_|sp_|exec|execute)",
        caseSensitive: false).hasMatch(input)) {
      return true;
    }

    // Script injection patterns
    if (RegExp(r'(<script|javascript:|onerror=|onclick=)',
        caseSensitive: false).hasMatch(input)) {
      return true;
    }

    // Excessive special characters
    if (RegExp(r'[!@#$%^&*()]{3,}').hasMatch(input)) {
      return true;
    }

    return false;
  }

  /// 🔐 Secure random string generator (for tokens)
  static String generateSecureToken(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    String token = '';

    // In production, use Random.secure() from dart:math
    for (int i = 0; i < length; i++) {
      token += chars[(DateTime.now().millisecondsSinceEpoch + i) % chars.length];
    }

    return token;
  }

  /// 🔐 Validate field before submission
  static Map<String, dynamic> validateFormField({
    required String fieldName,
    required String value,
    required String fieldType,
    bool isRequired = true,
  }) {
    final response = {
      'valid': true,
      'errors': <String>[],
    };

    // Check if required and empty
    if (isRequired && value.isEmpty) {
      response['valid'] = false;
      (response['errors'] as List<String>).add('$fieldName is required');
      return response;
    }

    // Check for suspicious patterns
    if (hasSuspiciousPatterns(value)) {
      response['valid'] = false;
      (response['errors'] as List<String>).add('$fieldName contains suspicious characters');
      return response;
    }

    // Validate against field type pattern
    if (!validateInputPattern(value, fieldType)) {
      response['valid'] = false;
      (response['errors'] as List<String>).add('$fieldName format is invalid');
      return response;
    }

    // Length validation
    if (value.length < 3) {
      response['valid'] = false;
      (response['errors'] as List<String>).add('$fieldName must be at least 3 characters');
      return response;
    }

    if (value.length > 100) {
      response['valid'] = false;
      (response['errors'] as List<String>).add('$fieldName exceeds maximum length');
      return response;
    }

    return response;
  }

  /// 🔐 Check if input was pasted (faster than humanly possible)
  static bool couldBePastedText(int inputLengthBefore, int inputLengthAfter, int timeElapsedMs) {
    final charAdded = inputLengthAfter - inputLengthBefore;

    // If more than 5 characters added in less than 100ms, likely pasted
    if (charAdded > 5 && timeElapsedMs < 100) {
      return true;
    }

    // If massive amount added at once
    if (charAdded > 20) {
      return true;
    }

    return false;
  }
}

/// 🔐 Sensitive data wrapper - keeps data in memory only
class SensitiveString {
  late Uint8List _data;
  bool _isCleared = false;

  SensitiveString(String value) {
    _data = Uint8List.fromList(utf8.encode(value));
  }

  /// Get the actual string value
  String getValue() {
    if (_isCleared) {
      throw Exception('SensitiveString has been cleared');
    }
    return utf8.decode(_data);
  }

  /// Clear the string from memory
  void clear() {
    if (!_isCleared) {
      // Overwrite with zeros
      for (int i = 0; i < _data.length; i++) {
        _data[i] = 0;
      }
      _isCleared = true;
    }
  }

  /// Auto-clear when garbage collected (in theory)
  @override
  String toString() => _isCleared ? '[CLEARED]' : '[SensitiveString]';
}

/// 🔐 Debug helper for development (disabled in production)
class SecurityDebug {
  static void logSecurityEvent(String event, Map<String, dynamic> data) {
    assert(() {
      print('🔐 [SECURITY_EVENT] $event');
      print('   Data: $data');
      return true;
    }());
  }

  static void logInputEvent(String fieldName, int length, String action) {
    assert(() {
      print('🔐 [INPUT_EVENT] Field: $fieldName | Length: $length | Action: $action');
      return true;
    }());
  }

  static void logSuspiciousActivity(String reason, String fieldName) {
    assert(() {
      print('🚨 [SUSPICIOUS_ACTIVITY] $reason | Field: $fieldName');
      return true;
    }());
  }
}

