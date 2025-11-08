import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sapit/core/error/failures.dart';
import 'package:sapit/core/usecases/Usecase.dart';
import 'package:sapit/features/chat/domain/entities/message.dart';
import 'package:sapit/features/chat/domain/repositories/chat_repository.dart';

class SendMessageUsecase implements UseCase<Message, SendMessageParams> {
  final ChatRepository repository;

  SendMessageUsecase(this.repository);

  @override
  Future<Either<Failure, Message>> call(SendMessageParams params) async {
    return await repository.sendMessage(
      groupId: params.groupId,
      content: params.content,
    );
  }
}

class SendMessageParams extends Equatable {
  final String groupId;
  final String content;

  const SendMessageParams({
    required this.groupId,
    required this.content,
  });

  @override
  List<Object?> get props => [groupId, content];
}

