import 'package:equatable/equatable.dart';

class LeaderboardEntry extends Equatable {
  final String id;
  final String displayName;
  final String? avatarUrl;
  final int xp;
  final int coins;
  final int level;
  final int rank;

  const LeaderboardEntry({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    required this.xp,
    required this.coins,
    required this.level,
    required this.rank,
  });

  @override
  List<Object?> get props => [id, displayName, avatarUrl, xp, coins, level, rank];
}

