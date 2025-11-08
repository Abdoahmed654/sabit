import 'package:equatable/equatable.dart';

abstract class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadXpLeaderboardEvent extends LeaderboardEvent {
  final int limit;

  const LoadXpLeaderboardEvent({this.limit = 100});

  @override
  List<Object?> get props => [limit];
}

class LoadCoinsLeaderboardEvent extends LeaderboardEvent {
  final int limit;

  const LoadCoinsLeaderboardEvent({this.limit = 100});

  @override
  List<Object?> get props => [limit];
}

class LoadFriendsLeaderboardEvent extends LeaderboardEvent {
  final String type;

  const LoadFriendsLeaderboardEvent({this.type = 'xp'});

  @override
  List<Object?> get props => [type];
}

