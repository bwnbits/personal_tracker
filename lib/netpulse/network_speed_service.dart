import 'package:flutter/services.dart';

class NetworkSpeedService {
  static const platform = MethodChannel('netpulse');

  Future<void> start() async {
    await platform.invokeMethod('startService');
  }

  Future<void> stop() async {
    await platform.invokeMethod('stopService');
  }

  Future<Map<String, dynamic>> getTotals() async {
    final result = await platform.invokeMethod('getTotals');
    return Map<String, dynamic>.from(result);
  }
}