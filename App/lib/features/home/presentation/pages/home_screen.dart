import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapit/core/di/injection_container.dart' as di;
import 'package:sapit/features/auth/presentation/state/auth_bloc.dart';
import 'package:sapit/features/auth/presentation/state/auth_state.dart';
import 'package:sapit/features/daily/presentation/bloc/daily_bloc.dart';
import 'package:sapit/features/daily/presentation/bloc/daily_event.dart';
import 'package:sapit/features/daily/presentation/bloc/daily_state.dart';
import 'package:sapit/features/daily/presentation/widgets/daily_quote_widget.dart';
import 'package:sapit/features/daily/presentation/widgets/prayer_countdown_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final DailyBloc _dailyBloc;

  @override
  void initState() {
    super.initState();
    _dailyBloc = di.sl<DailyBloc>();
    _loadDailyData();
  }

  void _loadDailyData() {
    _dailyBloc.add(const LoadDailyQuoteEvent());

    _dailyBloc.add(const LoadPrayerTimesEvent(
      latitude: 30.0444, 
      longitude: 31.2357,
    ));
  }

  @override
  void dispose() {
    _dailyBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoggedOut) {
          Navigator.pushReplacementNamed(context, '/');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sabit'),
          automaticallyImplyLeading: false,
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthSuccess) {
              final user = state.user;
              return RefreshIndicator(
                onRefresh: () async {
                  _loadDailyData();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Card with Stats
                      Card(
                        elevation: 2,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor.withOpacity(0.1),
                                Theme.of(context).primaryColor.withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Greeting
                              Text(
                                'As-salamu alaykum,',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.grey[700],
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.displayName,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                              ),
                              const SizedBox(height: 20),
                              // Stats Grid
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem(
                                    context,
                                    Icons.local_fire_department,
                                    'Streak',
                                    '0', // TODO: Calculate from daily actions
                                    Colors.orange,
                                  ),
                                  _buildStatItem(
                                    context,
                                    Icons.star,
                                    'XP',
                                    user.xp.toString(),
                                    Colors.amber,
                                  ),
                                  _buildStatItem(
                                    context,
                                    Icons.monetization_on,
                                    'Coins',
                                    user.coins.toString(),
                                    Colors.green,
                                  ),
                                  _buildStatItem(
                                    context,
                                    Icons.emoji_events,
                                    'Level',
                                    user.level.toString(),
                                    Colors.purple,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Prayer Countdown
                      BlocBuilder<DailyBloc, DailyState>(
                        bloc: _dailyBloc,
                        builder: (context, dailyState) {
                          if (dailyState is DailyLoaded &&
                              dailyState.prayerTimes != null) {
                            return Column(
                              children: [
                                PrayerCountdownWidget(
                                  prayerTimes: dailyState.prayerTimes!,
                                ),
                                const SizedBox(height: 16),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      // Daily Quote
                      BlocBuilder<DailyBloc, DailyState>(
                        bloc: _dailyBloc,
                        builder: (context, dailyState) {
                          if (dailyState is DailyLoaded &&
                              dailyState.quote != null) {
                            return Column(
                              children: [
                                DailyQuoteWidget(quote: dailyState.quote!),
                                const SizedBox(height: 16),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      // Today's Tasks from Challenges
                      Text(
                        'Today\'s Tasks',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}

