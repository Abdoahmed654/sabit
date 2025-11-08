import 'package:dartz/dartz.dart';
import 'package:sapit/core/error/failures.dart';
import 'package:sapit/core/usecases/Usecase.dart';
import 'package:sapit/features/auth/domain/entities/User.dart';
import 'package:sapit/features/auth/domain/repositories/auth_repo.dart';

class LoginUsecase implements UseCase<User, LoginParams> {
  final AuthRepo repo;

  LoginUsecase(this.repo);

  @override
  Future<Either<Failure, User>> call(LoginParams params) async {
    try {
      final user = await repo.login(
        email: params.email,
        password: params.password,
      );
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class LoginParams {
  final String email;
  final String password;

  LoginParams({required this.email, required this.password});
}
