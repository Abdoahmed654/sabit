import 'package:sapit/features/shop/domain/entities/shop_item.dart';

class ShopItemModel extends ShopItem {
  const ShopItemModel({
    required super.id,
    required super.name,
    required super.type,
    super.imageUrl,
    required super.priceCoins,
    required super.priceXp,
    required super.rarity,
    required super.createdAt,
  });

  factory ShopItemModel.fromJson(Map<String, dynamic> json) {
    return ShopItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: _parseItemType(json['type'] as String),
      imageUrl: json['imageUrl'] as String?,
      priceCoins: json['priceCoins'] as int,
      priceXp: json['priceXp'] as int? ?? 0,
      rarity: _parseItemRarity(json['rarity'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'imageUrl': imageUrl,
      'priceCoins': priceCoins,
      'priceXp': priceXp,
      'rarity': rarity.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static ItemType _parseItemType(String type) {
    switch (type.toUpperCase()) {
      case 'HAIR':
        return ItemType.HAIR;
      case 'CLOTH':
        return ItemType.CLOTH;
      case 'ACCESSORY':
        return ItemType.ACCESSORY;
      case 'SHOES':
        return ItemType.SHOES;
      default:
        return ItemType.CLOTH;
    }
  }

  static ItemRarity _parseItemRarity(String rarity) {
    switch (rarity.toUpperCase()) {
      case 'COMMON':
        return ItemRarity.COMMON;
      case 'RARE':
        return ItemRarity.RARE;
      case 'EPIC':
        return ItemRarity.EPIC;
      case 'LEGENDARY':
        return ItemRarity.LEGENDARY;
      default:
        return ItemRarity.COMMON;
    }
  }

  ShopItem toEntity() => this;
}

