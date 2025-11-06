import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vibe_tuner/constants/app_paths.dart';
import 'package:vibe_tuner/constants/app_strings.dart';
import 'package:vibe_tuner/services/api_client.dart';

class AuthProvider extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const _keyToken = 'auth_token';
  static const _keyUser = 'auth_user';

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  String? _token;
  String? get token => _token;

  Map<String, dynamic>? _user;
  Map<String, dynamic>? get user => _user;

  bool _loading = false;
  bool get loading => _loading;

  AuthProvider() {
    _restoreFromStorage();
  }

  Future<void> _setLoading(bool v) async {
    _loading = v;
    notifyListeners();
  }

  Future<void> _saveTokenToStorage(String token, [Map<String, dynamic>? user]) async {
    await _secureStorage.write(key: _keyToken, value: token);
    if (user != null) await _secureStorage.write(key: _keyUser, value: jsonEncode(user));
  }

  Future<void> _clearStorage() async {
    await _secureStorage.delete(key: _keyToken);
    await _secureStorage.delete(key: _keyUser);
  }

  Future<void> _restoreFromStorage() async {
    final storedToken = await _secureStorage.read(key: _keyToken);
    final storedUserJson = await _secureStorage.read(key: _keyUser);
    if (storedToken != null) {
      _token = storedToken;
      try {
        if (storedUserJson != null) _user = jsonDecode(storedUserJson) as Map<String, dynamic>?;
      } catch (_) {}
      ApiClient.instance.setToken(_token);
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  Future<void> register({required String email, required String password}) async {
    await _setLoading(true);
    try {
      final body = {'email': email, 'password': password};
      await ApiClient.instance.post(AppPaths.register, body: body);
    } catch (e) {
      rethrow;
    } finally {
      await _setLoading(false);
    }
  }

  Future<void> login({required String email, required String password}) async {
    await _setLoading(true);
    try {
      final body = {'email': email, 'password': password};
      final res = await ApiClient.instance.post(AppPaths.login, body: body);
      final token = res['token'] as String?;
      final user = res['user'] as Map<String, dynamic>?;
      if (token == null) {
        throw ApiException(AppStrings.noTokenReturn);
      }
      _token = token;
      _user = user;
      _isLoggedIn = true;
      ApiClient.instance.setToken(_token);
      await _saveTokenToStorage(_token!, _user);
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      await _setLoading(false);
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _token = null;
    _user = null;
    notifyListeners();
    ApiClient.instance.setToken(null);
    await _clearStorage();
  }
}
