import 'package:dio/dio.dart';
import 'package:sapit/features/leaderboard/data/models/leaderboard_entry_model.dart';

abstract class LeaderboardRemoteDataSource {
  Future<List<LeaderboardEntryModel>> getXpLeaderboard({int limit = 100});
  Future<List<LeaderboardEntryModel>> getCoinsLeaderboard({int limit = 100});
  Future<List<LeaderboardEntryModel>> getFriendsLeaderboard(String type);
}

class LeaderboardRemoteDataSourceImpl implements LeaderboardRemoteDataSource {
  final Dio dio;

  LeaderboardRemoteDataSourceImpl(this.dio);

  @override
  Future<List<LeaderboardEntryModel>> getXpLeaderboard({int limit = 100}) async {
    final response = await dio.get('/leaderboards/xp', queryParameters: {'limit': limit});
    final List<dynamic> data = response.data as List<dynamic>;
    return data.asMap().entries.map((entry) {
      return LeaderboardEntryModel.fromJson(
        entry.value as Map<String, dynamic>,
        entry.key + 1, // rank starts from 1
      );
    }).toList();
  }

  @override
  Future<List<LeaderboardEntryModel>> getCoinsLeaderboard({int limit = 100}) async {
    final response = await dio.get('/leaderboards/coins', queryParameters: {'limit': limit});
    final List<dynamic> data = response.data as List<dynamic>;
    return data.asMap().entries.map((entry) {
      return LeaderboardEntryModel.fromJson(
        entry.value as Map<String, dynamic>,
        entry.key + 1,
      );
    }).toList();
  }

  @override
  Future<List<LeaderboardEntryModel>> getFriendsLeaderboard(String type) async {
    final response = await dio.get('/leaderboards/friends', queryParameters: {'type': type});
    final List<dynamic> data = response.data as List<dynamic>;
    return data.asMap().entries.map((entry) {
      return LeaderboardEntryModel.fromJson(
        entry.value as Map<String, dynamic>,
        entry.key + 1,
      );
    }).toList();
  }
}

