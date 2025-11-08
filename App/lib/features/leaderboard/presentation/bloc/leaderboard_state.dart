import 'package:equatable/equatable.dart';
import 'package:sapit/features/leaderboard/domain/entities/leaderboard_entry.dart';

abstract class LeaderboardState extends Equatable {
  const LeaderboardState();

  @override
  List<Object?> get props => [];
}

class LeaderboardInitial extends LeaderboardState {
  const LeaderboardInitial();
}

class LeaderboardLoading extends LeaderboardState {
  const LeaderboardLoading();
}

class LeaderboardLoaded extends LeaderboardState {
  final List<LeaderboardEntry> entries;
  final String type; // 'xp', 'coins', or 'friends'

  const LeaderboardLoaded({
    required this.entries,
    required this.type,
  });

  @override
  List<Object?> get props => [entries, type];
}

class LeaderboardError extends LeaderboardState {
  final String message;

  const LeaderboardError(this.message);

  @override
  List<Object?> get props => [message];
}

