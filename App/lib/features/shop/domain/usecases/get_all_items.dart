import 'package:sapit/core/usecases/usecase_plain.dart';
import 'package:sapit/features/shop/domain/entities/shop_item.dart';
import 'package:sapit/features/shop/domain/repositories/shop_repository.dart';

class GetAllItems implements UseCasePlain<List<ShopItem>, NoParamsPlain> {
  final ShopRepository repository;

  GetAllItems(this.repository);

  @override
  Future<List<ShopItem>> call(NoParamsPlain params) async {
    return await repository.getAllItems();
  }
}
