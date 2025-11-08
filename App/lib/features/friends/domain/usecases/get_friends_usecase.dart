import 'package:dartz/dartz.dart';
import 'package:sapit/core/error/failures.dart';
import 'package:sapit/core/usecases/Usecase.dart';
import 'package:sapit/features/friends/domain/entities/friend_request.dart';
import 'package:sapit/features/friends/domain/repositories/friends_repository.dart';

class GetFriendsUsecase implements UseCase<List<UserInfo>, NoParams> {
  final FriendsRepository repository;

  GetFriendsUsecase(this.repository);

  @override
  Future<Either<Failure, List<UserInfo>>> call(NoParams params) async {
    return await repository.getFriends();
  }
}

