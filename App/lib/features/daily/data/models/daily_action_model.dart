import 'package:sapit/features/daily/domain/entities/daily_action.dart';

class DailyActionModel extends DailyAction {
  DailyActionModel({
    required super.id,
    required super.userId,
    required super.actionType,
    required super.xpEarned,
    required super.coinsEarned,
    required super.completedAt,
    super.metadata,
  });

  factory DailyActionModel.fromJson(Map<String, dynamic> json) {
    return DailyActionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      actionType: json['actionType'] as String,
      xpEarned: json['xpEarned'] as int,
      coinsEarned: json['coinsEarned'] as int,
      completedAt: DateTime.parse(json['completedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'actionType': actionType,
      'xpEarned': xpEarned,
      'coinsEarned': coinsEarned,
      'completedAt': completedAt.toIso8601String(),
      'metadata': metadata,
    };
  }
}

