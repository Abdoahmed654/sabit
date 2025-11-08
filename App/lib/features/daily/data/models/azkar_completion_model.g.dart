// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'azkar_completion_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AzkarCompletionModel _$AzkarCompletionModelFromJson(
        Map<String, dynamic> json) =>
    AzkarCompletionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      azkarId: json['azkarId'] as String,
      xpEarned: (json['xpEarned'] as num).toInt(),
      coinsEarned: (json['coinsEarned'] as num).toInt(),
      completedAt: DateTime.parse(json['completedAt'] as String),
      azkar: json['azkar'] == null
          ? null
          : AzkarModel.fromJson(json['azkar'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AzkarCompletionModelToJson(
        AzkarCompletionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'azkarId': instance.azkarId,
      'xpEarned': instance.xpEarned,
      'coinsEarned': instance.coinsEarned,
      'completedAt': instance.completedAt.toIso8601String(),
      'azkar': instance.azkar?.toJson(),
    };

