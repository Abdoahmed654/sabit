import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapit/features/daily/domain/entities/prayer_times.dart';
import 'package:sapit/features/daily/presentation/bloc/daily_bloc.dart';
import 'package:sapit/features/daily/presentation/bloc/daily_event.dart';
import 'package:sapit/features/daily/presentation/bloc/daily_state.dart';

class PrayerTrackerWidget extends StatefulWidget {
  final PrayerTimes prayerTimes;
  final List<String> completedPrayers;
  final List<String> remainingPrayers;

  const PrayerTrackerWidget({
    super.key,
    required this.prayerTimes,
    required this.completedPrayers,
    required this.remainingPrayers,
  });

  @override
  State<PrayerTrackerWidget> createState() => _PrayerTrackerWidgetState();
}

class _PrayerTrackerWidgetState extends State<PrayerTrackerWidget> {
  Timer? _timer;
  String? _completablePrayer;
  bool _showEndOfDayReminder = false;

  @override
  void initState() {
    super.initState();
    _updateCompletablePrayer();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _updateCompletablePrayer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateCompletablePrayer() {
    final completable = widget.prayerTimes.getCurrentCompletablePrayer();
    final now = DateTime.now();
    final hour = now.hour;
    
    // Show end of day reminder after Isha (after 9 PM) if there are remaining prayers
    final showReminder = hour >= 21 && widget.remainingPrayers.isNotEmpty;
    
    setState(() {
      _completablePrayer = completable;
      _showEndOfDayReminder = showReminder;
    });
  }

  void _completePrayer(String prayerName) {
    context.read<DailyBloc>().add(CompletePrayerEvent(
      prayerName: prayerName,
      onTime: true,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DailyBloc, DailyState>(
      listener: (context, state) {
        if (state is PrayerCompleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${state.prayerName} completed! +${state.xpEarned} XP, +${state.coinsEarned} Coins',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
          // Reload prayer times
          context.read<DailyBloc>().add(const LoadTodayPrayersEvent());
        } else if (state is DailyError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Column(
        children: [
          // Completable Prayer Button (10-minute window)
          if (_completablePrayer != null &&
              !widget.completedPrayers.contains(_completablePrayer))
            Card(
              color: Colors.green.shade50,
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.alarm, color: Colors.green.shade700, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Complete $_completablePrayer Prayer',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'You have 10 minutes to mark this prayer',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _completePrayer(_completablePrayer!),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Mark as Complete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // End of Day Reminder
          if (_showEndOfDayReminder)
            Card(
              color: Colors.orange.shade50,
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Incomplete Prayers',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'You have ${widget.remainingPrayers.length} prayer(s) remaining today',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.remainingPrayers.map((prayer) {
                        return Chip(
                          label: Text(prayer),
                          backgroundColor: Colors.orange.shade100,
                          labelStyle: TextStyle(
                            color: Colors.orange.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

          // Prayer Status Summary
          Card(
            color: Colors.teal.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Today\'s Prayers',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade900,
                        ),
                      ),
                      Text(
                        '${widget.completedPrayers.length}/5',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: widget.completedPrayers.length / 5,
                    backgroundColor: Colors.teal.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.teal.shade700),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 12),
                  ...widget.prayerTimes.getAllPrayerNames().map((prayerName) {
                    final isCompleted = widget.completedPrayers.contains(prayerName);
                    final prayerTime = widget.prayerTimes.getPrayerTimeByName(prayerName);
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: isCompleted ? Colors.green : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              prayerName,
                              style: TextStyle(
                                fontSize: 14,
                                color: isCompleted ? Colors.green.shade900 : Colors.grey.shade700,
                                fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (prayerTime != null)
                            Text(
                              '${prayerTime.hour.toString().padLeft(2, '0')}:${prayerTime.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

