import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapit/core/di/injection_container.dart' as di;
import 'package:sapit/features/daily/presentation/bloc/good_deeds_bloc.dart';
import 'package:sapit/features/daily/presentation/bloc/good_deeds_event.dart';
import 'package:sapit/features/daily/presentation/bloc/good_deeds_state.dart';
import 'package:sapit/features/daily/domain/entities/azkar_group.dart';
import 'package:sapit/features/daily/presentation/pages/azkar_group_detail_screen.dart';

class GoodDeedsScreen extends StatefulWidget {
  const GoodDeedsScreen({super.key});

  @override
  State<GoodDeedsScreen> createState() =>
      _GoodDeedsRedesignedScreenState();
}

class _GoodDeedsRedesignedScreenState extends State<GoodDeedsScreen> {
  late final GoodDeedsBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = di.sl<GoodDeedsBloc>();
    _bloc.add(const LoadAzkarGroupsEvent());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Good Deeds'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: BlocConsumer<GoodDeedsBloc, GoodDeedsState>(
        bloc: _bloc,
        listener: (context, state) {
          if (state is GoodDeedsError) {
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

          if (state is AzkarGroupsLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                _bloc.add(const LoadAzkarGroupsEvent());
                _bloc.add(const LoadFastingStatusEvent());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Header
                  const Text(
                    'Complete your daily good deeds',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Earn XP and coins by completing Azkar and fasting',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Azkar Groups Grid
                  ...state.groups.map((group) => _buildAzkarGroupCard(
                        context,
                        group,
                        state.completions,
                      )),
                ],
              ),
            );
          }

          return const Center(
            child: Text('Pull to refresh'),
          );
        },
      ),
    );
  }

  Widget _buildAzkarGroupCard(
    BuildContext context,
    AzkarGroup group,
    List completions,
  ) {
    // Count completed azkars in this group
    final completedCount = completions
        .where((c) => group.azkars.any((a) => a.id == c.azkarId))
        .length;
    final totalCount = group.azkars.length;
    final isCompleted = completedCount == totalCount && totalCount > 0;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: _bloc,
                child: AzkarGroupDetailScreen(group: group),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getCategoryColor(group.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  group.icon ?? _getCategoryIcon(group.category),
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      group.nameAr,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: 'Arabic',
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Progress bar
                    LinearProgressIndicator(
                      value: totalCount > 0 ? completedCount / totalCount : 0,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getCategoryColor(group.category),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completedCount / $totalCount completed',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Status icon
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
        ),
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

