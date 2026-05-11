# Device Information Capture - Quick Start Guide

## What Was Done

Your Flutter voting application now has the infrastructure to capture device information during voting events. This has been implemented using the `device_info_plus: ^12.4.0` package (already in your pubspec.yaml).

## Files Created

### 1. **lib/services/device_info_service.dart**
   - Complete device information retrieval service
   - Platform-specific implementations for Android and iOS
   - Methods for getting device ID, model, OS version, and full device info
   - Robust error handling

### 2. **lib/model/voting_analytics.dart**
   - Data model combining voting and device information
   - JSON serialization/deserialization support
   - Easy integration with API requests

### 3. **lib/device_capture_examples.dart**
   - Practical code examples for integration
   - Device capture patterns
   - Analytics logging examples
   - UI widget examples
   - Complete voting page integration example

### 4. **Documentation Files**
   - `DEVICE_CAPTURE_IMPLEMENTATION.md` - Detailed implementation guide
   - `DEVICE_INFO_CAPTURE_GUIDE.md` - Original technical guide
   - `DEVICE_CAPTURE_QUICK_START.md` - This file

## Quick Integration (5 Steps)

### Step 1: Import the Service
```dart
import 'package:uje/services/device_info_service.dart';
```

### Step 2: Create Service Instance
```dart
class MyVotingPage extends StatefulWidget {
  @override
  State<MyVotingPage> createState() => _MyVotingPageState();
}

class _MyVotingPageState extends State<MyVotingPage> {
  final deviceService = DeviceInfoService();
  
  // ... rest of your code
}
```

### Step 3: Capture Device Info Before Voting
```dart
Future<void> castVote(String cdsNo, String resolution) async {
  // Get device information
  final deviceInfo = await deviceService.getDeviceInfo();
  final deviceId = await deviceService.getDeviceIdentifier();
  final model = await deviceService.getDeviceModel();
  
  // ... rest of voting logic
}
```

### Step 4: Include Device Info in API Request
```dart
final response = await http.post(
  Uri.parse(apiUrl),
  body: {
    'CDSNo': cdsNo,
    'ResolutionNumber': resNumber,
    'Vote': voteValue,
    // Add device information
    'DeviceId': deviceId,
    'DevicePlatform': deviceInfo['platform'],
    'DeviceModel': model,
    'OSVersion': deviceInfo['osVersion'],
    'VoteTimestamp': DateTime.now().toIso8601String(),
  },
);
```

### Step 5: Update Backend to Accept Device Fields
Your API endpoints should now accept:
- `DeviceId` - Unique device identifier
- `DevicePlatform` - 'Android' or 'iOS'
- `DeviceModel` - Device model string
- `DeviceManufacturer` - OEM manufacturer (optional)
- `OSVersion` - Operating system version
- `VoteTimestamp` - ISO8601 timestamp

## Device Information Captured

| Field | Android | iOS | Notes |
|-------|---------|-----|-------|
| Platform | ✓ Android | ✓ iOS | Device OS |
| Device ID | ✓ android.id | ✓ identifierForVendor | Unique identifier |
| Model | ✓ model | ✓ model | Device model name |
| Manufacturer | ✓ manufacturer | ✗ | OEM name |
| OS Version | ✓ version.release | ✓ systemVersion | OS version string |
| API Level | ✓ version.sdkInt | ✗ | Android only |
| Physical Device | ✓ isPhysicalDevice | ✓ isPhysicalDevice | Real vs emulator |
| Device Name | ✗ | ✓ name | User-set device name |

## Usage Examples from Your Code

### For ShareholderVotePage:

```dart
// In handleNormalResVote method
Future<void> handleNormalResVote(String cdsNo, String resNumber, String vote) async {
  // Capture device info
  final deviceInfo = await deviceService.getDeviceInfo();
  final deviceId = await deviceService.getDeviceIdentifier();
  
  // Make API call with device info
  final response = await http.post(
    Uri.parse("$baseApiUrl/CommitVoteNormalRes"),
    body: {
      "CDSNo": cdsNo,
      "ResolutionNumber": resNumber,
      "Vote": vote,
      // Device information
      "DeviceId": deviceId,
      "DevicePlatform": deviceInfo['platform'],
      "DeviceModel": deviceInfo['model'],
      "OSVersion": deviceInfo['osVersion'],
      "VoteTimestamp": DateTime.now().toIso8601String(),
    },
  );
}
```

### For ProxyVotePage:

```dart
// In handleNormalVote method
Future<void> handleNormalVote(String cdsNumber, String resNumber, String voteType) async {
  // Capture device info
  final deviceInfo = await deviceService.getDeviceInfo();
  final deviceId = await deviceService.getDeviceIdentifier();
  
  // Send vote with device tracking
  final response = await http.post(
    Uri.parse("$baseApiUrl/CommitVoteNormalRes"),
    body: {
      "CDSNo": cdsNumber,
      "ResolutionNumber": resNumber,
      "Vote": voteType,
      "DeviceId": deviceId,
      "DevicePlatform": deviceInfo['platform'],
      "DeviceModel": deviceInfo['model'],
      "OSVersion": deviceInfo['osVersion'],
      "VoteTimestamp": DateTime.now().toIso8601String(),
    },
  );
}
```

