import 'package:sapit/features/daily/domain/entities/azkar_group.dart';
import 'package:sapit/features/daily/domain/repositories/daily_repository.dart';

class GetAzkarGroups {
  final DailyRepository repository;

  GetAzkarGroups(this.repository);

  Future<List<AzkarGroup>> call({AzkarCategory? category}) async {
    return await repository.getAzkarGroups(category: category);
  }
}

