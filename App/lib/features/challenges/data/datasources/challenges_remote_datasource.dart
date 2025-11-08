import 'package:dio/dio.dart';
import 'package:sapit/features/challenges/data/models/challenge_model.dart';
import 'package:sapit/features/challenges/data/models/challenge_progress_model.dart';

abstract class ChallengesRemoteDataSource {
  Future<List<ChallengeModel>> getAllChallenges();
  Future<ChallengeModel> getChallengeById(String id);
  Future<ChallengeProgressModel> joinChallenge(String challengeId);
  Future<List<ChallengeProgressModel>> getUserChallenges();
}

class ChallengesRemoteDataSourceImpl implements ChallengesRemoteDataSource {
  final Dio dio;

  ChallengesRemoteDataSourceImpl(this.dio);

  @override
  Future<List<ChallengeModel>> getAllChallenges() async {
    try {
      final response = await dio.get('/challenges');
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => ChallengeModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get challenges');
    }
  }

  @override
  Future<ChallengeModel> getChallengeById(String id) async {
    try {
      final response = await dio.get('/challenges/$id');
      return ChallengeModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get challenge');
    }
  }

  @override
  Future<ChallengeProgressModel> joinChallenge(String challengeId) async {
    try {
      final response = await dio.post('/challenges/$challengeId/join');
      return ChallengeProgressModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to join challenge');
    }
  }

  @override
  Future<List<ChallengeProgressModel>> getUserChallenges() async {
    try {
      final response = await dio.get('/challenges/user/my-challenges');
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => ChallengeProgressModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get user challenges');
    }
  }
}

