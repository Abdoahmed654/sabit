import 'package:equatable/equatable.dart';

class Azkar extends Equatable {
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

  const Azkar({
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

  @override
  List<Object?> get props => [
        id,
        groupId,
        title,
        titleAr,
        arabicText,
        translation,
        transliteration,
        targetCount,
        xpReward,
        coinsReward,
        order,
        reference,
        createdAt,
        updatedAt,
      ];
}

