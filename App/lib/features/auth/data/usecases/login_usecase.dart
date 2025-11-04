import 'package:sapit/core/usecases/Usecase.dart';
import 'package:sapit/features/auth/domain/entities/User.dart';
import 'package:sapit/features/auth/domain/repositories/auth_repo.dart';

class LoginUsecase extends Usecase<User, LoginParams> {
  final AuthRepo repo;

  LoginUsecase(this.repo);

  @override
  Future<User> call(LoginParams params) async {
    return await repo.login(
      email: params.email,
      password: params.password,
    );
  }
}

class LoginParams {
  final String email;
  final String password;

  LoginParams({required this.email, required this.password});
}
