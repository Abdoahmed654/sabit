// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fasting_completion_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FastingCompletionModel _$FastingCompletionModelFromJson(
        Map<String, dynamic> json) =>
    FastingCompletionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      fastingType: json['fastingType'] as String,
      xpEarned: (json['xpEarned'] as num).toInt(),
      coinsEarned: (json['coinsEarned'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$FastingCompletionModelToJson(
        FastingCompletionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'date': instance.date.toIso8601String(),
      'fastingType': instance.fastingType,
      'xpEarned': instance.xpEarned,
      'coinsEarned': instance.coinsEarned,
      'createdAt': instance.createdAt.toIso8601String(),
    };

FastingStatusModel _$FastingStatusModelFromJson(Map<String, dynamic> json) =>
    FastingStatusModel(
      completedToday: json['completedToday'] as bool,
      canSubmit: json['canSubmit'] as bool,
      message: json['message'] as String?,
      completion: json['completion'] == null
          ? null
          : FastingCompletionModel.fromJson(
              json['completion'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FastingStatusModelToJson(
        FastingStatusModel instance) =>
    <String, dynamic>{
      'completedToday': instance.completedToday,
      'canSubmit': instance.canSubmit,
      'message': instance.message,
      'completion': instance.completion?.toJson(),
    };

