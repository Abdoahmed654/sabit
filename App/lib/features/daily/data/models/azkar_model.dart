import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/azkar.dart';

part 'azkar_model.g.dart';

@JsonSerializable()
class AzkarModel {
  final String id;
  final String groupId;
  final String title;
  final String titleAr;
  final String arabicText;
  final String translation;
  final String? transliteration;
  final int targetCount;
  final int xpReward;
  final int coinsReward;
  final int order;
  final String? reference;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AzkarModel({
    required this.id,
    required this.groupId,
    required this.title,
    required this.titleAr,
    required this.arabicText,
    required this.translation,
    this.transliteration,
    required this.targetCount,
    required this.xpReward,
    required this.coinsReward,
    required this.order,
    this.reference,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AzkarModel.fromJson(Map<String, dynamic> json) =>
      _$AzkarModelFromJson(json);

  Map<String, dynamic> toJson() => _$AzkarModelToJson(this);

  Azkar toEntity() {
    return Azkar(
      id: id,
      groupId: groupId,
      title: title,
      titleAr: titleAr,
      arabicText: arabicText,
      translation: translation,
      transliteration: transliteration,
      targetCount: targetCount,
      xpReward: xpReward,
      coinsReward: coinsReward,
      order: order,
      reference: reference,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory AzkarModel.fromEntity(Azkar entity) {
    return AzkarModel(
      id: entity.id,
      groupId: entity.groupId,
      title: entity.title,
      titleAr: entity.titleAr,
      arabicText: entity.arabicText,
      translation: entity.translation,
      transliteration: entity.transliteration,
      targetCount: entity.targetCount,
      xpReward: entity.xpReward,
      coinsReward: entity.coinsReward,
      order: entity.order,
      reference: entity.reference,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

