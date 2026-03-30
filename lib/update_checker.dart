import 'package:flutter/services.dart';

class UpdateChecker {
  static const platform = MethodChannel('app_update_manager');

  Future<void> checkForUpdates() async {
    try {
      final result = await platform.invokeMethod('checkForUpdate');
      print(result); // Handle the result as needed
    } on PlatformException catch (e) {
      print("Failed to check for updates: '${e.message}'.");
    }
  }
}