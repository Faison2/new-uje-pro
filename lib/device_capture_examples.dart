/// Device Capture Integration Examples
///
/// This file provides practical code examples for integrating device
/// information capture into your voting application.

import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

// ────────────────────────────────────────────────────────────���────
// EXAMPLE 1: Simple Device Info Capture
// ─────────────────────────────────────────────────────────────────

Future<Map<String, dynamic>> captureDeviceInfo() async {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  Map<String, dynamic> data = {};

  try {
    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      data = {
        'platform': 'Android',
        'device_id': androidInfo.id,
        'model': androidInfo.model,
        'manufacturer': androidInfo.manufacturer,
        'os_version': androidInfo.version.release,
      };
    } else if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      data = {
        'platform': 'iOS',
        'device_id': iosInfo.identifierForVendor,
        'model': iosInfo.model,
        'os_version': iosInfo.systemVersion,
      };
    }
  } catch (e) {
    print('Error capturing device info: $e');
  }

  return data;
}

// ──────────────────────────────────────────────��──────────────────
// EXAMPLE 2: Vote with Device Info
// ─────────────────────────────────────────────────────────────────

Future<void> submitVoteWithDeviceInfo(
  String cdsNumber,
  String resolutionNumber,
  String voteType,
) async {
  try {
    // Capture device info
    final deviceInfo = await captureDeviceInfo();

    // Prepare vote data
    final voteData = {
      'CDSNo': cdsNumber,
      'ResolutionNumber': resolutionNumber,
      'Vote': voteType,
      // Device information
      'DeviceId': deviceInfo['device_id'],
      'DevicePlatform': deviceInfo['platform'],
      'DeviceModel': deviceInfo['model'],
      'DeviceManufacturer': deviceInfo['manufacturer'] ?? 'N/A',
      'OSVersion': deviceInfo['os_version'],
      'VoteTimestamp': DateTime.now().toIso8601String(),
    };

    // Send to API
    print('Sending vote with device info: $voteData');
    // await http.post(Uri.parse("$baseApiUrl/SubmitVote"), body: voteData);
  } catch (e) {
    print('Error submitting vote: $e');
  }
}

// ─────────────────────────────────────────────────────────────────
// EXAMPLE 3: Device Info with Error Handling
// ─────────────────────────────────────────────────────────────────

class DeviceInfoCapture {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Future<String> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.id ?? 'unknown_android';
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown_ios';
      }
      return 'unknown_platform';
    } catch (e) {
      return 'error_${e.toString()}';
    }
  }

  Future<String> getDeviceModel() async {
    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        return '${androidInfo.manufacturer} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.model ?? 'Unknown iOS';
      }
      return 'Unknown Device';
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String> getPlatform() async {
    try {
      if (Platform.isAndroid) {
        return 'Android';
      } else if (Platform.isIOS) {
        return 'iOS';
      }
      return Platform.operatingSystem;
    } catch (e) {
      return 'Unknown';
    }
  }
}

// ─────────────────────────────────────────────────────────────────
// EXAMPLE 4: Voting Analytics Logger
// ─────────────────────────────────────────────────────────────────

class VotingAnalyticsLogger {
  final DeviceInfoCapture deviceCapture = DeviceInfoCapture();
  final List<Map<String, dynamic>> votingLog = [];

  Future<void> logVote({
    required String cdsNumber,
    required String resolutionNumber,
    required String voteValue,
    required String status, // 'pending', 'success', 'failed'
  }) async {
    final deviceId = await deviceCapture.getDeviceId();
    final deviceModel = await deviceCapture.getDeviceModel();
    final platform = await deviceCapture.getPlatform();

    final logEntry = {
      'timestamp': DateTime.now().toIso8601String(),
      'cds_number': cdsNumber,
      'resolution_number': resolutionNumber,
      'vote_value': voteValue,
      'status': status,
      'device_id': deviceId,
      'device_model': deviceModel,
      'platform': platform,
    };

    votingLog.add(logEntry);
    print('Vote logged: $logEntry');
  }

