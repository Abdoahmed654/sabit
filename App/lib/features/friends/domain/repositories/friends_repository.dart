import 'package:dartz/dartz.dart';
import 'package:sapit/core/error/failures.dart';
import 'package:sapit/features/friends/domain/entities/friend_request.dart';

abstract class FriendsRepository {
  Future<Either<Failure, UserInfo>> searchUserByEmail(String email);
  Future<Either<Failure, FriendRequest>> sendFriendRequest(String email);
  Future<Either<Failure, List<FriendRequest>>> getPendingRequests();
  Future<Either<Failure, FriendRequest>> acceptFriendRequest(String friendshipId);
  Future<Either<Failure, FriendRequest>> blockFriendRequest(String friendshipId);
  Future<Either<Failure, List<UserInfo>>> getFriends();
  Future<Either<Failure, void>> unfriend(String friendId);
  Future<Either<Failure, void>> blockFriend(String friendId);
}

