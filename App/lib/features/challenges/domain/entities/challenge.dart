class ChallengeTask {
  final String id;
  final String title;
  final String type;
  final int? goalCount;
  final int points;
  final Map<String, dynamic>? params;

  const ChallengeTask({
    required this.id,
    required this.title,
    required this.type,
    this.goalCount,
    required this.points,
    this.params,
  });
}

class Challenge {
  final String id;
  final String title;
  final String description;
  final DateTime startAt;
  final DateTime endAt;
  final int rewardXp;
  final int rewardCoins;
  final bool isGlobal;
  final List<ChallengeTask> tasks;
  final DateTime createdAt;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.startAt,
    required this.endAt,
    required this.rewardXp,
    required this.rewardCoins,
    required this.isGlobal,
    required this.tasks,
    required this.createdAt,
  });

  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(startAt) && now.isBefore(endAt);
  }

  bool get isUpcoming {
    final now = DateTime.now();
    return now.isBefore(startAt);
  }

  bool get isCompleted {
    final now = DateTime.now();
    return now.isAfter(endAt);
  }
}

