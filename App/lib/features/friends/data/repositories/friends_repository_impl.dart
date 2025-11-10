import 'package:dartz/dartz.dart';
import 'package:sapit/core/error/failures.dart';
import 'package:sapit/features/friends/data/datasources/friends_local_datasource.dart';
import 'package:sapit/features/friends/data/datasources/friends_remote_datasource.dart';
import 'package:sapit/features/friends/domain/entities/friend_request.dart';
import 'package:sapit/features/friends/domain/repositories/friends_repository.dart';

class FriendsRepositoryImpl implements FriendsRepository {
  final FriendsRemoteDataSource remoteDataSource;
  final FriendsLocalDataSource localDataSource;

  FriendsRepositoryImpl(this.remoteDataSource, this.localDataSource);

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
  Future<Either<Failure, FriendRequest>> sendFriendRequest({String? email, String? userId}) async {
    try {
      final request = await remoteDataSource.sendFriendRequest(email: email, userId: userId);
      return Right(request);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FriendRequest>>> getPendingRequests() async {
    // Load cached requests first for instant display
    final cachedRequests = await localDataSource.getCachedPendingRequests();
    
    try {
      // Fetch from remote in the background
      final requests = await remoteDataSource.getPendingRequests();
      
      // Cache the new data
      await localDataSource.cachePendingRequests(requests);
      
      return Right(requests);
    } catch (e) {
      // If remote fails, return cached data if available
      if (cachedRequests.isNotEmpty) {
        return Right(cachedRequests);
      }
      
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
    // Load cached friends first for instant display
    final cachedFriends = await localDataSource.getCachedFriends();
    
    try {
      // Fetch from remote in the background
      final friends = await remoteDataSource.getFriends();
      
      // Cache the new data
      await localDataSource.cacheFriends(friends);
      
      return Right(friends);
    } catch (e) {
      // If remote fails, return cached data if available
      if (cachedFriends.isNotEmpty) {
        return Right(cachedFriends);
      }
      
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

