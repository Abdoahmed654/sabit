import 'package:dartz/dartz.dart';
import 'package:sapit/core/error/failures.dart';
import 'package:sapit/features/chat/domain/entities/chat_group.dart';
import 'package:sapit/features/chat/domain/entities/message.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<ChatGroup>>> getAllGroups();
  Future<Either<Failure, ChatGroup>> getGroupById(String groupId);
  Future<Either<Failure, ChatGroup>> createGroup({
    required String name,
    List<String>? memberIds,
  });
  Future<Either<Failure, List<Message>>> getMessages({
    required String groupId,
    int limit = 50,
  });
  Future<Either<Failure, Message>> sendMessage({
    required String groupId,
    required String content,
  });
  Future<Either<Failure, void>> leaveGroup(String groupId);
  Future<Either<Failure, void>> addMemberToGroup(String groupId, String userId);
  Future<Either<Failure, void>> removeMemberFromGroup(String groupId, String memberId);
}

