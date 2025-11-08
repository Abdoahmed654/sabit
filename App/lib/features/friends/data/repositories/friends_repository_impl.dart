import 'package:dartz/dartz.dart';
import 'package:sapit/core/error/failures.dart';
import 'package:sapit/features/friends/data/datasources/friends_remote_datasource.dart';
import 'package:sapit/features/friends/domain/entities/friend_request.dart';
import 'package:sapit/features/friends/domain/repositories/friends_repository.dart';

class FriendsRepositoryImpl implements FriendsRepository {
  final FriendsRemoteDataSource remoteDataSource;

  FriendsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, UserInfo>> searchUserByEmail(String email) async {
    try {
      final user = await remoteDataSource.searchUserByEmail(email);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FriendRequest>> sendFriendRequest(String email) async {
    try {
      final request = await remoteDataSource.sendFriendRequest(email);
      return Right(request);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FriendRequest>>> getPendingRequests() async {
    try {
      final requests = await remoteDataSource.getPendingRequests();
      return Right(requests);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FriendRequest>> acceptFriendRequest(String friendshipId) async {
    try {
      final request = await remoteDataSource.acceptFriendRequest(friendshipId);
      return Right(request);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FriendRequest>> blockFriendRequest(String friendshipId) async {
    try {
      final request = await remoteDataSource.blockFriendRequest(friendshipId);
      return Right(request);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserInfo>>> getFriends() async {
    try {
      final friends = await remoteDataSource.getFriends();
      return Right(friends);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unfriend(String friendId) async {
    try {
      await remoteDataSource.unfriend(friendId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> blockFriend(String friendId) async {
    try {
      await remoteDataSource.blockFriend(friendId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

