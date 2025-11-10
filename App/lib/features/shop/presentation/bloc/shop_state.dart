import 'package:equatable/equatable.dart';
import 'package:sapit/features/shop/domain/entities/shop_item.dart';
import 'package:sapit/features/shop/domain/entities/user_item.dart';

abstract class ShopState extends Equatable {
  const ShopState();

  @override
  List<Object?> get props => [];
}

class ShopInitial extends ShopState {
  const ShopInitial();
}

class ShopLoading extends ShopState {
  const ShopLoading();
}

class ShopItemsLoaded extends ShopState {
  final List<ShopItem> items;
  final List<UserItem> inventory;

  const ShopItemsLoaded({
    required this.items,
    required this.inventory,
  });

  @override
  List<Object?> get props => [items, inventory];

  ShopItemsLoaded copyWith({
    List<ShopItem>? items,
    List<UserItem>? inventory,
  }) {
    return ShopItemsLoaded(
      items: items ?? this.items,
      inventory: inventory ?? this.inventory,
    );
  }
}

class ItemPurchased extends ShopState {
  final UserItem userItem;
  final String message;

  const ItemPurchased({
    required this.userItem,
    required this.message,
  });

  @override
  List<Object?> get props => [userItem, message];
}

class ItemEquipped extends ShopState {
  final UserItem userItem;
  final String message;

  const ItemEquipped({
    required this.userItem,
    required this.message,
  });

  @override
  List<Object?> get props => [userItem, message];
}

class ShopError extends ShopState {
  final String message;

  const ShopError(this.message);

  @override
  List<Object?> get props => [message];
}

