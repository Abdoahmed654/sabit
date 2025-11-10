import 'package:sapit/features/shop/data/models/shop_item_model.dart';
import 'package:sapit/features/shop/domain/entities/user_item.dart';

class UserItemModel extends UserItem {
  const UserItemModel({
    required super.id,
    required super.userId,
    required super.item,
    required super.equipped,
    required super.unlockedAt,
  });

  factory UserItemModel.fromJson(Map<String, dynamic> json) {
    return UserItemModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      item: ShopItemModel.fromJson(json['item'] as Map<String, dynamic>),
      equipped: json['equipped'] as bool,
      unlockedAt: DateTime.parse(json['unlockedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'item': (item as ShopItemModel).toJson(),
      'equipped': equipped,
      'unlockedAt': unlockedAt.toIso8601String(),
    };
  }

  UserItem toEntity() => this;
}

