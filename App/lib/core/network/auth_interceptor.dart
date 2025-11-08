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
    // 🔸 Skip auth for login, register, or refresh endpoints
    if (options.path.contains('/auth/login') ||
        options.path.contains('/auth/register') ||
        options.path.contains('/auth/refresh') ||
        options.extra['skipAuth'] == true) {
      return handler.next(options);
    }

    final token = await AuthStorage.getAccessToken();
    print(token);
    print("hello");
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only handle 401 (Unauthorized)
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    try {
      final refreshToken = await AuthStorage.getRefreshToken();
      if (refreshToken == null) {
        return handler.next(err);
      }

      // 🔸 Skip auth for refresh request to avoid infinite loop
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(extra: {'skipAuth': true}),
      );

      final newAccessToken = response.data['accessToken'];
      final newRefreshToken = response.data['refreshToken'];

      if (newAccessToken != null && newRefreshToken != null) {
        await AuthStorage.saveToken(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        // 🔹 Clone and safely retry the original request
        final retryResponse = await _dio.request(
          err.requestOptions.path,
          data: err.requestOptions.data,
          queryParameters: err.requestOptions.queryParameters,
          options: Options(
            method: err.requestOptions.method,
            headers: {
              ...err.requestOptions.headers,
              'Authorization': 'Bearer $newAccessToken',
            },
            responseType: err.requestOptions.responseType,
            contentType: err.requestOptions.contentType,
            followRedirects: err.requestOptions.followRedirects,
            validateStatus: err.requestOptions.validateStatus,
          ),
        );

        return handler.resolve(retryResponse);
      }
    } catch (e) {
      await AuthStorage.clearTokens();
      return handler.next(err);
    }

    return handler.next(err);
  }
}
