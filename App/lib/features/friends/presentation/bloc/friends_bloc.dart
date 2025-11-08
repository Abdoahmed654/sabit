import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapit/core/usecases/Usecase.dart';
import 'package:sapit/core/services/websocket_service.dart';
import 'package:sapit/features/friends/domain/usecases/accept_friend_request_usecase.dart';
import 'package:sapit/features/friends/domain/usecases/block_friend_request_usecase.dart';
import 'package:sapit/features/friends/domain/usecases/block_friend_usecase.dart';
import 'package:sapit/features/friends/domain/usecases/get_friends_usecase.dart';
import 'package:sapit/features/friends/domain/usecases/get_pending_requests_usecase.dart';
import 'package:sapit/features/friends/domain/usecases/search_user_usecase.dart';
import 'package:sapit/features/friends/domain/usecases/send_friend_request_usecase.dart';
import 'package:sapit/features/friends/domain/usecases/unfriend_usecase.dart';
import 'package:sapit/features/friends/presentation/bloc/friends_event.dart';
import 'package:sapit/features/friends/presentation/bloc/friends_state.dart';

class FriendsBloc extends Bloc<FriendsEvent, FriendsState> {
  final SearchUserUsecase searchUserUsecase;
  final SendFriendRequestUsecase sendFriendRequestUsecase;
  final GetPendingRequestsUsecase getPendingRequestsUsecase;
  final AcceptFriendRequestUsecase acceptFriendRequestUsecase;
  final BlockFriendRequestUsecase blockFriendRequestUsecase;
  final GetFriendsUsecase getFriendsUsecase;
  final UnfriendUsecase unfriendUsecase;
  final BlockFriendUsecase blockFriendUsecase;
  final WebSocketService _webSocketService = WebSocketService();

  FriendsBloc({
    required this.searchUserUsecase,
    required this.sendFriendRequestUsecase,
    required this.getPendingRequestsUsecase,
    required this.acceptFriendRequestUsecase,
    required this.blockFriendRequestUsecase,
    required this.getFriendsUsecase,
    required this.unfriendUsecase,
    required this.blockFriendUsecase,
  }) : super(const FriendsInitial()) {
    on<SearchUserEvent>(_onSearchUser);
    on<SendFriendRequestEvent>(_onSendFriendRequest);
    on<LoadPendingRequestsEvent>(_onLoadPendingRequests);
    on<AcceptFriendRequestEvent>(_onAcceptFriendRequest);
    on<BlockFriendRequestEvent>(_onBlockFriendRequest);
    on<LoadFriendsEvent>(_onLoadFriends);
    on<UnfriendEvent>(_onUnfriend);
    on<BlockFriendEvent>(_onBlockFriend);
    on<NewFriendRequestReceivedEvent>(_onNewFriendRequestReceived);
    on<FriendRequestAcceptedReceivedEvent>(_onFriendRequestAcceptedReceived);

    // Listen to WebSocket events
    _setupWebSocketListeners();
  }

  void _setupWebSocketListeners() {
    _webSocketService.onFriendRequest((data) {
      add(NewFriendRequestReceivedEvent(data as Map<String, dynamic>));
    });

    _webSocketService.onFriendRequestAccepted((data) {
      add(FriendRequestAcceptedReceivedEvent(data as Map<String, dynamic>));
    });
  }

  @override
  Future<void> close() {
    _webSocketService.offFriendRequest();
    _webSocketService.offFriendRequestAccepted();
    return super.close();
  }

  Future<void> _onSearchUser(SearchUserEvent event, Emitter<FriendsState> emit) async {
    emit(const FriendsLoading());

    final result = await searchUserUsecase.call(SearchUserParams(event.email));

    result.fold(
      (failure) {
        emit(FriendsError(failure.message));
      },
      (user) {
        emit(UserSearched(user));
      },
    );
  }

  Future<void> _onSendFriendRequest(SendFriendRequestEvent event, Emitter<FriendsState> emit) async {
    emit(const FriendsLoading());

    final result = await sendFriendRequestUsecase.call(SendFriendRequestParams(event.email));

    result.fold(
      (failure) {
        emit(FriendsError(failure.message));
      },
      (request) {
        emit(const FriendRequestSent('Friend request sent successfully!'));
      },
    );
  }

  Future<void> _onLoadPendingRequests(LoadPendingRequestsEvent event, Emitter<FriendsState> emit) async {
    emit(const FriendsLoading());

    final result = await getPendingRequestsUsecase.call(NoParams());

    result.fold(
      (failure) {
        emit(FriendsError(failure.message));
      },
      (requests) {
        emit(PendingRequestsLoaded(requests));
      },
    );
  }

  Future<void> _onAcceptFriendRequest(AcceptFriendRequestEvent event, Emitter<FriendsState> emit) async {
    emit(const FriendsLoading());

    final result = await acceptFriendRequestUsecase.call(AcceptFriendRequestParams(event.friendshipId));

    result.fold(
      (failure) {
        emit(FriendsError(failure.message));
      },
      (request) {
        emit(const FriendRequestAccepted('Friend request accepted!'));
        // Reload pending requests
        add(const LoadPendingRequestsEvent());
      },
    );
  }

  Future<void> _onBlockFriendRequest(BlockFriendRequestEvent event, Emitter<FriendsState> emit) async {
    emit(const FriendsLoading());

    final result = await blockFriendRequestUsecase.call(BlockFriendRequestParams(event.friendshipId));

    result.fold(
      (failure) {
        emit(FriendsError(failure.message));
      },
      (request) {
        emit(const FriendRequestBlocked('Friend request blocked!'));
        // Reload pending requests
        add(const LoadPendingRequestsEvent());
      },
    );
  }

  Future<void> _onLoadFriends(LoadFriendsEvent event, Emitter<FriendsState> emit) async {
    emit(const FriendsLoading());

    final result = await getFriendsUsecase.call(NoParams());

    result.fold(
      (failure) {
        emit(FriendsError(failure.message));
      },
      (friends) {
        emit(FriendsLoaded(friends));
      },
    );
  }

  Future<void> _onUnfriend(UnfriendEvent event, Emitter<FriendsState> emit) async {
    emit(const FriendsLoading());

    final result = await unfriendUsecase.call(UnfriendParams(event.friendId));

    result.fold(
      (failure) {
        emit(FriendsError(failure.message));
      },
      (_) {
        emit(const FriendUnfriended('Friend removed successfully!'));
        // Reload friends list
        add(const LoadFriendsEvent());
      },
    );
  }

  Future<void> _onBlockFriend(BlockFriendEvent event, Emitter<FriendsState> emit) async {
    emit(const FriendsLoading());

    final result = await blockFriendUsecase.call(BlockFriendParams(event.friendId));

    result.fold(
      (failure) {
        emit(FriendsError(failure.message));
      },
      (_) {
        emit(const FriendBlocked('Friend blocked successfully!'));
        // Reload friends list
        add(const LoadFriendsEvent());
      },
    );
  }

  void _onNewFriendRequestReceived(
    NewFriendRequestReceivedEvent event,
    Emitter<FriendsState> emit,
  ) {
    // Reload pending requests when a new friend request is received
    add(const LoadPendingRequestsEvent());
  }

  void _onFriendRequestAcceptedReceived(
    FriendRequestAcceptedReceivedEvent event,
    Emitter<FriendsState> emit,
  ) {
    // Reload friends list when a friend request is accepted
    add(const LoadFriendsEvent());
  }
}

