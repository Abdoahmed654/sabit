import 'package:sapit/features/daily/domain/entities/azkar_group.dart';
import 'package:sapit/features/daily/domain/repositories/daily_repository.dart';

class GetAzkarGroup {
  final DailyRepository repository;

  GetAzkarGroup(this.repository);

  Future<AzkarGroup> call(String groupId) async {
    return await repository.getAzkarGroup(groupId);
  }
}

