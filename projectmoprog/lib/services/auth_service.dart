import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class AuthService {
  static const _sessionKey = 'current_user';

  Future<UserModel> login({
    required String phoneNumber,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (phoneNumber.trim().isEmpty || password.trim().isEmpty) {
      throw AuthException('Phone number and password are required.');
    }
    if (password.length < 4) {
      throw AuthException('Password must be at least 4 characters.');
    }

    final user = UserModel(
      id: phoneNumber.trim(),
      name: 'GetContact User',
      phoneNumber: phoneNumber.trim(),
    );
    await _saveSession(user);
    return user;
  }

  Future<UserModel> register({
    required String name,
    required String phoneNumber,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (name.trim().isEmpty || phoneNumber.trim().isEmpty) {
      throw AuthException('Name and phone number are required.');
    }
    if (password.length < 4) {
      throw AuthException('Password must be at least 4 characters.');
    }

    final user = UserModel(
      id: phoneNumber.trim(),
      name: name.trim(),
      phoneNumber: phoneNumber.trim(),
    );
    await _saveSession(user);
    return user;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey);
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> updateCurrentUser(UserModel user) => _saveSession(user);

  Future<void> _saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(user.toJson()));
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
