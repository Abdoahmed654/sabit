import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapit/core/storage/auth_storage.dart';
import 'package:sapit/features/auth/data/usecases/login_usecase.dart';
import 'package:sapit/features/auth/data/usecases/logout_usecase.dart';
import 'package:sapit/features/auth/data/usecases/register_usecase.dart';
import 'package:sapit/features/auth/presentation/state/auth_event.dart';
import 'package:sapit/features/auth/presentation/state/auth_state.dart';
import 'package:sapit/router/app_router.dart';

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
    try {
      final user = await loginUseCase.call(LoginParams(
        email: event.email,
        password: event.password,
      ));
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure(_getErrorMessage(e)));
    }
  }

  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await registerUseCase.call(RegisterParams(
        email: event.email,
        password: event.password,
        name: event.name,
      ));
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure(_getErrorMessage(e)));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      await logoutUseCase.call(null);
      emit(AuthLoggedOut());
    } catch (e) {
      // Even if logout fails, clear local state
      emit(AuthLoggedOut());
    }
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

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('DioException')) {
      if (error.toString().contains('401')) {
        return 'Invalid email or password';
      } else if (error.toString().contains('409')) {
        return 'User already exists';
      } else if (error.toString().contains('SocketException')) {
        return 'No internet connection';
      }
      return 'Network error. Please try again.';
    }
    return error.toString().replaceAll('Exception:', '').trim();
  }
}
