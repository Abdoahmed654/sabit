import 'package:equatable/equatable.dart';

abstract class ShopEvent extends Equatable {
  const ShopEvent();

  @override
  List<Object?> get props => [];
}

class LoadShopItemsEvent extends ShopEvent {
  const LoadShopItemsEvent();
}

class LoadUserInventoryEvent extends ShopEvent {
  const LoadUserInventoryEvent();
}

class BuyItemEvent extends ShopEvent {
  final String itemId;

  const BuyItemEvent(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class EquipItemEvent extends ShopEvent {
  final String userItemId;

  const EquipItemEvent(this.userItemId);

  @override
  List<Object?> get props => [userItemId];
}

class UnequipItemEvent extends ShopEvent {
  final String userItemId;

  const UnequipItemEvent(this.userItemId);

  @override
  List<Object?> get props => [userItemId];
}

