import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sapit/core/error/failures.dart';
import 'package:sapit/features/friends/domain/repositories/friends_repository.dart';

class UnfriendUsecase {
  final FriendsRepository repository;

  UnfriendUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(UnfriendParams params) async {
    return await repository.unfriend(params.friendId);
  }
}

class UnfriendParams extends Equatable {
  final String friendId;

  const UnfriendParams(this.friendId);

  @override
  List<Object?> get props => [friendId];
}

