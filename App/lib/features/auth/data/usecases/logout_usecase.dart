import 'package:dartz/dartz.dart';
import 'package:sapit/core/error/failures.dart';
import 'package:sapit/core/usecases/Usecase.dart';
import 'package:sapit/features/auth/domain/repositories/auth_repo.dart';

class LogoutUsecase implements UseCase<void, NoParams> {
  final AuthRepo repo;

  LogoutUsecase(this.repo);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    try {
      await repo.logout();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}