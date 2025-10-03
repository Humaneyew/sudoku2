import 'dart:io';

import 'package:flutter/services.dart';

/// Provides access to the device timezone on Android devices via a method
/// channel. Falls back to UTC when the value cannot be retrieved.
class TimezoneProvider {
  TimezoneProvider._();

  static const _channel = MethodChannel('com.sudoku.uzor/timezone');

  /// Retrieves the local timezone name.
  static Future<String> getLocalTimezone() async {
    if (!Platform.isAndroid) {
      return 'UTC';
    }

    try {
      final result = await _channel.invokeMethod<String>('getLocalTimezone');
      return result ?? 'UTC';
    } on PlatformException {
      return 'UTC';
    }
  }
}
