import 'package:sapit/features/leaderboard/domain/entities/leaderboard_entry.dart';

class LeaderboardEntryModel extends LeaderboardEntry {
  const LeaderboardEntryModel({
    required super.id,
    required super.displayName,
    super.avatarUrl,
    required super.xp,
    required super.coins,
    required super.level,
    required super.rank,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json, int rank) {
    return LeaderboardEntryModel(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      xp: json['xp'] as int? ?? 0,
      coins: json['coins'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      rank: rank,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'xp': xp,
      'coins': coins,
      'level': level,
    };
  }
}

