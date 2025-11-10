import 'package:dio/dio.dart';
import 'package:sapit/features/shop/data/models/shop_item_model.dart';
import 'package:sapit/features/shop/data/models/user_item_model.dart';

abstract class ShopRemoteDataSource {
  Future<List<ShopItemModel>> getAllItems();
  Future<ShopItemModel> getItemById(String itemId);
  Future<UserItemModel> buyItem(String itemId);
  Future<UserItemModel> equipItem(String userItemId);
  Future<UserItemModel> unequipItem(String userItemId);
  Future<List<UserItemModel>> getUserInventory();
}

class ShopRemoteDataSourceImpl implements ShopRemoteDataSource {
  final Dio dio;

  ShopRemoteDataSourceImpl(this.dio);

  @override
  Future<List<ShopItemModel>> getAllItems() async {
    final response = await dio.get('/shop/items');
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((json) => ShopItemModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ShopItemModel> getItemById(String itemId) async {
    final response = await dio.get('/shop/items/$itemId');
    return ShopItemModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<UserItemModel> buyItem(String itemId) async {
    final response = await dio.post('/shop/buy', data: {'itemId': itemId});
    return UserItemModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<UserItemModel> equipItem(String userItemId) async {
    final response =
        await dio.post('/shop/equip', data: {'userItemId': userItemId});
    return UserItemModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<UserItemModel> unequipItem(String userItemId) async {
    final response = await dio.delete('/shop/unequip/$userItemId');
    return UserItemModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<UserItemModel>> getUserInventory() async {
    final response = await dio.get('/users/inventory');
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((json) => UserItemModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

