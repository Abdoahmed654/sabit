import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapit/core/di/injection_container.dart' as di;
import 'package:sapit/features/challenges/domain/entities/challenge.dart';
import 'package:sapit/features/challenges/presentation/bloc/challenges_bloc.dart';
import 'package:sapit/features/challenges/presentation/bloc/challenges_event.dart';
import 'package:sapit/features/challenges/presentation/bloc/challenges_state.dart';
import 'package:intl/intl.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen>
    with SingleTickerProviderStateMixin {
  late final ChallengesBloc _challengesBloc;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _challengesBloc = di.sl<ChallengesBloc>();
    _challengesBloc.add(const LoadAllChallengesEvent());
    _challengesBloc.add(const LoadUserChallengesEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _challengesBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenges'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          tabs: const [
            Tab(text: 'All Challenges'),
            Tab(text: 'My Challenges'),
          ],
        ),
      ),
      body: BlocConsumer<ChallengesBloc, ChallengesState>(
        bloc: _challengesBloc,
        listener: (context, state) {
          if (state is ChallengeJoined) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Successfully joined challenge!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ChallengesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ChallengesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ChallengesLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildAllChallengesTab(state),
                _buildMyChallengesTab(state),
              ],
            );
          }

          return const Center(child: Text('Something went wrong'));
        },
      ),
    );
  }

  Widget _buildAllChallengesTab(ChallengesLoaded state) {
    if (state.challenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No challenges available',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _challengesBloc.add(const LoadAllChallengesEvent());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.challenges.length,
        itemBuilder: (context, index) {
          final challenge = state.challenges[index];
          final isJoined = state.userChallenges
              .any((uc) => uc.challengeId == challenge.id);

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          challenge.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildChallengeStatusChip(challenge),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    challenge.description,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(
                        Icons.task,
                        '${challenge.tasks.length} tasks',
                        Colors.blue,
                      ),
                      _buildInfoChip(
                        Icons.calendar_today,
                        '${challenge.endAt.difference(challenge.startAt).inDays} days',
                        Colors.orange,
                      ),
                      _buildInfoChip(
                        Icons.star,
                        '+${challenge.rewardXp} XP',
                        Colors.amber,
                      ),
                      _buildInfoChip(
                        Icons.monetization_on,
                        '+${challenge.rewardCoins} coins',
                        Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.calendar_month, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Starts: ${DateFormat('MMM dd').format(challenge.startAt)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const Spacer(),
                      Text(
                        'Ends: ${DateFormat('MMM dd').format(challenge.endAt)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  if (!isJoined && challenge.isOngoing) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _challengesBloc
                              .add(JoinChallengeEvent(challenge.id));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Join Challenge'),
                      ),
                    ),
                  ],
                  if (isJoined)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      margin: const EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.green.shade700, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Joined',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMyChallengesTab(ChallengesLoaded state) {
    if (state.userChallenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined,
                size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'You haven\'t joined any challenges yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                _tabController.animateTo(0);
              },
              child: const Text('Browse Challenges'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _challengesBloc.add(const LoadUserChallengesEvent());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.userChallenges.length,
        itemBuilder: (context, index) {
          final progress = state.userChallenges[index];

          // Find the challenge for this progress
          Challenge? challenge;
          try {
            challenge = state.challenges.firstWhere(
              (c) => c.id == progress.challengeId,
            );
          } catch (e) {
            // Challenge not found in the list, skip this item
            return const SizedBox.shrink();
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          challenge.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildProgressStatusChip(progress),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Points Earned: ${progress.pointsEarned}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Status: ${progress.status}',
                              style: TextStyle(
                                color: progress.isCompleted
                                    ? Colors.green
                                    : progress.isInProgress
                                        ? Colors.orange
                                        : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        progress.isCompleted
                            ? Icons.check_circle
                            : progress.isInProgress
                                ? Icons.pending
                                : Icons.cancel,
                        color: progress.isCompleted
                            ? Colors.green
                            : progress.isInProgress
                                ? Colors.orange
                                : Colors.red,
                        size: 32,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${progress.pointsEarned} points earned',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const Spacer(),
                      Text(
                        'Joined: ${DateFormat('MMM dd').format(progress.createdAt)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChallengeStatusChip(challenge) {
    MaterialColor color;
    String label;

    if (challenge.isOngoing) {
      color = Colors.green;
      label = 'Active';
    } else if (challenge.isUpcoming) {
      color = Colors.blue;
      label = 'Upcoming';
    } else {
      color = Colors.grey;
      label = 'Ended';
    }

    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: color[700]),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildProgressStatusChip(progress) {
    return Chip(
      label: Text(
        progress.isCompleted ? 'Completed' : 'In Progress',
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: progress.isCompleted
          ? Colors.green.withOpacity(0.2)
          : Colors.orange.withOpacity(0.2),
      labelStyle: TextStyle(
        color: progress.isCompleted ? Colors.green.shade700 : Colors.orange.shade700,
      ),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: color.withOpacity(0.1),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

