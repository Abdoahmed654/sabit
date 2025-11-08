import 'package:dartz/dartz.dart';
import 'package:sapit/core/error/failures.dart';
import 'package:sapit/core/usecases/Usecase.dart';
import 'package:sapit/features/chat/domain/entities/chat_group.dart';
import 'package:sapit/features/chat/domain/repositories/chat_repository.dart';

class GetAllGroupsUsecase implements UseCase<List<ChatGroup>, NoParams> {
  final ChatRepository repository;

  GetAllGroupsUsecase(this.repository);

  @override
  Future<Either<Failure, List<ChatGroup>>> call(NoParams params) async {
    return await repository.getAllGroups();
  }
}

