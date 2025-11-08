import 'package:sapit/features/daily/domain/entities/azkar_completion.dart';
import 'package:sapit/features/daily/domain/repositories/daily_repository.dart';

class GetAzkarCompletions {
  final DailyRepository repository;

  GetAzkarCompletions(this.repository);

  Future<List<AzkarCompletion>> call({String? groupId}) async {
    return await repository.getAzkarCompletions(groupId: groupId);
  }
}

