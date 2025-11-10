import 'package:equatable/equatable.dart';

enum ItemType { HAIR, CLOTH, ACCESSORY, SHOES }

enum ItemRarity { COMMON, RARE, EPIC, LEGENDARY }

class ShopItem extends Equatable {
  final String id;
  final String name;
  final ItemType type;
  final String? imageUrl;
  final int priceCoins;
  final int priceXp;
  final ItemRarity rarity;
  final DateTime createdAt;

  const ShopItem({
    required this.id,
    required this.name,
    required this.type,
    this.imageUrl,
    required this.priceCoins,
    required this.priceXp,
    required this.rarity,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        imageUrl,
        priceCoins,
        priceXp,
        rarity,
        createdAt,
      ];
}

