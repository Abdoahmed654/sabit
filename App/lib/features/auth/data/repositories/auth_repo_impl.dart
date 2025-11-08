import 'package:sapit/core/storage/auth_storage.dart';
import 'package:sapit/features/auth/data/models/UserModel.dart';
import 'package:sapit/features/auth/domain/entities/User.dart';
import 'package:sapit/features/auth/domain/repositories/auth_repo.dart';

class AuthRepoImpl extends AuthRepo  {
  AuthRepoImpl(super.dio);

  @override
  Future<bool> refreshToken() async {
    final refreshToken = await AuthStorage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final res = await dio.post('/auth/refresh');

      final newAccessToken = res.data['accessToken'];
      final newRefreshToken = res.data['refreshToken'];
      if (newAccessToken != null && newRefreshToken != null) {
        await AuthStorage.saveToken(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );
        return true;
      }
    } catch (e) {
      await AuthStorage.clearTokens();
      rethrow;
    }

    return false;
  }

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final res = await dio.post("/auth/login", data: {
      "email": email,
      "password": password
    });

    final newAccessToken = res.data['accessToken'];
    final newRefreshToken = res.data['refreshToken'];
    final user = UserModel.fromJson(res.data["user"] as Map<String, dynamic>);

    if (newAccessToken != null && newRefreshToken != null) {
      await AuthStorage.saveToken(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
        userId: user.id,
      );
    }

    return user;
  }

  @override
  Future<void> logout() async {
    try {
      await dio.post('/auth/logout');
      await AuthStorage.clearTokens();
    } catch (e) {
      await AuthStorage.clearTokens();
      rethrow;
    }
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final res = await dio.post("/auth/register", data: {
      "email": email,
      "password": password,
      "displayName": name,
    });

    final newAccessToken = res.data['accessToken'];
    final newRefreshToken = res.data['refreshToken'];
    final user = UserModel.fromJson(res.data["user"] as Map<String, dynamic>);

    if (newAccessToken != null && newRefreshToken != null) {
      await AuthStorage.saveToken(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
        userId: user.id,
      );
    }

    return user;
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await AuthStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}