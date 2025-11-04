import 'package:hive/hive.dart';

class AuthStorage {
  static String _boxName = "AuthBox";
  static String? _accessToken;
  static Future<void> saveToken({required String accessToken,required String refreshToken}) async{
    _accessToken = accessToken;
    final box  = await Hive.openBox(_boxName);
    await box.put("refreshToken", refreshToken);
  }
  static Future<String?>getAccessToken() async{
    return _accessToken;
  }
  static Future<String?>getRefreshToken() async{
    final box = await Hive.openBox(_boxName);
    return await box.get('refreshToken');
  }
  static Future<void>clearTokens() async{
    _accessToken = null;
    final box = await Hive.openBox(_boxName);
    await box.delete('refreshToken');
  }
}