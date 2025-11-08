import 'package:equatable/equatable.dart';

abstract class FriendsEvent extends Equatable {
  const FriendsEvent();

  @override
  List<Object?> get props => [];
}

class SearchUserEvent extends FriendsEvent {
  final String email;

  const SearchUserEvent(this.email);

  @override
  List<Object?> get props => [email];
}

class SendFriendRequestEvent extends FriendsEvent {
  final String email;

  const SendFriendRequestEvent(this.email);

  @override
  List<Object?> get props => [email];
}

class LoadPendingRequestsEvent extends FriendsEvent {
  const LoadPendingRequestsEvent();
}

class AcceptFriendRequestEvent extends FriendsEvent {
  final String friendshipId;

  const AcceptFriendRequestEvent(this.friendshipId);

  @override
  List<Object?> get props => [friendshipId];
}

class UnfriendEvent extends FriendsEvent {
  final String friendId;

  const UnfriendEvent(this.friendId);

  @override
  List<Object?> get props => [friendId];
}

class BlockFriendEvent extends FriendsEvent {
  final String friendId;

  const BlockFriendEvent(this.friendId);

  @override
  List<Object?> get props => [friendId];
}

class BlockFriendRequestEvent extends FriendsEvent {
  final String friendshipId;

  const BlockFriendRequestEvent(this.friendshipId);

  @override
  List<Object?> get props => [friendshipId];
}

class LoadFriendsEvent extends FriendsEvent {
  const LoadFriendsEvent();
}

class NewFriendRequestReceivedEvent extends FriendsEvent {
  final Map<String, dynamic> requestData;

  const NewFriendRequestReceivedEvent(this.requestData);

  @override
  List<Object?> get props => [requestData];
}

class FriendRequestAcceptedReceivedEvent extends FriendsEvent {
  final Map<String, dynamic> data;

  const FriendRequestAcceptedReceivedEvent(this.data);

  @override
  List<Object?> get props => [data];
}

