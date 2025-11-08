import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/fasting_completion.dart';

part 'fasting_completion_model.g.dart';

@JsonSerializable()
class FastingCompletionModel {
  final String id;
  final String userId;
  final DateTime date;
  final String fastingType;
  final int xpEarned;
  final int coinsEarned;
  final DateTime createdAt;

  const FastingCompletionModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.fastingType,
    required this.xpEarned,
    required this.coinsEarned,
    required this.createdAt,
  });

  factory FastingCompletionModel.fromJson(Map<String, dynamic> json) =>
      _$FastingCompletionModelFromJson(json);

  Map<String, dynamic> toJson() => _$FastingCompletionModelToJson(this);

  FastingCompletion toEntity() {
    return FastingCompletion(
      id: id,
      userId: userId,
      date: date,
      fastingType: _fastingTypeFromString(fastingType),
      xpEarned: xpEarned,
      coinsEarned: coinsEarned,
      createdAt: createdAt,
    );
  }

  factory FastingCompletionModel.fromEntity(FastingCompletion entity) {
    return FastingCompletionModel(
      id: entity.id,
      userId: entity.userId,
      date: entity.date,
      fastingType: _fastingTypeToString(entity.fastingType),
      xpEarned: entity.xpEarned,
      coinsEarned: entity.coinsEarned,
      createdAt: entity.createdAt,
    );
  }

  static FastingType _fastingTypeFromString(String type) {
    switch (type.toUpperCase()) {
      case 'VOLUNTARY':
        return FastingType.voluntary;
      case 'MONDAY':
        return FastingType.monday;
      case 'THURSDAY':
        return FastingType.thursday;
      case 'WHITE_DAYS':
        return FastingType.whiteDays;
      case 'ARAFAH':
        return FastingType.arafah;
      case 'ASHURA':
        return FastingType.ashura;
      case 'SHAWWAL':
        return FastingType.shawwal;
      default:
        return FastingType.voluntary;
    }
  }

  static String _fastingTypeToString(FastingType type) {
    switch (type) {
      case FastingType.voluntary:
        return 'VOLUNTARY';
      case FastingType.monday:
        return 'MONDAY';
      case FastingType.thursday:
        return 'THURSDAY';
      case FastingType.whiteDays:
        return 'WHITE_DAYS';
      case FastingType.arafah:
        return 'ARAFAH';
      case FastingType.ashura:
        return 'ASHURA';
      case FastingType.shawwal:
        return 'SHAWWAL';
    }
  }
}

@JsonSerializable()
class FastingStatusModel {
  final bool completedToday;
  final bool canSubmit;
  final String? message;
  final FastingCompletionModel? completion;

  const FastingStatusModel({
    required this.completedToday,
    required this.canSubmit,
    this.message,
    this.completion,
  });

  factory FastingStatusModel.fromJson(Map<String, dynamic> json) =>
      _$FastingStatusModelFromJson(json);

  Map<String, dynamic> toJson() => _$FastingStatusModelToJson(this);

  FastingStatus toEntity() {
    return FastingStatus(
      completedToday: completedToday,
      canSubmit: canSubmit,
      message: message,
      completion: completion?.toEntity(),
    );
  }
}

