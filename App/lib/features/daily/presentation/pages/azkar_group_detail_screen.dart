import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapit/features/daily/domain/entities/azkar_group.dart';
import 'package:sapit/features/daily/domain/entities/azkar.dart';
import 'package:sapit/features/daily/presentation/bloc/good_deeds_bloc.dart';
import 'package:sapit/features/daily/presentation/bloc/good_deeds_event.dart';
import 'package:sapit/features/daily/presentation/bloc/good_deeds_state.dart';
import 'package:sapit/features/daily/presentation/pages/azkar_counter_screen.dart';

class AzkarGroupDetailScreen extends StatefulWidget {
  final AzkarGroup group;

  const AzkarGroupDetailScreen({
    super.key,
    required this.group,
  });

  @override
  State<AzkarGroupDetailScreen> createState() => _AzkarGroupDetailScreenState();
}

class _AzkarGroupDetailScreenState extends State<AzkarGroupDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load completions for this group
    context.read<GoodDeedsBloc>().add(
          LoadAzkarCompletionsEvent(groupId: widget.group.id),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        backgroundColor: _getCategoryColor(widget.group.category),
      ),
      body: BlocBuilder<GoodDeedsBloc, GoodDeedsState>(
        builder: (context, state) {
          final completions = state is AzkarCompletionsLoaded
              ? state.completions
              : state is AzkarGroupLoaded
                  ? state.completions
                  : <dynamic>[];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Group Header
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        _getCategoryColor(widget.group.category),
                        _getCategoryColor(widget.group.category).withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.group.icon ?? _getCategoryIcon(widget.group.category),
                        style: const TextStyle(fontSize: 48),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.group.nameAr,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Arabic',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (widget.group.description != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.group.description!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Azkars List
              const Text(
                'Azkars',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              ...widget.group.azkars.map((azkar) {
                final isCompleted = completions.any((c) => c.azkarId == azkar.id);
                return _buildAzkarCard(context, azkar, isCompleted);
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAzkarCard(BuildContext context, Azkar azkar, bool isCompleted) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: isCompleted
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: context.read<GoodDeedsBloc>(),
                      child: AzkarCounterScreen(azkar: azkar),
                    ),
                  ),
                );
              },
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: isCompleted ? 0.5 : 1.0,
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                            azkar.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            azkar.titleAr,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontFamily: 'Arabic',
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isCompleted)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 28,
                      )
                    else
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Rewards
                Row(
                  children: [
                    _buildRewardChip(
                      Icons.star,
                      '${azkar.xpReward} XP',
                      Colors.amber,
                    ),
                    const SizedBox(width: 8),
                    _buildRewardChip(
                      Icons.monetization_on,
                      '${azkar.coinsReward} Coins',
                      Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    if (azkar.targetCount > 1)
                      _buildRewardChip(
                        Icons.repeat,
                        '${azkar.targetCount}x',
                        Colors.blue,
                      ),
                  ],
                ),

                if (isCompleted) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Completed',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
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
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(AzkarCategory category) {
    switch (category) {
      case AzkarCategory.morning:
        return Colors.orange;
      case AzkarCategory.evening:
        return Colors.indigo;
      case AzkarCategory.afterPrayer:
        return Colors.teal;
      case AzkarCategory.beforeSleep:
        return Colors.deepPurple;
      case AzkarCategory.general:
        return Colors.blue;
    }
  }

  String _getCategoryIcon(AzkarCategory category) {
    switch (category) {
      case AzkarCategory.morning:
        return '🌅';
      case AzkarCategory.evening:
        return '🌙';
      case AzkarCategory.afterPrayer:
        return '🕌';
      case AzkarCategory.beforeSleep:
        return '😴';
      case AzkarCategory.general:
        return '📿';
    }
  }
}

