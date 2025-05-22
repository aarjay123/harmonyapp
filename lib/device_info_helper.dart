import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io' show Platform;

class DeviceInfoHelper {
  static Future<bool> supportsDynamicColor() async {
    if (kIsWeb) return false;

    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.sdkInt >= 31; // Android 12 = SDK 31
    }

    return false; // other platforms no dynamic color support
  }
}