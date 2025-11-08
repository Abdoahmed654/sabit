import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sapit/core/error/failures.dart';
import 'package:sapit/core/usecases/Usecase.dart';
import 'package:sapit/features/friends/domain/entities/friend_request.dart';
import 'package:sapit/features/friends/domain/repositories/friends_repository.dart';

class SendFriendRequestUsecase implements UseCase<FriendRequest, SendFriendRequestParams> {
  final FriendsRepository repository;

  SendFriendRequestUsecase(this.repository);

  @override
  Future<Either<Failure, FriendRequest>> call(SendFriendRequestParams params) async {
    return await repository.sendFriendRequest(params.email);
  }
}

class SendFriendRequestParams extends Equatable {
  final String email;

  const SendFriendRequestParams(this.email);

  @override
  List<Object?> get props => [email];
}

