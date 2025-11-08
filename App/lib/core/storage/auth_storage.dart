import 'package:hive/hive.dart';

class AuthStorage {
  static final String _boxName = "AuthBox";
  static String? _accessToken;
  static String? _userId;

  static Future<void> saveToken({
    required String accessToken,
    required String refreshToken,
    String? userId,
  }) async {
    _accessToken = accessToken;
    _userId = userId;
    final box = await Hive.openBox(_boxName);
    await box.put("refreshToken", refreshToken);
    if (userId != null) {
      await box.put("userId", userId);
    }
  }

  static Future<String?> getAccessToken() async {
    return _accessToken;
  }

  static Future<String?> getRefreshToken() async {
    final box = await Hive.openBox(_boxName);
    return await box.get('refreshToken');
  }

  static Future<String?> getUserId() async {
    if (_userId != null) return _userId;
    final box = await Hive.openBox(_boxName);
    _userId = await box.get('userId');
    return _userId;
  }

  static Future<void> clearTokens() async {
    _accessToken = null;
    _userId = null;
    final box = await Hive.openBox(_boxName);
    await box.delete('refreshToken');
    await box.delete('userId');
  }
}