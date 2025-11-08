import 'package:sapit/features/daily/domain/repositories/daily_repository.dart';

class CompleteFasting {
  final DailyRepository repository;

  CompleteFasting(this.repository);

  Future<Map<String, dynamic>> call(String fastingType) async {
    return await repository.completeFasting(fastingType);
  }
}

