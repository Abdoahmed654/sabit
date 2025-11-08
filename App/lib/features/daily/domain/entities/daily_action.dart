class DailyAction {
  final String id;
  final String userId;
  final String actionType;
  final int xpEarned;
  final int coinsEarned;
  final DateTime completedAt;
  final Map<String, dynamic>? metadata;

  DailyAction({
    required this.id,
    required this.userId,
    required this.actionType,
    required this.xpEarned,
    required this.coinsEarned,
    required this.completedAt,
    this.metadata,
  });
}

