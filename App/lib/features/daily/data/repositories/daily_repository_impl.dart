import 'package:sapit/features/daily/data/datasources/daily_remote_datasource.dart';
import 'package:sapit/features/daily/domain/entities/daily_action.dart';
import 'package:sapit/features/daily/domain/entities/daily_quote.dart';
import 'package:sapit/features/daily/domain/entities/prayer_times.dart';
import 'package:sapit/features/daily/domain/entities/azkar_group.dart';
import 'package:sapit/features/daily/domain/entities/azkar_completion.dart';
import 'package:sapit/features/daily/domain/repositories/daily_repository.dart';

class DailyRepositoryImpl implements DailyRepository {
  final DailyRemoteDataSource remoteDataSource;

  DailyRepositoryImpl(this.remoteDataSource);

  @override
  Future<DailyQuote> getDailyQuote() async {
    return await remoteDataSource.getDailyQuote();
  }

  @override
  Future<PrayerTimes> getPrayerTimes({
    required double latitude,
    required double longitude,
    String? date,
  }) async {
    return await remoteDataSource.getPrayerTimes(
      latitude: latitude,
      longitude: longitude,
      date: date,
    );
  }

  @override
  Future<List<DailyAction>> getTodayActions() async {
    return await remoteDataSource.getTodayActions();
  }

  @override
  Future<List<DailyAction>> getUserActions({int days = 7}) async {
    return await remoteDataSource.getUserActions(days: days);
  }

  @override
  Future<DailyAction> recordAction({
    required String actionType,
    Map<String, dynamic>? metadata,
  }) async {
    return await remoteDataSource.recordAction(
      actionType: actionType,
      metadata: metadata,
    );
  }

  @override
  Future<List<AzkarGroup>> getAzkarGroups({AzkarCategory? category}) async {
    final categoryString =
        category != null ? _categoryToString(category) : null;
    final models =
        await remoteDataSource.getAzkarGroups(category: categoryString);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<AzkarGroup> getAzkarGroup(String groupId) async {
    final model = await remoteDataSource.getAzkarGroup(groupId);
    return model.toEntity();
  }

  @override
  Future<Map<String, dynamic>> completeAzkar(String azkarId) async {
    return await remoteDataSource.completeAzkar(azkarId);
  }

  @override
  Future<List<AzkarCompletion>> getAzkarCompletions({String? groupId}) async {
    final models = await remoteDataSource.getAzkarCompletions(groupId: groupId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Map<String, dynamic>> completePrayer({
    required String prayerName,
    bool onTime = false,
  }) async {
    return await remoteDataSource.completePrayer(
      prayerName: prayerName,
      onTime: onTime,
    );
  }

  @override
  Future<Map<String, dynamic>> getTodayPrayers() async {
    return await remoteDataSource.getTodayPrayers();
  }

  @override
  Future<Map<String, dynamic>> completeFasting(String fastingType) async {
    return await remoteDataSource.completeFasting(fastingType);
  }

  String _categoryToString(AzkarCategory category) {
    switch (category) {
      case AzkarCategory.morning:
        return 'MORNING';
      case AzkarCategory.evening:
        return 'EVENING';
      case AzkarCategory.afterPrayer:
        return 'AFTER_PRAYER';
      case AzkarCategory.beforeSleep:
        return 'BEFORE_SLEEP';
      case AzkarCategory.general:
        return 'GENERAL';
    }
  }
}