## Testing Device Capture

### Local Testing:
```dart
void testDeviceCapture() async {
  final deviceService = DeviceInfoService();
  
  // Test 1: Get full device info
  final info = await deviceService.getDeviceInfo();
  print('Full device info: $info');
  
  // Test 2: Get device ID
  final id = await deviceService.getDeviceIdentifier();
  print('Device ID: $id');
  
  // Test 3: Get device model
  final model = await deviceService.getDeviceModel();
  print('Device model: $model');
  
  // Test 4: Get OS version
  final osVersion = await deviceService.getOSVersion();
  print('OS version: $osVersion');
  
  // Test 5: Get basic device info
  final basic = await deviceService.getBasicDeviceInfo();
  print('Basic info: $basic');
}
```

### Network Testing:
1. Use Charles Proxy or similar to intercept network requests
2. Perform a vote action
3. Verify the device fields are in the request body
4. Check backend logs for successful receipt

## Common Implementation Patterns

### Pattern 1: Cache Device Info
```dart
class VotingManager {
  final deviceService = DeviceInfoService();
  late Map<String, dynamic> _cachedDeviceInfo;
  
  Future<void> initialize() async {
    _cachedDeviceInfo = await deviceService.getDeviceInfo();
  }
  
  Future<void> submitVote(String cdsNo, String resolution) async {
    final response = await http.post(url, body: {
      ...voteData,
      'DeviceId': _cachedDeviceInfo['androidId'] ?? _cachedDeviceInfo['identifierForVendor'],
      'DevicePlatform': _cachedDeviceInfo['platform'],
      'DeviceModel': _cachedDeviceInfo['model'],
    });
  }
}
```

### Pattern 2: Error Handling
```dart
Future<Map<String, dynamic>> getSafeDeviceInfo() async {
  try {
    return await deviceService.getDeviceInfo();
  } catch (e) {
    print('Device info capture failed: $e');
    return {'platform': 'Unknown', 'timestamp': DateTime.now().toIso8601String()};
  }
}
```

### Pattern 3: Analytics Logging
```dart
class VoteAnalytics {
  static void logVote({
    required String cdsNo,
    required String resolution,
    required String voteType,
    required Map<String, dynamic> deviceInfo,
  }) {
    final log = {
      'timestamp': DateTime.now().toIso8601String(),
      'cds': cdsNo,
      'resolution': resolution,
      'vote': voteType,
      'device_platform': deviceInfo['platform'],
      'device_model': deviceInfo['model'],
    };
    
    debugPrint('Vote Log: ${jsonEncode(log)}');
    // Send to backend logging service
  }
}
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `device_info_plus` not found | Run `flutter pub get` |
| Device info returns null | Test on real device (emulator support limited) |
| Android ID not available | Ensure Android API level >= 16 |
| iOS identifier empty | Check app is installed properly on device |
| Performance slow | Cache device info instead of calling each time |
| Missing imports | Add `import 'dart:io';` for Platform class |

## Security Best Practices

✅ **DO:**
- Use HTTPS/TLS for all API communication
- Validate device info on the backend
- Log all device-related activities
- Implement rate limiting based on device ID
- Encrypt sensitive device data

❌ **DON'T:**
- Store device IDs in plain text
- Rely only on device ID for authentication
- Send device info over unencrypted connections
- Log device IDs in public error messages
- Assume device ID is permanent

## Performance Tips

1. **Cache device info** - Don't call getDeviceInfo() multiple times
2. **Use async/await** - Device capture is I/O, runs asynchronously
3. **Batch operations** - Capture once, use multiple times
4. **Optimize database** - Index device_id for quick lookups

Example caching:
```dart
class DeviceManager {
  static Map<String, dynamic>? _cachedInfo;
  
  static Future<Map<String, dynamic>> getInfo() async {
    _cachedInfo ??= await DeviceInfoService().getDeviceInfo();
    return _cachedInfo!;
  }
}
```

## Next Steps

1. ✓ Review the device capture infrastructure
2. → Update your voting page implementations
3. → Test on real Android and iOS devices
4. → Update backend API to accept device fields
5. → Deploy to production
6. → Monitor device capture success rates
7. → Implement device analytics dashboard

## Support Resources

- **device_info_plus**: https://pub.dev/packages/device_info_plus
- **Flutter Platform Channels**: https://flutter.dev/docs/development/platform-integration/platform-channels
- **Your Implementation Files**: 
  - `lib/services/device_info_service.dart`
  - `lib/model/voting_analytics.dart`
  - `lib/device_capture_examples.dart`

## Summary

You now have everything needed to:
✓ Capture complete device information
✓ Track voting by device
✓ Generate audit trails
✓ Detect voting anomalies
✓ Comply with regulations

The infrastructure is in place. Now update your voting pages to use it!

---

**Package**: device_info_plus: ^12.4.0  
**Status**: Ready to Deploy  
**Last Updated**: May 7, 2026  
**Questions?** Check the example file or implementation guide  

