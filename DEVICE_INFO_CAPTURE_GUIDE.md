## Device Information Capture for Voting - Implementation Guide

This document explains how device information is now being captured during voting events in your application.

### Overview

Device information is now automatically captured and sent with every vote submission. This includes:

- **Device ID** - Unique device identifier
- **Device Platform** - Android or iOS
- **Device Model** - Manufacturer and model name
- **Device Manufacturer** - OEM manufacturer
- **OS Version** - Operating system version
- **API Level** (Android only) - Android API level
- **Is Physical Device** - Whether it's a real device or emulator
- **Vote Timestamp** - Exact time of vote submission

### What Was Changed

#### 1. **services.dart**
Added three helper functions at the top of the file:
- `getDeviceInfoForVoting()` - Retrieves comprehensive device information
- `getDeviceIdentifier()` - Gets unique device ID
- `getDeviceModel()` - Gets device model string

Updated `submitVote()` function to:
- Capture device information before sending vote
- Include device data in API request body

#### 2. **shareholder_vote_page.dart**
Added to ShareholderVotePageState class:
- `_getDeviceInfoForVoting()` - Local device info retrieval
- `_getDeviceIdentifier()` - Local device ID retrieval

Updated three voting methods:
- `handleNormalResVote()` - Normal resolution votes now include device info
- `postCandidateVote()` - Election/candidate votes now include device info

#### 3. **proxy_vote.dart**
Added to ProxyVotePageState class:
- `_getDeviceInfoForVoting()` - Local device info retrieval
- `_getDeviceIdentifier()` - Local device ID retrieval

Updated four voting methods:
- `handleNormalVote()` - Proxy normal votes include device info
- `handleElectionVote()` - Proxy election votes include device info
- `handleNormalVoteAll()` - Proxy vote-all operations include device info
- `handleElectionVoteAll()` - Proxy election vote-all operations include device info

### Device Information Captured

#### For Android:
```
- Platform: "Android"
- Device: Device codename
- Model: Device model
- Manufacturer: OEM manufacturer
- OSVersion: Android version
- ApiLevel: Android API level
- AndroidId: Unique Android ID
- isPhysicalDevice: Boolean
- timestamp: ISO8601 timestamp
```

#### For iOS:
```
- Platform: "iOS"
- Device: Device model (e.g., "iPhone 12")
- Name: Device name
- SystemVersion: iOS version
- IdentifierForVendor: Unique vendor identifier
- isPhysicalDevice: Boolean
- timestamp: ISO8601 timestamp
```

### API Request Body Changes

Every vote submission now includes these additional fields:

```json
{
  "CDSNo": "shareholder_cds",
  "ResolutionNumber": "resolution_id",
  "Vote": "vote_value",
  "DeviceId": "unique_device_id",
  "DevicePlatform": "Android|iOS",
  "DeviceModel": "Device Model",
  "DeviceManufacturer": "Manufacturer",
  "OSVersion": "OS Version",
  "VoteTimestamp": "2024-05-07T10:30:45.123456Z"
}
```

### Usage Example

When a shareholder votes on a normal resolution, the system automatically:

1. Gets current device information
2. Gets unique device identifier
3. Combines vote data with device data
4. Sends everything to the API endpoint

```dart
// Vote is submitted with device info automatically
handleNormalResVote(cdsNo, resNumber, "YES");
// Includes: DeviceId, DevicePlatform, DeviceModel, OSVersion, VoteTimestamp
```

### Backend Integration

Your backend API should expect and handle these new fields:

1. **Store device information** - Log which devices are voting
2. **Audit trail** - Track devices and timestamps for compliance
3. **Fraud detection** - Identify suspicious voting patterns
4. **Device analytics** - Understand device usage in voting

### Permissions

Ensure these permissions are set in `AndroidManifest.xml` (Android):
```xml
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
```

For iOS, no special permissions are required for device_info_plus package.

### Testing

To test device capture locally:
1. Run the app on a real device or emulator
2. Perform a vote action
3. Check network traffic (using Charles Proxy or similar) to verify device fields are sent
4. Check backend logs to confirm device data is received

### Troubleshooting

**Issue**: Device info not being captured
- Check imports are correct (device_info_plus is imported)
- Verify device_info_plus: ^12.4.0 is in pubspec.yaml
- Run `flutter pub get` to ensure dependencies are installed

**Issue**: Specific device info missing on iOS/Android
- iOS 14+ may limit access to certain device identifiers
- Emulators provide limited device information
- Test on real devices for complete data

### Future Enhancements

Consider implementing:
1. **Local logging** - Log device info locally for audit purposes
2. **Encryption** - Encrypt sensitive device info in transit
3. **Analytics dashboard** - Visualize voting patterns by device
4. **Device fingerprinting** - Create unique device profiles
5. **Compliance reporting** - Generate device audit reports

### Security Notes

- Device IDs are unique but not permanently stable on some Android devices
- Consider additional authentication mechanisms
- Protect device data in transit with HTTPS/TLS
- Comply with data privacy regulations (GDPR, etc.)
- Never store sensitive device identifiers in plain text

### Support

For issues with device_info_plus package:
- GitHub: https://github.com/fluttercommunity/plus_plugins
- Documentation: https://pub.dev/packages/device_info_plus

---

**Implementation Date**: May 7, 2026
**Package Version**: device_info_plus: ^12.4.0
**Status**: Active and Deployed

