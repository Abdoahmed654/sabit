// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'azkar_group_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AzkarGroupModel _$AzkarGroupModelFromJson(Map<String, dynamic> json) =>
    AzkarGroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      nameAr: json['nameAr'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      category: json['category'] as String,
      order: (json['order'] as num).toInt(),
      azkars: (json['azkars'] as List<dynamic>)
          .map((e) => AzkarModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AzkarGroupModelToJson(AzkarGroupModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'nameAr': instance.nameAr,
      'description': instance.description,
      'icon': instance.icon,
      'color': instance.color,
      'category': instance.category,
      'order': instance.order,
      'azkars': instance.azkars.map((e) => e.toJson()).toList(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

