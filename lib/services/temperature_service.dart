
import 'dart:async';
import 'package:flutter/services.dart';

class TemperatureService {
  static const EventChannel _channel = EventChannel('com.example.queue_manager/sensor');

  Stream<double>? _temperatureStream;

  Stream<double> get temperatureStream {
    _temperatureStream ??= _channel.receiveBroadcastStream().map((event) {
      if (event is double) {
        return event;
      } else if (event is int) {
        return event.toDouble();
      }
      return 0.0;
    });
    return _temperatureStream!;
  }
}
