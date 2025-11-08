import 'package:sapit/features/challenges/domain/entities/challenge.dart';

class ChallengeTaskModel extends ChallengeTask {
  const ChallengeTaskModel({
    required super.id,
    required super.title,
    required super.type,
    super.goalCount,
    required super.points,
    super.params,
  });

  factory ChallengeTaskModel.fromJson(Map<String, dynamic> json) {
    return ChallengeTaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      goalCount: json['goalCount'] as int?,
      points: json['points'] as int? ?? 10,
      params: json['params'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'goalCount': goalCount,
      'points': points,
      'params': params,
    };
  }
}

class ChallengeModel extends Challenge {
  const ChallengeModel({
    required super.id,
    required super.title,
    required super.description,
    required super.startAt,
    required super.endAt,
    required super.rewardXp,
    required super.rewardCoins,
    required super.isGlobal,
    required super.tasks,
    required super.createdAt,
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    final tasksList = json['tasks'] as List<dynamic>? ?? [];
    return ChallengeModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      startAt: DateTime.parse(json['startAt'] as String),
      endAt: DateTime.parse(json['endAt'] as String),
      rewardXp: json['rewardXp'] as int,
      rewardCoins: json['rewardCoins'] as int,
      isGlobal: json['isGlobal'] as bool? ?? true,
      tasks: tasksList
          .map((task) => ChallengeTaskModel.fromJson(task as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startAt': startAt.toIso8601String(),
      'endAt': endAt.toIso8601String(),
      'rewardXp': rewardXp,
      'rewardCoins': rewardCoins,
      'isGlobal': isGlobal,
      'tasks': tasks.map((task) {
        final taskModel = task as ChallengeTaskModel;
        return taskModel.toJson();
      }).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

