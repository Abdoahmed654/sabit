import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sapit/features/daily/domain/entities/prayer_times.dart';

class PrayerCountdownWidget extends StatefulWidget {
  final PrayerTimes prayerTimes;

  const PrayerCountdownWidget({
    super.key,
    required this.prayerTimes,
  });

  @override
  State<PrayerCountdownWidget> createState() => _PrayerCountdownWidgetState();
}

class _PrayerCountdownWidgetState extends State<PrayerCountdownWidget> {
  Timer? _timer;
  Duration? _timeRemaining;
  String? _nextPrayerName;

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateCountdown() {
    final nextPrayerTime = widget.prayerTimes.getNextPrayerTime();
    final nextPrayerName = widget.prayerTimes.getNextPrayerName();

    if (nextPrayerTime != null) {
      setState(() {
        _timeRemaining = nextPrayerTime.difference(DateTime.now());
        _nextPrayerName = nextPrayerName;
      });
    } else {
      setState(() {
        _timeRemaining = null;
        _nextPrayerName = null;
      });
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_timeRemaining == null || _nextPrayerName == null) {
      return Card(
        color: Colors.teal.shade50,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.mosque, size: 48, color: Colors.teal.shade700),
              const SizedBox(height: 12),
              Text(
                'All prayers completed for today',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.teal.shade900,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      color: Colors.teal.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mosque, size: 32, color: Colors.teal.shade700),
                const SizedBox(width: 12),
                Text(
                  'Next Prayer: $_nextPrayerName',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.teal.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _formatDuration(_timeRemaining!),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.teal.shade700,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Time remaining',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.teal.shade600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

