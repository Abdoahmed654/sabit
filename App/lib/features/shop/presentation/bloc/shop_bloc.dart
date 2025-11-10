import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:sapit/core/usecases/Usecase.dart';
import 'package:sapit/core/usecases/usecase_plain.dart';

import 'package:sapit/features/shop/domain/usecases/buy_item.dart';
import 'package:sapit/features/shop/domain/usecases/get_all_items.dart';
import 'package:sapit/features/shop/domain/usecases/get_user_inventory.dart';
import 'shop_event.dart';
import 'shop_state.dart';

class ShopBloc extends Bloc<ShopEvent, ShopState> {
  final GetAllItems getAllItems;
  final GetUserInventory getUserInventory;
  final BuyItem buyItem;

  ShopBloc({
    required this.getAllItems,
    required this.getUserInventory,
    required this.buyItem,
  }) : super(const ShopInitial()) {
    on<LoadShopItemsEvent>(_onLoadShopItems);
    on<LoadUserInventoryEvent>(_onLoadUserInventory);
    on<BuyItemEvent>(_onBuyItem);
  }

  Future<void> _onLoadShopItems(
    LoadShopItemsEvent event,
    Emitter<ShopState> emit,
  ) async {
    emit(const ShopLoading());
    try {
      final items = await getAllItems(NoParamsPlain());
      final inventory = await getUserInventory(NoParamsPlain());
      emit(ShopItemsLoaded(items: items, inventory: inventory));
    } catch (e) {
      emit(ShopError(e.toString()));
    }
  }

  Future<void> _onLoadUserInventory(
    LoadUserInventoryEvent event,
    Emitter<ShopState> emit,
  ) async {
    try {
      final inventory = await getUserInventory(NoParamsPlain());
      if (state is ShopItemsLoaded) {
        emit((state as ShopItemsLoaded).copyWith(inventory: inventory));
      }
    } catch (e) {
      emit(ShopError(e.toString()));
    }
  }

  Future<void> _onBuyItem(
    BuyItemEvent event,
    Emitter<ShopState> emit,
  ) async {
    try {
      final userItem = await buyItem(event.itemId);
      emit(ItemPurchased(
        userItem: userItem,
        message: 'Item purchased successfully!',
      ));
      
      // Reload shop items and inventory
      add(const LoadShopItemsEvent());
    } catch (e) {
      emit(ShopError(e.toString()));
      
      // Reload shop items to restore state
      add(const LoadShopItemsEvent());
    }
  }
}

