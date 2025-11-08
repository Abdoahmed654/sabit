// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'azkar_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AzkarModel _$AzkarModelFromJson(Map<String, dynamic> json) => AzkarModel(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      title: json['title'] as String,
      titleAr: json['titleAr'] as String,
      arabicText: json['arabicText'] as String,
      translation: json['translation'] as String,
      transliteration: json['transliteration'] as String?,
      targetCount: (json['targetCount'] as num).toInt(),
      xpReward: (json['xpReward'] as num).toInt(),
      coinsReward: (json['coinsReward'] as num).toInt(),
      order: (json['order'] as num).toInt(),
      reference: json['reference'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AzkarModelToJson(AzkarModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'title': instance.title,
      'titleAr': instance.titleAr,
      'arabicText': instance.arabicText,
      'translation': instance.translation,
      'transliteration': instance.transliteration,
      'targetCount': instance.targetCount,
      'xpReward': instance.xpReward,
      'coinsReward': instance.coinsReward,
      'order': instance.order,
      'reference': instance.reference,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

