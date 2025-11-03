import 'package:dio/dio.dart';
import 'package:sapit/core/network/auth_interceptor.dart';

class DioClient {
  static Dio createDio(){
    
    Dio dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost:3000',
        responseType: ResponseType.json,
        headers: {'Content-Type': 'application/json'},     
    )
  );
  dio.interceptors.addAll([AuthInterceptor()]);
    return dio;
  }
}