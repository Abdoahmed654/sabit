import 'package:dio/dio.dart';
import 'package:sapit/core/storage/auth_storage.dart';
import 'package:sapit/features/Auth/data/repositories/Auth_reposotory.dart';

class AuthInterceptor extends Interceptor {
  final _authRepo = AuthReposotory();
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async{
    final token = await  AuthStorage.getAccessToken();
    if (token!=null) {
      options.headers['Authorization']='Bearer $token';
    }
    return handler.next(options);
  }
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async{
    if (err.response?.statusCode!=401) {
      return handler.next(err);
    }
    final refreshed = await _authRepo.refreshToken();
    if (!refreshed) {
        return handler.next(err);
    }
        final newToken = await AuthStorage.getAccessToken();
        final retryRequest = err.requestOptions;
        if (newToken!=null) {
          retryRequest.headers['Authorization']='Bearer $newToken';
        }
        final dio = Dio(
        BaseOptions(
        baseUrl: 'http://localhost:3000',
        responseType: ResponseType.json,
        headers: {'Content-Type': 'application/json'},     
    )
  );
        final retryResponse = await dio.fetch(retryRequest);
        return handler.resolve(retryResponse);
  }
}