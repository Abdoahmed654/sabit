import 'package:sapit/features/daily/domain/repositories/daily_repository.dart';

class CompleteAzkar {
  final DailyRepository repository;

  CompleteAzkar(this.repository);

  Future<Map<String, dynamic>> call(String azkarId) async {
    return await repository.completeAzkar(azkarId);
  }
}

