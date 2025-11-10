import 'package:sapit/features/shop/domain/entities/shop_item.dart';
import 'package:sapit/features/shop/domain/entities/user_item.dart';

abstract class ShopRepository {
  Future<List<ShopItem>> getAllItems();
  Future<ShopItem> getItemById(String itemId);
  Future<UserItem> buyItem(String itemId);
  Future<UserItem> equipItem(String userItemId);
  Future<UserItem> unequipItem(String userItemId);
  Future<List<UserItem>> getUserInventory();
}

