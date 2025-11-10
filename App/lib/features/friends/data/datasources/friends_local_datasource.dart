import 'package:hive/hive.dart';
import 'package:sapit/features/friends/data/models/friend_request_model.dart';

abstract class FriendsLocalDataSource {
  Future<List<UserInfoModel>> getCachedFriends();
  Future<void> cacheFriends(List<UserInfoModel> friends);
  Future<List<FriendRequestModel>> getCachedPendingRequests();
  Future<void> cachePendingRequests(List<FriendRequestModel> requests);
  Future<void> clearCache();
}

class FriendsLocalDataSourceImpl implements FriendsLocalDataSource {
  static const String _friendsBoxName = 'friends';
  static const String _requestsBoxName = 'friend_requests';
  static const String _friendsKey = 'all_friends';
  static const String _requestsKey = 'pending_requests';

  @override
  Future<List<UserInfoModel>> getCachedFriends() async {
    try {
      final box = await Hive.openBox(_friendsBoxName);
      final List<dynamic>? cachedData = box.get(_friendsKey);
      
      if (cachedData == null) return [];
      
      return cachedData
          .map((json) => UserInfoModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> cacheFriends(List<UserInfoModel> friends) async {
    try {
      final box = await Hive.openBox(_friendsBoxName);
      final jsonList = friends.map((friend) => friend.toJson()).toList();
      await box.put(_friendsKey, jsonList);
    } catch (e) {
      // Silently fail - caching is not critical
      print('Error caching friends: $e');
    }
  }

  @override
  Future<List<FriendRequestModel>> getCachedPendingRequests() async {
    try {
      final box = await Hive.openBox(_requestsBoxName);
      final List<dynamic>? cachedData = box.get(_requestsKey);
      
      if (cachedData == null) return [];
      
      return cachedData
          .map((json) => FriendRequestModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> cachePendingRequests(List<FriendRequestModel> requests) async {
    try {
      final box = await Hive.openBox(_requestsBoxName);
      final jsonList = requests.map((request) => request.toJson()).toList();
      await box.put(_requestsKey, jsonList);
    } catch (e) {
      // Silently fail - caching is not critical
      print('Error caching pending requests: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final friendsBox = await Hive.openBox(_friendsBoxName);
      final requestsBox = await Hive.openBox(_requestsBoxName);
      await friendsBox.clear();
      await requestsBox.clear();
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
}

