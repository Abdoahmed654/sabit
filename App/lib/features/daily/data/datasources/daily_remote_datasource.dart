import 'package:dio/dio.dart';
import 'package:sapit/features/daily/data/models/daily_action_model.dart';
import 'package:sapit/features/daily/data/models/daily_quote_model.dart';
import 'package:sapit/features/daily/data/models/prayer_times_model.dart';
import 'package:sapit/features/daily/data/models/azkar_group_model.dart';
import 'package:sapit/features/daily/data/models/azkar_completion_model.dart';

abstract class DailyRemoteDataSource {
  Future<DailyQuoteModel> getDailyQuote();
  Future<PrayerTimesModel> getPrayerTimes({
    required double latitude,
    required double longitude,
    String? date,
  });
  Future<List<DailyActionModel>> getTodayActions();
  Future<List<DailyActionModel>> getUserActions({int days = 7});
  Future<DailyActionModel> recordAction({
    required String actionType,
    Map<String, dynamic>? metadata,
  });

  // Azkar Groups
  Future<List<AzkarGroupModel>> getAzkarGroups({String? category});
  Future<AzkarGroupModel> getAzkarGroup(String groupId);

  // Azkar Completions
  Future<Map<String, dynamic>> completeAzkar(String azkarId);
  Future<List<AzkarCompletionModel>> getAzkarCompletions({String? groupId});

  // Fasting
  Future<Map<String, dynamic>> completeFasting(String fastingType);
}

class DailyRemoteDataSourceImpl implements DailyRemoteDataSource {
  final Dio dio;

  DailyRemoteDataSourceImpl(this.dio);

  @override
  Future<DailyQuoteModel> getDailyQuote() async {
    try {
      final response = await dio.get('/daily/quote');
      return DailyQuoteModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get daily quote');
    }
  }

  @override
  Future<PrayerTimesModel> getPrayerTimes({
    required double latitude,
    required double longitude,
    String? date,
  }) async {
    try {
      final response = await dio.get(
        '/daily/prayer-times',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          if (date != null) 'date': date,
        },
      );
      return PrayerTimesModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get prayer times');
    }
  }

  @override
  Future<List<DailyActionModel>> getTodayActions() async {
    try {
      final response = await dio.get('/daily/actions/today');
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => DailyActionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get today actions');
    }
  }

  @override
  Future<List<DailyActionModel>> getUserActions({int days = 7}) async {
    try {
      final response = await dio.get(
        '/daily/actions',
        queryParameters: {'days': days},
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => DailyActionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get user actions');
    }
  }

  @override
  Future<DailyActionModel> recordAction({
    required String actionType,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await dio.post(
        '/daily/actions',
        data: {
          'actionType': actionType,
          if (metadata != null) 'metadata': metadata,
        },
      );
      return DailyActionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to record action');
    }
  }

  @override
  Future<List<AzkarGroupModel>> getAzkarGroups({String? category}) async {
    try {
      final response = await dio.get(
        '/daily/azkar-groups',
        queryParameters: {
          if (category != null) 'category': category,
        },
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => AzkarGroupModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get azkar groups');
    }
  }

  @override
  Future<AzkarGroupModel> getAzkarGroup(String groupId) async {
    try {
      final response = await dio.get('/daily/azkar-groups/$groupId');
      return AzkarGroupModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get azkar group');
    }
  }

  @override
  Future<Map<String, dynamic>> completeAzkar(String azkarId) async {
    try {
      final response = await dio.post(
        '/daily/azkars/complete',
        data: {'azkarId': azkarId},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to complete azkar');
    }
  }

  @override
  Future<List<AzkarCompletionModel>> getAzkarCompletions({String? groupId}) async {
    try {
      final response = await dio.get(
        '/daily/azkars/completions',
        queryParameters: {
          if (groupId != null) 'groupId': groupId,
        },
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => AzkarCompletionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get azkar completions');
    }
  }

  @override
  Future<Map<String, dynamic>> completeFasting(String fastingType) async {
    try {
      final response = await dio.post(
        '/daily/fasting/complete',
        data: {'fastingType': fastingType},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to complete fasting');
    }
  }

}