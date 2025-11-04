import 'package:sapit/core/usecases/Usecase.dart';
import 'package:sapit/features/auth/domain/entities/User.dart';
import 'package:sapit/features/auth/domain/repositories/auth_repo.dart';

class RegisterUsecase extends Usecase<User, RegisterParams> {
  final AuthRepo repo;

  RegisterUsecase(this.repo);

  @override
  Future<User> call(RegisterParams params) async {
    return await repo.register(
      email: params.email,
      password: params.password,
      name: params.name
    );
  }
}

class RegisterParams {
  final String email;
  final String password;
  final String name;

  RegisterParams({
    required this.email, 
    required this.password, 
    required this.name
  });
}
