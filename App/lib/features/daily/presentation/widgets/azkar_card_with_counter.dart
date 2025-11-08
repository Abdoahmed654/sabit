import 'package:flutter/material.dart';
import 'package:sapit/features/daily/domain/entities/azkar.dart';

class AzkarCardWithCounter extends StatefulWidget {
  final Azkar azkar;
  final bool isCompleted;
  final VoidCallback onComplete;

  const AzkarCardWithCounter({
    super.key,
    required this.azkar,
    required this.isCompleted,
    required this.onComplete,
  });

  @override
  State<AzkarCardWithCounter> createState() => _AzkarCardWithCounterState();
}

class _AzkarCardWithCounterState extends State<AzkarCardWithCounter>
    with SingleTickerProviderStateMixin {
  int _currentCount = 0;
  bool _showDetails = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    if (_currentCount < widget.azkar.targetCount && !widget.isCompleted) {
      setState(() {
        _currentCount++;
      });
      _animationController.forward().then((_) {
        _animationController.reverse();
      });

      // Auto-complete when target reached
      if (_currentCount >= widget.azkar.targetCount) {
        Future.delayed(const Duration(milliseconds: 500), () {
          widget.onComplete();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = widget.isCompleted || _currentCount >= widget.azkar.targetCount;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isComplete ? Colors.grey[100] : Colors.white,
      child: Column(
        children: [
          // Main Card Content
          InkWell(
            onTap: () {
              setState(() {
                _showDetails = !_showDetails;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.azkar.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                decoration: isComplete ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.azkar.titleAr,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontFamily: 'Arabic',
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isComplete)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 24,
                        )
                      else
                        Icon(
                          _showDetails ? Icons.expand_less : Icons.expand_more,
                          color: Colors.grey[600],
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Rewards
                  Row(
                    children: [
                      _buildRewardChip(Icons.star, '${widget.azkar.xpReward} XP', Colors.amber),
                      const SizedBox(width: 8),
                      _buildRewardChip(Icons.monetization_on, '${widget.azkar.coinsReward} Coins', Colors.orange),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expanded Details with Counter
          if (_showDetails && !isComplete)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Arabic Text
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.azkar.arabicText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'Arabic',
                        height: 1.8,
                      ),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Translation
                  Text(
                    widget.azkar.translation,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Counter
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.teal.shade400, Colors.teal.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$_currentCount',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '/ ${widget.azkar.targetCount}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tap Button
                  ElevatedButton(
                    onPressed: _incrementCounter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'TAP TO COUNT',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Completed Message
          if (_showDetails && isComplete)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Completed for today!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRewardChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

