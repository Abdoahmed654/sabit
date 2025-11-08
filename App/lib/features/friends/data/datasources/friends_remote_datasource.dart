import 'package:dio/dio.dart';
import 'package:sapit/features/friends/data/models/friend_request_model.dart';

abstract class FriendsRemoteDataSource {
  Future<UserInfoModel> searchUserByEmail(String email);
  Future<FriendRequestModel> sendFriendRequest(String email);
  Future<List<FriendRequestModel>> getPendingRequests();
  Future<FriendRequestModel> acceptFriendRequest(String friendshipId);
  Future<FriendRequestModel> blockFriendRequest(String friendshipId);
  Future<List<UserInfoModel>> getFriends();
  Future<void> unfriend(String friendId);
  Future<void> blockFriend(String friendId);
}

class FriendsRemoteDataSourceImpl implements FriendsRemoteDataSource {
  final Dio dio;

  FriendsRemoteDataSourceImpl(this.dio);

  @override
  Future<UserInfoModel> searchUserByEmail(String email) async {
    try {
      final response = await dio.get('/users/search', queryParameters: {'email': email});
      return UserInfoModel.fromJson(response.data);
    } catch (e){
      print(e);
      throw e;
    }

  }

  @override
  Future<FriendRequestModel> sendFriendRequest(String email) async {
    final response = await dio.post('/users/friends/request', data: {'email': email});
    return FriendRequestModel.fromJson(response.data);
  }

  @override
  Future<List<FriendRequestModel>> getPendingRequests() async {
    final response = await dio.get('/users/friends/requests/pending');
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => FriendRequestModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<FriendRequestModel> acceptFriendRequest(String friendshipId) async {
    final response = await dio.post('/users/friends/$friendshipId/accept');
    return FriendRequestModel.fromJson(response.data);
  }

  @override
  Future<FriendRequestModel> blockFriendRequest(String friendshipId) async {
    final response = await dio.post('/users/friends/$friendshipId/block');
    return FriendRequestModel.fromJson(response.data);
  }

  @override
  Future<List<UserInfoModel>> getFriends() async {
    final response = await dio.get('/users/friends');
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => UserInfoModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> unfriend(String friendId) async {
    await dio.post('/users/friends/$friendId/unfriend');
  }

  @override
  Future<void> blockFriend(String friendId) async {
    await dio.post('/users/friends/$friendId/block-friend');
  }
}

