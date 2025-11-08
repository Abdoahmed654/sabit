import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sapit/core/network/dio_client.dart';
import 'package:sapit/core/services/websocket_service.dart';
import 'package:sapit/features/auth/data/repositories/auth_repo_impl.dart';
import 'package:sapit/features/auth/data/usecases/login_usecase.dart';
import 'package:sapit/features/auth/data/usecases/logout_usecase.dart';
import 'package:sapit/features/auth/data/usecases/register_usecase.dart';
import 'package:sapit/features/auth/domain/repositories/auth_repo.dart';
import 'package:sapit/features/auth/presentation/state/auth_bloc.dart';
import 'package:sapit/features/challenges/data/datasources/challenges_remote_datasource.dart';
import 'package:sapit/features/challenges/data/repositories/challenges_repository_impl.dart';
import 'package:sapit/features/challenges/domain/repositories/challenges_repository.dart';
import 'package:sapit/features/challenges/presentation/bloc/challenges_bloc.dart';
import 'package:sapit/features/chat/data/datasources/chat_local_datasource.dart';
import 'package:sapit/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:sapit/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:sapit/features/chat/domain/repositories/chat_repository.dart';
import 'package:sapit/features/chat/domain/usecases/get_all_groups_usecase.dart';
import 'package:sapit/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:sapit/features/chat/domain/usecases/leave_group_usecase.dart';
import 'package:sapit/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:sapit/features/daily/data/datasources/daily_remote_datasource.dart';
import 'package:sapit/features/daily/data/repositories/daily_repository_impl.dart';
import 'package:sapit/features/daily/domain/repositories/daily_repository.dart';
import 'package:sapit/features/daily/domain/usecases/get_azkar_groups.dart';
import 'package:sapit/features/daily/domain/usecases/get_azkar_group.dart';
import 'package:sapit/features/daily/domain/usecases/complete_azkar.dart';
import 'package:sapit/features/daily/domain/usecases/get_azkar_completions.dart';
import 'package:sapit/features/daily/domain/usecases/complete_fasting.dart';
import 'package:sapit/features/daily/domain/usecases/get_fasting_status.dart';
import 'package:sapit/features/daily/presentation/bloc/daily_bloc.dart';
import 'package:sapit/features/daily/presentation/bloc/good_deeds_bloc.dart';
import 'package:sapit/features/friends/data/datasources/friends_remote_datasource.dart';
import 'package:sapit/features/friends/data/repositories/friends_repository_impl.dart';
import 'package:sapit/features/friends/domain/repositories/friends_repository.dart';
import 'package:sapit/features/friends/domain/usecases/accept_friend_request_usecase.dart';
import 'package:sapit/features/friends/domain/usecases/block_friend_request_usecase.dart';
import 'package:sapit/features/friends/domain/usecases/block_friend_usecase.dart';
import 'package:sapit/features/friends/domain/usecases/get_friends_usecase.dart';
import 'package:sapit/features/friends/domain/usecases/get_pending_requests_usecase.dart';
import 'package:sapit/features/friends/domain/usecases/search_user_usecase.dart';
import 'package:sapit/features/friends/domain/usecases/send_friend_request_usecase.dart';
import 'package:sapit/features/friends/domain/usecases/unfriend_usecase.dart';
import 'package:sapit/features/friends/presentation/bloc/friends_bloc.dart';
import 'package:sapit/features/leaderboard/data/datasources/leaderboard_remote_datasource.dart';
import 'package:sapit/features/leaderboard/data/repositories/leaderboard_repository_impl.dart';
import 'package:sapit/features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:sapit/features/leaderboard/presentation/bloc/leaderboard_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Initialize Hive
  await Hive.initFlutter();

  // Dio client
  sl.registerLazySingleton<Dio>(() => DioClient.createDio());

  // WebSocket Service (Singleton)
  sl.registerLazySingleton<WebSocketService>(() => WebSocketService());

  // Repository
  sl.registerLazySingleton<AuthRepo>(() => AuthRepoImpl(sl()));

  // Usecases
  sl.registerLazySingleton(() => LoginUsecase(sl()));
  sl.registerLazySingleton(() => RegisterUsecase(sl()));
  sl.registerLazySingleton(() => LogoutUsecase(sl()));

  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
    ),
  );

  // ========== Chat Feature ==========

  // Data sources
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ChatLocalDataSource>(
    () => ChatLocalDataSourceImpl(),
  );

  // Repositories
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(sl(), sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAllGroupsUsecase(sl()));
  sl.registerLazySingleton(() => GetMessagesUsecase(sl()));
  sl.registerLazySingleton(() => LeaveGroupUsecase(sl()));

  // BLoC
  sl.registerFactory(
    () => ChatBloc(
      chatRepository: sl(),
      webSocketService: sl(),
      localDataSource: sl(),
      leaveGroupUsecase: sl(),
    ),
  );

  // ========== Friends Feature ==========

  // Data sources
  sl.registerLazySingleton<FriendsRemoteDataSource>(
    () => FriendsRemoteDataSourceImpl(sl<Dio>()),
  );

  // Repositories
  sl.registerLazySingleton<FriendsRepository>(
    () => FriendsRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => SearchUserUsecase(sl()));
  sl.registerLazySingleton(() => SendFriendRequestUsecase(sl()));
  sl.registerLazySingleton(() => GetPendingRequestsUsecase(sl()));
  sl.registerLazySingleton(() => AcceptFriendRequestUsecase(sl()));
  sl.registerLazySingleton(() => BlockFriendRequestUsecase(sl()));
  sl.registerLazySingleton(() => GetFriendsUsecase(sl()));
  sl.registerLazySingleton(() => UnfriendUsecase(sl()));
  sl.registerLazySingleton(() => BlockFriendUsecase(sl()));

  // BLoC
  sl.registerFactory(
    () => FriendsBloc(
      searchUserUsecase: sl(),
      sendFriendRequestUsecase: sl(),
      getPendingRequestsUsecase: sl(),
      acceptFriendRequestUsecase: sl(),
      blockFriendRequestUsecase: sl(),
      getFriendsUsecase: sl(),
      unfriendUsecase: sl(),
      blockFriendUsecase: sl(),
    ),
  );

  // ========== Daily Feature ==========

  // Data sources
  sl.registerLazySingleton<DailyRemoteDataSource>(
    () => DailyRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<DailyRepository>(
    () => DailyRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAzkarGroups(sl()));
  sl.registerLazySingleton(() => GetAzkarGroup(sl()));
  sl.registerLazySingleton(() => CompleteAzkar(sl()));
  sl.registerLazySingleton(() => GetAzkarCompletions(sl()));
  sl.registerLazySingleton(() => CompleteFasting(sl()));
  sl.registerLazySingleton(() => GetFastingStatus(sl()));

  // BLoC
  sl.registerFactory(() => DailyBloc(repository: sl()));
  sl.registerFactory(() => GoodDeedsBloc(
        getAzkarGroups: sl(),
        getAzkarGroup: sl(),
        completeAzkar: sl(),
        getAzkarCompletions: sl(),
        completeFasting: sl(),
        getFastingStatus: sl(),
      ));

  // ========== Challenges Feature ==========

  // Data sources
  sl.registerLazySingleton<ChallengesRemoteDataSource>(
    () => ChallengesRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<ChallengesRepository>(
    () => ChallengesRepositoryImpl(sl()),
  );

  // BLoC
  sl.registerFactory(() => ChallengesBloc(repository: sl()));

  // ========== Leaderboard Feature ==========

  // Data sources
  sl.registerLazySingleton<LeaderboardRemoteDataSource>(
    () => LeaderboardRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<LeaderboardRepository>(
    () => LeaderboardRepositoryImpl(sl()),
  );

  // BLoC
  sl.registerFactory(() => LeaderboardBloc(repository: sl()));
}
