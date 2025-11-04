import 'package:sapit/core/usecases/Usecase.dart';
import 'package:sapit/features/auth/domain/repositories/auth_repo.dart';

class LogoutUsecase extends Usecase<void, void> {
  final AuthRepo repo;

  LogoutUsecase(this.repo);

  @override
  Future<void> call(void params) async {
    await repo.logout();
  }
}