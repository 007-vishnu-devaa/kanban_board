import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static final AuthStorage _instance = AuthStorage._internal();
  late SharedPreferences _prefs;

  AuthStorage._internal();

  // Public factory to get the same instance
  factory AuthStorage() => _instance;

  static const _loggedInKey = 'logged_in';
  static const _userIdKey = 'user_id';
  static const _userEmailKey = 'user_email';


  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }


  Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool(_loggedInKey, value);
  }


Future<bool> isLoggedIn() async {
  return _prefs.getBool(_loggedInKey) ?? false;
}

Future<void> saveUser({
    required String id,
    required String email,
  }) async {
    await _prefs.setString(_userIdKey, id);
    await _prefs.setString(_userEmailKey, email);
  }

Future<void> clear() async {
    await _prefs.remove(_loggedInKey);
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_userEmailKey);
  }
}
