import 'package:sapit/features/daily/domain/entities/daily_action.dart';
import 'package:sapit/features/daily/domain/entities/daily_quote.dart';
import 'package:sapit/features/daily/domain/entities/prayer_times.dart';
import 'package:sapit/features/daily/domain/entities/azkar_group.dart';
import 'package:sapit/features/daily/domain/entities/azkar.dart';
import 'package:sapit/features/daily/domain/entities/azkar_completion.dart';

abstract class DailyRepository {
  Future<DailyQuote> getDailyQuote();
  Future<PrayerTimes> getPrayerTimes({
    required double latitude,
    required double longitude,
    String? date,
  });
  Future<List<DailyAction>> getTodayActions();
  Future<List<DailyAction>> getUserActions({int days = 7});
  Future<DailyAction> recordAction({
    required String actionType,
    Map<String, dynamic>? metadata,
  });

  // Prayer Completion
  Future<Map<String, dynamic>> completePrayer({
    required String prayerName,
    bool onTime = false,
  });
  Future<Map<String, dynamic>> getTodayPrayers();

  // Azkar Groups
  Future<List<AzkarGroup>> getAzkarGroups({AzkarCategory? category});
  Future<AzkarGroup> getAzkarGroup(String groupId);

  // Azkar Completions
  Future<Map<String, dynamic>> completeAzkar(String azkarId);
  Future<List<AzkarCompletion>> getAzkarCompletions({String? groupId});

  // Fasting
  Future<Map<String, dynamic>> completeFasting(String fastingType);
}
