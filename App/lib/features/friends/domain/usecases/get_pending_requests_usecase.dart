import 'package:dartz/dartz.dart';
import 'package:sapit/core/error/failures.dart';
import 'package:sapit/core/usecases/Usecase.dart';
import 'package:sapit/features/friends/domain/entities/friend_request.dart';
import 'package:sapit/features/friends/domain/repositories/friends_repository.dart';

class GetPendingRequestsUsecase implements UseCase<List<FriendRequest>, NoParams> {
  final FriendsRepository repository;

  GetPendingRequestsUsecase(this.repository);

  @override
  Future<Either<Failure, List<FriendRequest>>> call(NoParams params) async {
    return await repository.getPendingRequests();
  }
}

