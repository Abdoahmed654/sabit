import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sapit/core/error/failures.dart';
import 'package:sapit/core/usecases/Usecase.dart';
import 'package:sapit/features/friends/domain/entities/friend_request.dart';
import 'package:sapit/features/friends/domain/repositories/friends_repository.dart';

class SearchUserUsecase implements UseCase<UserInfo, SearchUserParams> {
  final FriendsRepository repository;

  SearchUserUsecase(this.repository);

  @override
  Future<Either<Failure, UserInfo>> call(SearchUserParams params) async {
    return await repository.searchUserByEmail(params.email);
  }
}

class SearchUserParams extends Equatable {
  final String email;

  const SearchUserParams(this.email);

  @override
  List<Object?> get props => [email];
}

