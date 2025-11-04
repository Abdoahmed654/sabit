import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sapit/core/network/dio_client.dart';
import 'package:sapit/features/auth/data/repositories/auth_repo_impl.dart';
import 'package:sapit/features/auth/data/usecases/login_usecase.dart';
import 'package:sapit/features/auth/data/usecases/logout_usecase.dart';
import 'package:sapit/features/auth/data/usecases/register_usecase.dart';
import 'package:sapit/features/auth/domain/repositories/auth_repo.dart';
import 'package:sapit/features/auth/presentation/state/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Initialize Hive
  await Hive.initFlutter();

  // Dio client
  sl.registerLazySingleton<Dio>(() => DioClient.createDio());

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
}
