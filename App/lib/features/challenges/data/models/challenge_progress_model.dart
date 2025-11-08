import 'package:sapit/features/challenges/domain/entities/challenge_progress.dart';

class ChallengeProgressModel extends ChallengeProgress {
  const ChallengeProgressModel({
    required super.id,
    required super.userId,
    required super.challengeId,
    required super.status,
    super.taskProgress,
    required super.pointsEarned,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ChallengeProgressModel.fromJson(Map<String, dynamic> json) {
    return ChallengeProgressModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      challengeId: json['challengeId'] as String,
      status: json['status'] as String,
      taskProgress: json['taskProgress'] as Map<String, dynamic>?,
      pointsEarned: json['pointsEarned'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'challengeId': challengeId,
      'status': status,
      'taskProgress': taskProgress,
      'pointsEarned': pointsEarned,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

