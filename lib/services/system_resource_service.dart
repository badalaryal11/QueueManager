import 'dart:async';
import 'package:flutter/services.dart';

class SystemResources {
  final double cpuUsage; // Percentage 0-100
  final double ramUsage; // Percentage 0-100

  SystemResources({required this.cpuUsage, required this.ramUsage});

  @override
  String toString() => 'CPU: ${cpuUsage.toStringAsFixed(1)}%, RAM: ${ramUsage.toStringAsFixed(1)}%';
}

class SystemResourceService {
  static const EventChannel _channel = EventChannel('com.example.queue_manager/resources');

  Stream<SystemResources>? _resourceStream;

  Stream<SystemResources> get resourceStream {
    _resourceStream ??= _channel.receiveBroadcastStream().map((event) {
      if (event is Map) {
        final cpu = (event['cpu'] as num?)?.toDouble() ?? 0.0;
        final ram = (event['ram'] as num?)?.toDouble() ?? 0.0;
        return SystemResources(cpuUsage: cpu, ramUsage: ram);
      }
      return SystemResources(cpuUsage: 0.0, ramUsage: 0.0);
    });
    return _resourceStream!;
  }
}
