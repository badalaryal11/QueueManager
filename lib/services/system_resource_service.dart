import 'dart:async';
import 'package:flutter/services.dart';

class SystemResources {
  final double cpuUsage; // Percentage 0-100
  final double ramUsage; // Percentage 0-100
  final double temperature; // Celsius

  SystemResources({
    required this.cpuUsage, 
    required this.ramUsage,
    required this.temperature,
  });

  @override
  String toString() => 'CPU: ${cpuUsage.toStringAsFixed(1)}%, RAM: ${ramUsage.toStringAsFixed(1)}%, Temp: ${temperature.toStringAsFixed(1)}C';
}

class SystemResourceService {
  static const EventChannel _channel = EventChannel('com.example.queue_manager/resources');

  Stream<SystemResources>? _resourceStream;

  Stream<SystemResources> get resourceStream {
    _resourceStream ??= _channel.receiveBroadcastStream().map((event) {
      if (event is Map) {
        final cpu = (event['cpu'] as num?)?.toDouble() ?? 0.0;
        final ram = (event['ram'] as num?)?.toDouble() ?? 0.0;
        final temp = (event['temp'] as num?)?.toDouble() ?? 0.0;
        return SystemResources(cpuUsage: cpu, ramUsage: ram, temperature: temp);
      }
      return SystemResources(cpuUsage: 0.0, ramUsage: 0.0, temperature: 0.0);
    });
    return _resourceStream!;
  }
}
