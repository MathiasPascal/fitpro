import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  runApp(const MaterialApp(home: AccelerationDistance()));
}

class AccelerationDistance extends StatefulWidget {
  const AccelerationDistance({super.key});

  @override
  State<AccelerationDistance> createState() => _AccelerationDistanceState();
}

class _AccelerationDistanceState extends State<AccelerationDistance> {
  StreamSubscription<UserAccelerometerEvent>? _subscription;

  double _velocity = 0.0; // m/s
  double _distance = 0.0; // meters
  DateTime? _lastTimestamp;

  bool _isTracking = false;

  void _startTracking() {
    print("Tracking started");
    _velocity = 0.0;
    _distance = 0.0;
    _lastTimestamp = DateTime.now();
    _isTracking = true;

    _subscription = userAccelerometerEventStream().listen((event) {
      if (!_isTracking) {
        print("Tracking is off");
        return;
      }

      final now = DateTime.now();
      final dt =
          _lastTimestamp == null
              ? 0.0
              : now.difference(_lastTimestamp!).inMilliseconds / 1000.0;

      _lastTimestamp = now;

      double acceleration = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );
      double netAccel = (acceleration - 1.0).clamp(-10.0, 10.0);

      double deltaDistance = _velocity * dt + 0.5 * netAccel * dt * dt;
      _velocity += netAccel * dt;
      _distance += deltaDistance;

      print("Accel: ${event.x}, ${event.y}, ${event.z}");
      print("Distance: $_distance");

      setState(() {});
    });
  }

  void _stopTracking() {
    _subscription?.cancel();
    _subscription = null;
    _isTracking = false;
    _velocity = 0.0;
    _lastTimestamp = null;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Distance from Acceleration"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Distance Traveled:",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Text(
                "${_distance.toStringAsFixed(2)} meters",
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isTracking ? _stopTracking : _startTracking,
                child: Text(_isTracking ? "Stop Tracking" : "Start Tracking"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
