import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapit/core/storage/auth_storage.dart';
import 'package:sapit/core/usecases/Usecase.dart';
import 'package:sapit/features/auth/data/usecases/login_usecase.dart';
import 'package:sapit/features/auth/data/usecases/logout_usecase.dart';
import 'package:sapit/features/auth/data/usecases/register_usecase.dart';
import 'package:sapit/features/auth/presentation/state/auth_event.dart';
import 'package:sapit/features/auth/presentation/state/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase loginUseCase;
  final RegisterUsecase registerUseCase;
  final LogoutUsecase logoutUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
  }) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await loginUseCase.call(LoginParams(
      email: event.email,
      password: event.password,
    ));

    result.fold(
      (failure) {
        emit(AuthFailure(failure.message));
      },
      (user) {
        emit(AuthSuccess(user));
      },
    );
  }

  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await registerUseCase.call(RegisterParams(
      email: event.email,
      password: event.password,
      name: event.name,
    ));

    result.fold(
      (failure) {
        emit(AuthFailure(failure.message));
      },
      (user) {
        emit(AuthSuccess(user));
      },
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    final result = await logoutUseCase.call(NoParams());

    result.fold(
      (failure) {
        // Even if logout fails, clear local state
        emit(AuthLoggedOut());
      },
      (_) {
        emit(AuthLoggedOut());
      },
    );
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final accessToken = await AuthStorage.getAccessToken();
    final refreshToken = await AuthStorage.getRefreshToken();

    if (accessToken == null && refreshToken == null) {
      emit(AuthLoggedOut());
    } else {
      // Token exists, user is logged in
      // In a real app, you might want to validate the token or fetch user data
      emit(AuthLoggedOut()); // For now, require re-login
    }
  }
}
