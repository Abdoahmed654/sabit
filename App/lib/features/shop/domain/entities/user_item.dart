import 'package:equatable/equatable.dart';
import 'package:sapit/features/shop/domain/entities/shop_item.dart';

class UserItem extends Equatable {
  final String id;
  final String userId;
  final ShopItem item;
  final bool equipped;
  final DateTime unlockedAt;

  const UserItem({
    required this.id,
    required this.userId,
    required this.item,
    required this.equipped,
    required this.unlockedAt,
  });

  @override
  List<Object?> get props => [id, userId, item, equipped, unlockedAt];
}

