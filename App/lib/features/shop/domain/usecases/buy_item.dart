import 'package:sapit/features/shop/domain/entities/user_item.dart';
import 'package:sapit/features/shop/domain/repositories/shop_repository.dart';

class BuyItem {
  final ShopRepository repository;

  BuyItem(this.repository);

  Future<UserItem> call(String itemId) async {
    return await repository.buyItem(itemId);
  }
}

