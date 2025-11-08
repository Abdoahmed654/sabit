import 'package:dartz/dartz.dart';
import 'package:sapit/core/error/failures.dart';
import 'package:sapit/core/usecases/Usecase.dart';
import 'package:sapit/features/auth/domain/entities/User.dart';
import 'package:sapit/features/auth/domain/repositories/auth_repo.dart';

class RegisterUsecase implements UseCase<User, RegisterParams> {
  final AuthRepo repo;

  RegisterUsecase(this.repo);

  @override
  Future<Either<Failure, User>> call(RegisterParams params) async {
    try {
      final user = await repo.register(
        email: params.email,
        password: params.password,
        name: params.name,
      );
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
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
