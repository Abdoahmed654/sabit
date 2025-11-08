import 'package:equatable/equatable.dart';
import 'azkar.dart';

enum AzkarCategory {
  morning,
  evening,
  afterPrayer,
  beforeSleep,
  general,
}

class AzkarGroup extends Equatable {
  final String id;
  final String name;
  final String nameAr;
  final String? description;
  final String? icon;
  final String? color;
  final AzkarCategory category;
  final int order;
  final List<Azkar> azkars;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AzkarGroup({
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

  @override
  List<Object?> get props => [
        id,
        name,
        nameAr,
        description,
        icon,
        color,
        category,
        order,
        azkars,
        createdAt,
        updatedAt,
      ];
}

