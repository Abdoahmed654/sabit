import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/azkar_completion.dart';
import 'azkar_model.dart';

part 'azkar_completion_model.g.dart';

@JsonSerializable()
class AzkarCompletionModel {
  final String id;
  final String userId;
  final String azkarId;
  final int xpEarned;
  final int coinsEarned;
  final DateTime completedAt;
  final AzkarModel? azkar;

  const AzkarCompletionModel({
    required this.id,
    required this.userId,
    required this.azkarId,
    required this.xpEarned,
    required this.coinsEarned,
    required this.completedAt,
    this.azkar,
  });

  factory AzkarCompletionModel.fromJson(Map<String, dynamic> json) =>
      _$AzkarCompletionModelFromJson(json);

  Map<String, dynamic> toJson() => _$AzkarCompletionModelToJson(this);

  AzkarCompletion toEntity() {
    return AzkarCompletion(
      id: id,
      userId: userId,
      azkarId: azkarId,
      xpEarned: xpEarned,
      coinsEarned: coinsEarned,
      completedAt: completedAt,
      azkar: azkar?.toEntity(),
    );
  }

  factory AzkarCompletionModel.fromEntity(AzkarCompletion entity) {
    return AzkarCompletionModel(
      id: entity.id,
      userId: entity.userId,
      azkarId: entity.azkarId,
      xpEarned: entity.xpEarned,
      coinsEarned: entity.coinsEarned,
      completedAt: entity.completedAt,
      azkar: entity.azkar != null ? AzkarModel.fromEntity(entity.azkar!) : null,
    );
  }
}

