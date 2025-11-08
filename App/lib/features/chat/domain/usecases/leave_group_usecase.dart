import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sapit/core/error/failures.dart';
import 'package:sapit/features/chat/domain/repositories/chat_repository.dart';

class LeaveGroupUsecase {
  final ChatRepository repository;

  LeaveGroupUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(LeaveGroupParams params) async {
    return await repository.leaveGroup(params.groupId);
  }
}

class LeaveGroupParams extends Equatable {
  final String groupId;

  const LeaveGroupParams(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

