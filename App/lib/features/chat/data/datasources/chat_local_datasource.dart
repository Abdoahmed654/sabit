import 'package:hive/hive.dart';
import 'package:sapit/features/chat/data/models/chat_group_model.dart';
import 'package:sapit/features/chat/data/models/message_model.dart';

abstract class ChatLocalDataSource {
  Future<List<ChatGroupModel>> getCachedGroups();
  Future<void> cacheGroups(List<ChatGroupModel> groups);
  Future<List<MessageModel>> getCachedMessages(String groupId);
  Future<void> cacheMessages(String groupId, List<MessageModel> messages);
  Future<void> clearCache();
}

class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  static const String _groupsBoxName = 'chat_groups';
  static const String _messagesBoxName = 'chat_messages';
  static const String _groupsKey = 'all_groups';

  @override
  Future<List<ChatGroupModel>> getCachedGroups() async {
    try {
      final box = await Hive.openBox(_groupsBoxName);
      final List<dynamic>? cachedData = box.get(_groupsKey);
      
      if (cachedData == null) return [];
      
      return cachedData
          .map((json) => ChatGroupModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> cacheGroups(List<ChatGroupModel> groups) async {
    try {
      final box = await Hive.openBox(_groupsBoxName);
      final jsonList = groups.map((group) => group.toJson()).toList();
      await box.put(_groupsKey, jsonList);
    } catch (e) {
      print('Error caching groups: $e');
    }
  }

  @override
  Future<List<MessageModel>> getCachedMessages(String groupId) async {
    try {
      final box = await Hive.openBox(_messagesBoxName);
      final List<dynamic>? cachedData = box.get(groupId);
      
      if (cachedData == null) return [];
      
      return cachedData
          .map((json) => MessageModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> cacheMessages(String groupId, List<MessageModel> messages) async {
    try {
      final box = await Hive.openBox(_messagesBoxName);
      final jsonList = messages.map((message) => message.toJson()).toList();
      await box.put(groupId, jsonList);
    } catch (e) {
      // Silently fail - caching is not critical
      print('Error caching messages: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final groupsBox = await Hive.openBox(_groupsBoxName);
      final messagesBox = await Hive.openBox(_messagesBoxName);
      await groupsBox.clear();
      await messagesBox.clear();
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
}

