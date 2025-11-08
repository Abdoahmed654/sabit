import 'package:sapit/features/daily/domain/entities/fasting_completion.dart';
import 'package:sapit/features/daily/domain/repositories/daily_repository.dart';

class GetFastingStatus {
  final DailyRepository repository;

  GetFastingStatus(this.repository);

  Future<FastingStatus> call() async {
    return await repository.getTodayFastingStatus();
  }
}

