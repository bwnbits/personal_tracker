import 'dart:async';
import 'package:flutter/material.dart';
import 'package:personal_tracker/netpulse/network_speed_service.dart';

class NetPulseScreen extends StatefulWidget {
  const NetPulseScreen({super.key});

  @override
  State<NetPulseScreen> createState() => _NetPulseScreenState();
}

class _NetPulseScreenState extends State<NetPulseScreen> {
  double down = 0;
  double up = 0;

  Timer? timer;

  final service = NetworkSpeedService();

  double lastDownload = 0;
  double lastUpload = 0;

  @override
  void initState() {
    super.initState();
    startMonitoring();
  }

  void startMonitoring() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final data = await service.getTotals();

      double currentDownload = (data['download'] ?? 0).toDouble();
      double currentUpload = (data['upload'] ?? 0).toDouble();

      setState(() {
        down = currentDownload - lastDownload;
        up = currentUpload - lastUpload;

        lastDownload = currentDownload;
        lastUpload = currentUpload;
      });
    });
  }

  String format(double bytes) {
    double kb = bytes / 1024;

    if (kb < 1024) {
      return "${kb.toStringAsFixed(0)} KB/s";
    } else {
      return "${(kb / 1024).toStringAsFixed(2)} MB/s";
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("NetPulse")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Real-Time Speed",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            Text(
              format(down),
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text("↓ ${format(down)}"),
            Text("↑ ${format(up)}"),
          ],
        ),
      ),
    );
  }
}