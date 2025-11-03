import 'package:dio/dio.dart';
import 'package:sapit/core/network/dio_client.dart';
import 'package:sapit/core/storage/auth_storage.dart';

class AuthReposotory  {
  final Dio _dio = DioClient.createDio();
  Future<bool>refreshToken()async{
    final refreshToken = await AuthStorage.getRefreshToken();
    if (refreshToken== null) {
      return false;
    }
    try {
      final res = await _dio.post('/auth/refresh',data: {"refreshToken":refreshToken});
      final newaccessToken  = res.data['accessToken'];
      final newrefreshToken  = res.data['refreshToken'];
      if (newaccessToken!=null&&newrefreshToken!=null) {
        await AuthStorage.saveToken(accessToken: newaccessToken, refreshToken: newrefreshToken);
        return true;
      }
    } catch (e) {
      await AuthStorage.clearTokens();
    }

    return false;
  }
}