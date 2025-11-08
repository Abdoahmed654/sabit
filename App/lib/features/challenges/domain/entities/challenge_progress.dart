class ChallengeProgress {
  final String id;
  final String userId;
  final String challengeId;
  final String status;
  final Map<String, dynamic>? taskProgress;
  final int pointsEarned;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChallengeProgress({
    required this.id,
    required this.userId,
    required this.challengeId,
    required this.status,
    this.taskProgress,
    required this.pointsEarned,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isCompleted => status == 'COMPLETED';
  bool get isInProgress => status == 'IN_PROGRESS';
  bool get isFailed => status == 'FAILED';
}

