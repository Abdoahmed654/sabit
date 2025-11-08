import 'package:dio/dio.dart';
import 'package:sapit/features/chat/data/models/chat_group_model.dart';
import 'package:sapit/features/chat/data/models/message_model.dart';
import 'package:sapit/features/chat/domain/entities/chat_group.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatGroupModel>> getAllGroups();
  Future<ChatGroupModel> getGroupById(String groupId);
  Future<ChatGroupModel> createGroup({
    required String name,
    required GroupType type,
  });
  Future<List<MessageModel>> getMessages({
    required String groupId,
    int limit = 50,
  });
  Future<MessageModel> sendMessage({
    required String groupId,
    required String content,
  });
  Future<void> leaveGroup(String groupId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final Dio dio;

  ChatRemoteDataSourceImpl(this.dio);

  @override
  Future<List<ChatGroupModel>> getAllGroups() async {
    try {
      final response = await dio.get('/chat/groups');
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => ChatGroupModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get groups');
    }
  }

  @override
  Future<ChatGroupModel> getGroupById(String groupId) async {
    try {
      final response = await dio.get('/chat/groups/$groupId');
      return ChatGroupModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get group');
    }
  }

  @override
  Future<ChatGroupModel> createGroup({
    required String name,
    required GroupType type,
  }) async {
    try {
      final response = await dio.post(
        '/chat/groups',
        data: {
          'name': name,
          'type': type.name,
        },
      );
      return ChatGroupModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to create group');
    }
  }

  @override
  Future<List<MessageModel>> getMessages({
    required String groupId,
    int limit = 50,
  }) async {
    try {
      final response = await dio.get(
        '/chat/groups/$groupId/messages',
        queryParameters: {'limit': limit},
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => MessageModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get messages');
    }
  }

  @override
  Future<MessageModel> sendMessage({
    required String groupId,
    required String content,
  }) async {
    try {
      final response = await dio.post(
        '/chat/messages',
        data: {
          'groupId': groupId,
          'content': content,
        },
      );
      return MessageModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to send message');
    }
  }

  @override
  Future<void> leaveGroup(String groupId) async {
    try {
      await dio.delete('/chat/groups/$groupId/leave');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to leave group');
    }
  }
}

