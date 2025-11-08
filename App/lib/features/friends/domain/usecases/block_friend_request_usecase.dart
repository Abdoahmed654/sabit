import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sapit/core/error/failures.dart';
import 'package:sapit/core/usecases/Usecase.dart';
import 'package:sapit/features/friends/domain/entities/friend_request.dart';
import 'package:sapit/features/friends/domain/repositories/friends_repository.dart';

class BlockFriendRequestUsecase implements UseCase<FriendRequest, BlockFriendRequestParams> {
  final FriendsRepository repository;

  BlockFriendRequestUsecase(this.repository);

  @override
  Future<Either<Failure, FriendRequest>> call(BlockFriendRequestParams params) async {
    return await repository.blockFriendRequest(params.friendshipId);
  }
}

class BlockFriendRequestParams extends Equatable {
  final String friendshipId;

  const BlockFriendRequestParams(this.friendshipId);

  @override
  List<Object?> get props => [friendshipId];
}

