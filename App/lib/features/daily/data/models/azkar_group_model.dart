import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/azkar_group.dart';
import 'azkar_model.dart';

part 'azkar_group_model.g.dart';

@JsonSerializable()
class AzkarGroupModel {
  final String id;
  final String name;
  final String nameAr;
  final String? description;
  final String? icon;
  final String? color;
  final String category;
  final int order;
  final List<AzkarModel> azkars;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AzkarGroupModel({
    required this.id,
    required this.name,
    required this.nameAr,
    this.description,
    this.icon,
    this.color,
    required this.category,
    required this.order,
    required this.azkars,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AzkarGroupModel.fromJson(Map<String, dynamic> json) =>
      _$AzkarGroupModelFromJson(json);

  Map<String, dynamic> toJson() => _$AzkarGroupModelToJson(this);

  AzkarGroup toEntity() {
    return AzkarGroup(
      id: id,
      name: name,
      nameAr: nameAr,
      description: description,
      icon: icon,
      color: color,
      category: _categoryFromString(category),
      order: order,
      azkars: azkars.map((a) => a.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory AzkarGroupModel.fromEntity(AzkarGroup entity) {
    return AzkarGroupModel(
      id: entity.id,
      name: entity.name,
      nameAr: entity.nameAr,
      description: entity.description,
      icon: entity.icon,
      color: entity.color,
      category: _categoryToString(entity.category),
      order: entity.order,
      azkars: entity.azkars.map((a) => AzkarModel.fromEntity(a)).toList(),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static AzkarCategory _categoryFromString(String category) {
    switch (category.toUpperCase()) {
      case 'MORNING':
        return AzkarCategory.morning;
      case 'EVENING':
        return AzkarCategory.evening;
      case 'AFTER_PRAYER':
        return AzkarCategory.afterPrayer;
      case 'BEFORE_SLEEP':
        return AzkarCategory.beforeSleep;
      case 'GENERAL':
      default:
        return AzkarCategory.general;
    }
  }

  static String _categoryToString(AzkarCategory category) {
    switch (category) {
      case AzkarCategory.morning:
        return 'MORNING';
      case AzkarCategory.evening:
        return 'EVENING';
      case AzkarCategory.afterPrayer:
        return 'AFTER_PRAYER';
      case AzkarCategory.beforeSleep:
        return 'BEFORE_SLEEP';
      case AzkarCategory.general:
        return 'GENERAL';
    }
  }
}

