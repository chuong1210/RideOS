import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/models/user_model.dart';
import 'package:flutter_app/services/api_service.dart';

enum UserType { passenger, driver }

class AuthProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  final ApiService _apiService = ApiService();

  bool _isLoggedIn = false;
  UserModel? _currentUser;
  UserType _userType = UserType.passenger;
  String? _token;

  AuthProvider(this._prefs);

  bool get isLoggedIn => _isLoggedIn;
  UserModel? get currentUser => _currentUser;
  UserType get userType => _userType;
  String? get token => _token;

  Future<void> checkLoginStatus() async {
    final token = _prefs.getString('token');
    if (token != null && token.isNotEmpty) {
      _token = token;
      _isLoggedIn = true;

      final userTypeString = _prefs.getString('userType');
      _userType =
          userTypeString == 'driver' ? UserType.driver : UserType.passenger;

      try {
        final response = await _apiService.get('user/profile');
        if (response.success) {
          _currentUser = UserModel.fromJson(response.data);
        } else {
          // Token might be expired
          await logout();
        }
      } catch (e) {
        await logout();
      }
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password, UserType type) async {
    try {
      final response = await _apiService.post('auth/login', {
        'email': email,
        'password': password,
        'userType': type == UserType.driver ? 'driver' : 'passenger',
      });

      if (response.success) {
        _token = response.data['token'];
        _isLoggedIn = true;
        _userType = type;
        _currentUser = UserModel.fromJson(response.data['user']);

        await _prefs.setString('token', _token!);
        await _prefs.setString(
          'userType',
          type == UserType.driver ? 'driver' : 'passenger',
        );

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(
    String name,
    String email,
    String phone,
    String password,
    UserType type,
  ) async {
    try {
      final response = await _apiService.post('auth/register', {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'userType': type == UserType.driver ? 'driver' : 'passenger',
      });

      if (response.success) {
        _token = response.data['token'];
        _isLoggedIn = true;
        _userType = type;
        _currentUser = UserModel.fromJson(response.data['user']);

        await _prefs.setString('token', _token!);
        await _prefs.setString(
          'userType',
          type == UserType.driver ? 'driver' : 'passenger',
        );

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _currentUser = null;
    _token = null;

    await _prefs.remove('token');
    await _prefs.remove('userType');

    notifyListeners();
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('user/profile', data);

      if (response.success) {
        _currentUser = UserModel.fromJson(response.data);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      final response = await _apiService.post('auth/reset-password', {
        'email': email,
      });

      return response.success;
    } catch (e) {
      return false;
    }
  }
}