  // Get all votes from specific device
  List<Map<String, dynamic>> getVotesFromDevice(String deviceId) {
    return votingLog.where((vote) => vote['device_id'] == deviceId).toList();
  }

  // Export logs as JSON
  String exportLogsAsJson() {
    return votingLog.map((e) => e.toString()).join('\n');
  }
}

// ─────────────────────────────────────────────────────────────────
// EXAMPLE 5: UI Widget to Display Device Info
// ─────────────────────────────────────────────────────────────────

class DeviceInfoWidget extends StatefulWidget {
  @override
  State<DeviceInfoWidget> createState() => _DeviceInfoWidgetState();
}

class _DeviceInfoWidgetState extends State<DeviceInfoWidget> {
  final DeviceInfoCapture capture = DeviceInfoCapture();
  late Future<Map<String, String>> deviceInfoFuture;

  @override
  void initState() {
    super.initState();
    deviceInfoFuture = _getDeviceInfo();
  }

  Future<Map<String, String>> _getDeviceInfo() async {
    return {
      'device_id': await capture.getDeviceId(),
      'model': await capture.getDeviceModel(),
      'platform': await capture.getPlatform(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: deviceInfoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final info = snapshot.data ?? {};
        return Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Device Information',
                    style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 8),
                Text('Platform: ${info['platform'] ?? 'N/A'}'),
                Text('Model: ${info['model'] ?? 'N/A'}'),
                Text('ID: ${info['device_id'] ?? 'N/A'}'),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// EXAMPLE 6: Integration with Voting Page
// ─────────────────────────────────────────────────────────────────

class VotingPageWithDeviceCapture extends StatefulWidget {
  @override
  State<VotingPageWithDeviceCapture> createState() =>
      _VotingPageWithDeviceCaptureState();
}

class _VotingPageWithDeviceCaptureState
    extends State<VotingPageWithDeviceCapture> {
  final DeviceInfoCapture deviceCapture = DeviceInfoCapture();
  final VotingAnalyticsLogger analyticsLogger = VotingAnalyticsLogger();

  Future<void> handleVoteSubmission(
    String cdsNumber,
    String resolutionNumber,
    String voteType,
  ) async {
    try {
      // Log vote attempt
      await analyticsLogger.logVote(
        cdsNumber: cdsNumber,
        resolutionNumber: resolutionNumber,
        voteValue: voteType,
        status: 'pending',
      );

      // Get device info
      final deviceId = await deviceCapture.getDeviceId();
      final deviceModel = await deviceCapture.getDeviceModel();

      // Submit vote with device info
      await submitVoteWithDeviceInfo(cdsNumber, resolutionNumber, voteType);

      // Log success
      await analyticsLogger.logVote(
        cdsNumber: cdsNumber,
        resolutionNumber: resolutionNumber,
        voteValue: voteType,
        status: 'success',
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vote submitted successfully from $deviceModel')),
      );
    } catch (e) {
      // Log failure
      await analyticsLogger.logVote(
        cdsNumber: cdsNumber,
        resolutionNumber: resolutionNumber,
        voteValue: voteType,
        status: 'failed',
      );

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vote submission failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Voting with Device Capture')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          DeviceInfoWidget(),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => handleVoteSubmission('CDS123', 'RES001', 'YES'),
            child: Text('Submit Vote'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// USAGE SUMMARY
// ─────────────────────────────────────────────────────────────────

/*
  To use these examples in your voting pages:

  1. Import this file:
     import 'path/to/device_capture_examples.dart';

  2. Use DeviceInfoCapture for device information:
     final capture = DeviceInfoCapture();
     final deviceId = await capture.getDeviceId();

  3. Use VotingAnalyticsLogger to track votes:
     final logger = VotingAnalyticsLogger();
     await logger.logVote(...);

  4. Add DeviceInfoWidget to your UI to display device info

  5. Use the voting page example as template for your pages

  For production use:
  - Cache device info to avoid repeated calls
  - Handle errors gracefully
  - Encrypt device data in transit
  - Follow privacy regulations
  - Test thoroughly on real devices
 */

