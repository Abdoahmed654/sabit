import 'package:equatable/equatable.dart';
import 'package:sapit/features/friends/domain/entities/friend_request.dart';

abstract class FriendsState extends Equatable {
  const FriendsState();

  @override
  List<Object?> get props => [];
}

class FriendsInitial extends FriendsState {
  const FriendsInitial();
}

class FriendsLoading extends FriendsState {
  const FriendsLoading();
}

class UserSearched extends FriendsState {
  final UserInfo user;

  const UserSearched(this.user);

  @override
  List<Object?> get props => [user];
}

class FriendRequestSent extends FriendsState {
  final String message;

  const FriendRequestSent(this.message);

  @override
  List<Object?> get props => [message];
}

class PendingRequestsLoaded extends FriendsState {
  final List<FriendRequest> requests;

  const PendingRequestsLoaded(this.requests);

  @override
  List<Object?> get props => [requests];
}

class FriendRequestAccepted extends FriendsState {
  final String message;

  const FriendRequestAccepted(this.message);

  @override
  List<Object?> get props => [message];
}

class FriendRequestBlocked extends FriendsState {
  final String message;

  const FriendRequestBlocked(this.message);

  @override
  List<Object?> get props => [message];
}

class FriendUnfriended extends FriendsState {
  final String message;

  const FriendUnfriended(this.message);

  @override
  List<Object?> get props => [message];
}

class FriendBlocked extends FriendsState {
  final String message;

  const FriendBlocked(this.message);

  @override
  List<Object?> get props => [message];
}

class FriendsLoaded extends FriendsState {
  final List<UserInfo> friends;

  const FriendsLoaded(this.friends);

  @override
  List<Object?> get props => [friends];
}

class FriendsError extends FriendsState {
  final String message;

  const FriendsError(this.message);

  @override
  List<Object?> get props => [message];
}

