import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sapit/core/error/failures.dart';
import 'package:sapit/core/usecases/Usecase.dart';
import 'package:sapit/features/chat/domain/entities/message.dart';
import 'package:sapit/features/chat/domain/repositories/chat_repository.dart';

class GetMessagesUsecase implements UseCase<List<Message>, GetMessagesParams> {
  final ChatRepository repository;

  GetMessagesUsecase(this.repository);

  @override
  Future<Either<Failure, List<Message>>> call(GetMessagesParams params) async {
    return await repository.getMessages(
      groupId: params.groupId,
      limit: params.limit,
    );
  }
}

class GetMessagesParams extends Equatable {
  final String groupId;
  final int limit;

  const GetMessagesParams({
    required this.groupId,
    this.limit = 50,
  });

  @override
  List<Object?> get props => [groupId, limit];
}

