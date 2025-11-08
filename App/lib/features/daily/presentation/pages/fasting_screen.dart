import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapit/features/daily/presentation/bloc/good_deeds_bloc.dart';
import 'package:sapit/features/daily/presentation/bloc/good_deeds_event.dart';
import 'package:sapit/features/daily/presentation/bloc/good_deeds_state.dart';
import 'package:sapit/features/daily/domain/entities/fasting_completion.dart';
import 'package:confetti/confetti.dart';

class FastingScreen extends StatefulWidget {
  const FastingScreen({super.key});

  @override
  State<FastingScreen> createState() => _FastingScreenState();
}

class _FastingScreenState extends State<FastingScreen> {
  late ConfettiController _confettiController;
  FastingType _selectedType = FastingType.voluntary;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    context.read<GoodDeedsBloc>().add(const LoadFastingStatusEvent());
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _submitFasting() {
    final fastingTypeString = _fastingTypeToString(_selectedType);
    context.read<GoodDeedsBloc>().add(CompleteFastingEvent(fastingTypeString));
  }

  String _fastingTypeToString(FastingType type) {
    switch (type) {
      case FastingType.voluntary:
        return 'VOLUNTARY';
      case FastingType.monday:
        return 'MONDAY';
      case FastingType.thursday:
        return 'THURSDAY';
      case FastingType.whiteDays:
        return 'WHITE_DAYS';
      case FastingType.arafah:
        return 'ARAFAH';
      case FastingType.ashura:
        return 'ASHURA';
      case FastingType.shawwal:
        return 'SHAWWAL';
    }
  }

  String _fastingTypeLabel(FastingType type) {
    switch (type) {
      case FastingType.voluntary:
        return 'Voluntary Fasting';
      case FastingType.monday:
        return 'Monday Fasting';
      case FastingType.thursday:
        return 'Thursday Fasting';
      case FastingType.whiteDays:
        return 'White Days (13, 14, 15)';
      case FastingType.arafah:
        return 'Day of Arafah';
      case FastingType.ashura:
        return 'Day of Ashura';
      case FastingType.shawwal:
        return 'Six Days of Shawwal';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fasting'),
        backgroundColor: const Color(0xFF6A11CB),
      ),
      body: BlocConsumer<GoodDeedsBloc, GoodDeedsState>(
        listener: (context, state) {
          if (state is FastingCompleted) {
            _confettiController.play();
            _showRewardDialog(state.xpEarned, state.coinsEarned);
          } else if (state is GoodDeedsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is GoodDeedsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FastingStatusLoaded) {
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Card
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.nightlight_round,
                                size: 64,
                                color: Colors.white,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Record Your Fasting',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Submit between Maghrib and Fajr',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Status Message
                      if (state.status.completedToday)
                        Card(
                          color: Colors.green.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 32,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    state.status.message ??
                                        'You have already recorded fasting today!',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (!state.status.canSubmit)
                        Card(
                          color: Colors.orange.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  color: Colors.orange,
                                  size: 32,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    state.status.message ??
                                        'You can only submit fasting between Maghrib (6 PM) and Fajr (5 AM)',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Fasting Type Selection
                      if (!state.status.completedToday) ...[
                        const Text(
                          'Select Fasting Type:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        ...FastingType.values.map((type) {
                          return RadioListTile<FastingType>(
                            title: Text(_fastingTypeLabel(type)),
                            value: type,
                            groupValue: _selectedType,
                            onChanged: (value) {
                              setState(() {
                                _selectedType = value!;
                              });
                            },
                            activeColor: const Color(0xFF6A11CB),
                          );
                        }),

                        const SizedBox(height: 24),

                        // Submit Button
                        ElevatedButton(
                          onPressed: state.status.canSubmit ? _submitFasting : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6A11CB),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: const Text(
                            'SUBMIT FASTING',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Rewards Info
                        Card(
                          color: Colors.amber.shade50,
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 24),
                                SizedBox(width: 8),
                                Text(
                                  '100 XP',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Icon(Icons.monetization_on,
                                    color: Colors.orange, size: 24),
                                SizedBox(width: 8),
                                Text(
                                  '50 Coins',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Confetti
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    particleDrag: 0.05,
                    emissionFrequency: 0.05,
                    numberOfParticles: 50,
                    gravity: 0.1,
                    shouldLoop: false,
                    colors: const [
                      Colors.green,
                      Colors.blue,
                      Colors.pink,
                      Colors.orange,
                      Colors.purple,
                    ],
                  ),
                ),
              ],
            );
          }

          return const Center(
            child: Text('Pull to refresh'),
          );
        },
      ),
    );
  }

  void _showRewardDialog(int xp, int coins) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.amber, size: 32),
            SizedBox(width: 12),
            Text('Congratulations!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your fasting has been recorded!',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRewardItem(Icons.star, '$xp XP', Colors.amber),
                _buildRewardItem(Icons.monetization_on, '$coins Coins', Colors.orange),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to good deeds screen
            },
            child: const Text('DONE'),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        Icon(icon, size: 48, color: color),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

