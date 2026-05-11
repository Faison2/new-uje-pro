import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:flutter/material.dart';

/// Service to capture and manage device information for voting analytics
class DeviceInfoService {
  static final DeviceInfoService _instance = DeviceInfoService._internal();
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  factory DeviceInfoService() {
    return _instance;
  }

  DeviceInfoService._internal();

  /// Get complete device information as a map
  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        return _getAndroidDeviceInfo();
      } else if (Platform.isIOS) {
        return _getIOSDeviceInfo();
      } else {
        return _getGenericDeviceInfo();
      }
    } catch (e) {
      debugPrint('Error getting device info: $e');
      return _getGenericDeviceInfo();
    }
  }

  /// Get Android-specific device information
  Future<Map<String, dynamic>> _getAndroidDeviceInfo() async {
    try {
      final AndroidDeviceInfo androidInfo = await _deviceInfoPlugin.androidInfo;
      return {
        'platform': 'Android',
        'device': androidInfo.device ?? 'Unknown',
        'model': androidInfo.model ?? 'Unknown',
        'manufacturer': androidInfo.manufacturer ?? 'Unknown',
        'brand': androidInfo.brand ?? 'Unknown',
        'product': androidInfo.product ?? 'Unknown',
        'osVersion': androidInfo.version.release ?? 'Unknown',
        'apiLevel': androidInfo.version.sdkInt ?? 0,
        'androidId': androidInfo.id ?? 'Unknown',
        'isPhysicalDevice': androidInfo.isPhysicalDevice,
      };
    } catch (e) {
      debugPrint('Error getting Android device info: $e');
      return {};
    }
  }

  /// Get iOS-specific device information
  Future<Map<String, dynamic>> _getIOSDeviceInfo() async {
    try {
      final IosDeviceInfo iosInfo = await _deviceInfoPlugin.iosInfo;
      return {
        'platform': 'iOS',
        'device': iosInfo.model ?? 'Unknown',
        'name': iosInfo.name ?? 'Unknown',
        'systemName': iosInfo.systemName ?? 'Unknown',
        'systemVersion': iosInfo.systemVersion ?? 'Unknown',
        'identifierForVendor': iosInfo.identifierForVendor ?? 'Unknown',
        'isPhysicalDevice': iosInfo.isPhysicalDevice,
        'localizedModel': iosInfo.localizedModel ?? 'Unknown',
        'utsname': {
          'sysname': iosInfo.utsname.sysname,
          'nodename': iosInfo.utsname.nodename,
          'release': iosInfo.utsname.release,
          'version': iosInfo.utsname.version,
          'machine': iosInfo.utsname.machine,
        },
      };
    } catch (e) {
      debugPrint('Error getting iOS device info: $e');
      return {};
    }
  }

  /// Get generic device information (fallback)
  Map<String, dynamic> _getGenericDeviceInfo() {
    return {
      'platform': Platform.operatingSystem,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Get device identifier (unique device ID)
  Future<String> getDeviceIdentifier() async {
    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo =
            await _deviceInfoPlugin.androidInfo;
        return androidInfo.id ?? 'unknown';
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await _deviceInfoPlugin.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown';
      }
      return 'unknown';
    } catch (e) {
      debugPrint('Error getting device identifier: $e');
      return 'unknown';
    }
  }

  /// Get device model name
  Future<String> getDeviceModel() async {
    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo =
            await _deviceInfoPlugin.androidInfo;
        return '${androidInfo.manufacturer} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await _deviceInfoPlugin.iosInfo;
        return iosInfo.model ?? 'Unknown iOS Device';
      }
      return 'Unknown Device';
    } catch (e) {
      debugPrint('Error getting device model: $e');
      return 'Unknown Device';
    }
  }

  /// Get OS version
  Future<String> getOSVersion() async {
    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo =
            await _deviceInfoPlugin.androidInfo;
        return androidInfo.version.release ?? 'Unknown';
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await _deviceInfoPlugin.iosInfo;
        return iosInfo.systemVersion ?? 'Unknown';
      }
      return 'Unknown';
    } catch (e) {
      debugPrint('Error getting OS version: $e');
      return 'Unknown';
    }
  }

  /// Get basic device info string for logging
  Future<String> getBasicDeviceInfo() async {
    try {
      final model = await getDeviceModel();
      final osVersion = await getOSVersion();
      return '$model | OS: $osVersion';
    } catch (e) {
      debugPrint('Error getting basic device info: $e');
      return 'Unknown Device';
    }
  }
}

