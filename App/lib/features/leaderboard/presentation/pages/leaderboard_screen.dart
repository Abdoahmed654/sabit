import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapit/features/leaderboard/presentation/bloc/leaderboard_bloc.dart';
import 'package:sapit/features/leaderboard/presentation/bloc/leaderboard_event.dart';
import 'package:sapit/features/leaderboard/presentation/bloc/leaderboard_state.dart';
import 'package:sapit/core/di/injection_container.dart' as di;

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late LeaderboardBloc _leaderboardBloc;

  @override
  void initState() {
    super.initState();
    _leaderboardBloc = di.sl<LeaderboardBloc>();
    _leaderboardBloc.add(const LoadXpLeaderboardEvent());
  }

  @override
  void dispose() {
    _leaderboardBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: BlocProvider.value(
        value: _leaderboardBloc,
        child: BlocBuilder<LeaderboardBloc, LeaderboardState>(
          builder: (context, state) {
            if (state is LeaderboardLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is LeaderboardError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading leaderboard',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(state.message),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            }

            if (state is LeaderboardLoaded) {
              if (state.entries.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No entries yet',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Be the first to earn points!',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.entries.length,
                  itemBuilder: (context, index) {
                    final entry = state.entries[index];
                    final isTopThree = entry.rank <= 3;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: isTopThree ? 4 : 1,
                      color: isTopThree
                          ? _getTopThreeColor(entry.rank).withOpacity(0.1)
                          : null,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildRankBadge(entry.rank),
                            const SizedBox(width: 12),
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: entry.avatarUrl != null
                                  ? NetworkImage(entry.avatarUrl!)
                                  : null,
                              child: entry.avatarUrl == null
                                  ? Text(
                                      entry.displayName[0].toUpperCase(),
                                      style: const TextStyle(fontSize: 20),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                        title: Text(
                          entry.displayName,
                          style: TextStyle(
                            fontWeight: isTopThree ? FontWeight.bold : FontWeight.normal,
                            fontSize: isTopThree ? 16 : 14,
                          ),
                        ),
                        subtitle: Text('Level ${entry.level}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (state.type == 'xp' || state.type.startsWith('friends'))
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.bolt, size: 16, color: Colors.blue),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${entry.xp}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            if (state.type == 'coins')
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.monetization_on, size: 16, color: Colors.orange),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${entry.coins}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
              );
            }

            return const Center(child: Text('Select a leaderboard'));
          },
        ),
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    Color color;
    IconData? icon;

    if (rank == 1) {
      color = Colors.amber;
      icon = Icons.emoji_events;
    } else if (rank == 2) {
      color = Colors.grey[400]!;
      icon = Icons.emoji_events;
    } else if (rank == 3) {
      color = Colors.brown[300]!;
      icon = Icons.emoji_events;
    } else {
      color = Colors.grey[300]!;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: icon != null
            ? Icon(icon, size: 18, color: Colors.white)
            : Text(
                '$rank',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Color _getTopThreeColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Colors.transparent;
    }
  }
}

