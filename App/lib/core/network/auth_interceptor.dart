import 'package:dio/dio.dart';
import 'package:sapit/core/storage/auth_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  bool _isRefreshing = false;

  AuthInterceptor(this._dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for login, register, and refresh endpoints
    if (options.path.contains('/auth/login') ||
        options.path.contains('/auth/register') ||
        options.path.contains('/auth/refresh')) {
      return handler.next(options);
    }

    final token = await AuthStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only handle 401 errors
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Prevent multiple refresh attempts
    if (_isRefreshing) {
      return handler.next(err);
    }

    _isRefreshing = true;

    try {
      // Try to refresh the token
      final refreshToken = await AuthStorage.getRefreshToken();
      if (refreshToken == null) {
        _isRefreshing = false;
        return handler.next(err);
      }

      // Make refresh request
      final response = await _dio.post('/auth/refresh');

      final newAccessToken = response.data['accessToken'];
      final newRefreshToken = response.data['refreshToken'];

      if (newAccessToken != null && newRefreshToken != null) {
        await AuthStorage.saveToken(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        // Retry the original request
        final retryRequest = err.requestOptions;
        retryRequest.headers['Authorization'] = 'Bearer $newAccessToken';

        final retryResponse = await _dio.fetch(retryRequest);
        _isRefreshing = false;
        return handler.resolve(retryResponse);
      }
    } catch (e) {
      await AuthStorage.clearTokens();
      _isRefreshing = false;
      return handler.next(err);
    }

    _isRefreshing = false;
    return handler.next(err);
  }
}