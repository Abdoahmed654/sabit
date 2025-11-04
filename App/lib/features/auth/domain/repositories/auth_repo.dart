import 'package:dio/dio.dart';
import 'package:sapit/features/auth/domain/entities/User.dart';

abstract class AuthRepo {
  final Dio dio;
  AuthRepo(this.dio);

  Future<bool> refreshToken();
  Future<bool> isAuthenticated();
  Future<User> login({
    required String email,
    required String password,
  });
  Future<User> register({
    required String email,
    required String password,
    required String name
  });
  Future<void> logout();
}