import 'package:sapit/core/usecases/usecase_plain.dart';
import 'package:sapit/features/shop/domain/entities/user_item.dart';
import 'package:sapit/features/shop/domain/repositories/shop_repository.dart';

class GetUserInventory implements UseCasePlain<List<UserItem>, NoParamsPlain> {
  final ShopRepository repository;

  GetUserInventory(this.repository);

  @override
  Future<List<UserItem>> call(NoParamsPlain params) async {
    return await repository.getUserInventory();
  }
}
