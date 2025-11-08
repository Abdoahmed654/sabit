import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sapit/core/error/failures.dart';
import 'package:sapit/features/friends/domain/repositories/friends_repository.dart';

class BlockFriendUsecase {
  final FriendsRepository repository;

  BlockFriendUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(BlockFriendParams params) async {
    return await repository.blockFriend(params.friendId);
  }
}

class BlockFriendParams extends Equatable {
  final String friendId;

  const BlockFriendParams(this.friendId);

  @override
  List<Object?> get props => [friendId];
}

