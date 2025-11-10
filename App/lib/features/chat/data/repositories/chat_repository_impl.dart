import 'package:dartz/dartz.dart';
import 'package:sapit/core/error/failures.dart';
import 'package:sapit/features/chat/data/datasources/chat_local_datasource.dart';
import 'package:sapit/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:sapit/features/chat/domain/entities/chat_group.dart';
import 'package:sapit/features/chat/domain/entities/message.dart';
import 'package:sapit/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final ChatLocalDataSource localDataSource;

  ChatRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<Either<Failure, List<ChatGroup>>> getAllGroups() async {
    // Load cached groups first for instant display
    final cachedGroups = await localDataSource.getCachedGroups();
    
    try {
      // Fetch from remote in the background
      final groups = await remoteDataSource.getAllGroups();

      // Cache the new data
      await localDataSource.cacheGroups(groups);

      return Right(groups);
    } catch (e) {
      // If remote fails, return cached data if available
      if (cachedGroups.isNotEmpty) {
        return Right(cachedGroups);
      }

      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatGroup>> getGroupById(String groupId) async {
    try {
      final group = await remoteDataSource.getGroupById(groupId);
      return Right(group);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatGroup>> createGroup({
    required String name,
    List<String>? memberIds,
  }) async {
    try {
      final group = await remoteDataSource.createGroup(
        name: name,
        memberIds: memberIds,
      );
      return Right(group);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Message>>> getMessages({
    required String groupId,
    int limit = 50,
  }) async {
    // Load cached messages first for instant display
    final cachedMessages = await localDataSource.getCachedMessages(groupId);
    
    try {
      // Fetch from remote in the background
      final messages = await remoteDataSource.getMessages(
        groupId: groupId,
        limit: limit,
      );

      // Cache the new data
      await localDataSource.cacheMessages(groupId, messages);

      // Reverse to show oldest first
      return Right(messages.reversed.toList());
    } catch (e) {
      // If remote fails, return cached data if available
      if (cachedMessages.isNotEmpty) {
        return Right(cachedMessages.reversed.toList());
      }

      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Message>> sendMessage({
    required String groupId,
    required String content,
  }) async {
    try {
      final message = await remoteDataSource.sendMessage(
        groupId: groupId,
        content: content,
      );
      return Right(message);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> leaveGroup(String groupId) async {
    try {
      await remoteDataSource.leaveGroup(groupId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addMemberToGroup(String groupId, String userId) async {
    try {
      await remoteDataSource.addMemberToGroup(groupId, userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeMemberFromGroup(String groupId, String memberId) async {
    try {
      await remoteDataSource.removeMemberFromGroup(groupId, memberId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

