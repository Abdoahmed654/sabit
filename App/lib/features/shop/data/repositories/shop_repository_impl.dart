import 'package:sapit/features/shop/data/datasources/shop_remote_datasource.dart';
import 'package:sapit/features/shop/domain/entities/shop_item.dart';
import 'package:sapit/features/shop/domain/entities/user_item.dart';
import 'package:sapit/features/shop/domain/repositories/shop_repository.dart';

class ShopRepositoryImpl implements ShopRepository {
  final ShopRemoteDataSource remoteDataSource;

  ShopRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ShopItem>> getAllItems() async {
    final items = await remoteDataSource.getAllItems();
    return items.map((model) => model.toEntity()).toList();
  }

  @override
  Future<ShopItem> getItemById(String itemId) async {
    final item = await remoteDataSource.getItemById(itemId);
    return item.toEntity();
  }

  @override
  Future<UserItem> buyItem(String itemId) async {
    final userItem = await remoteDataSource.buyItem(itemId);
    return userItem.toEntity();
  }

  @override
  Future<UserItem> equipItem(String userItemId) async {
    final userItem = await remoteDataSource.equipItem(userItemId);
    return userItem.toEntity();
  }

  @override
  Future<UserItem> unequipItem(String userItemId) async {
    final userItem = await remoteDataSource.unequipItem(userItemId);
    return userItem.toEntity();
  }

  @override
  Future<List<UserItem>> getUserInventory() async {
    final inventory = await remoteDataSource.getUserInventory();
    return inventory.map((model) => model.toEntity()).toList();
  }
}

