import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sapit/core/error/failures.dart';
import 'package:sapit/core/usecases/Usecase.dart';
import 'package:sapit/features/friends/domain/entities/friend_request.dart';
import 'package:sapit/features/friends/domain/repositories/friends_repository.dart';

class AcceptFriendRequestUsecase implements UseCase<FriendRequest, AcceptFriendRequestParams> {
  final FriendsRepository repository;

  AcceptFriendRequestUsecase(this.repository);

  @override
  Future<Either<Failure, FriendRequest>> call(AcceptFriendRequestParams params) async {
    return await repository.acceptFriendRequest(params.friendshipId);
  }
}

class AcceptFriendRequestParams extends Equatable {
  final String friendshipId;

  const AcceptFriendRequestParams(this.friendshipId);

  @override
  List<Object?> get props => [friendshipId];
}

