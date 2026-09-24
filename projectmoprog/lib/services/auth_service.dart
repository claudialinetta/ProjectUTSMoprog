import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';
import 'notification_service.dart';

class AuthService {
  static const _sessionKey = 'current_user';
  final SupabaseClient _supabase = Supabase.instance.client;

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

    try {
      final notificationService = NotificationService();
      await notificationService.createNotification(
        ownerId: user.id,
        title: 'Login Berhasil',
        message: 'Terdapat aktivitas login baru pada akun Anda menggunakan perangkat ini.',
        type: 'login',
      );
    } catch (e) {
      debugPrint('Gagal membuat notifikasi login: $e');
    }

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
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_sessionKey);
      if (raw == null) return null;

      final localUser = UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);

      final data = await _supabase
          .from('users')
          .select()
          .eq('phone_number', localUser.phoneNumber)
          .maybeSingle();

      if (data != null) {
        final updatedUser = UserModel(
          id: data['id']?.toString() ?? localUser.id,
          name: data['name'] ?? localUser.name,
          phoneNumber: data['phone_number'] ?? localUser.phoneNumber,
          dateOfBirth: data['date_of_birth'],
        );
        
        await _saveSession(updatedUser);
        return updatedUser;
      }
      
      return localUser;
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_sessionKey);
      if (raw == null) return null;
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    }
  }

  Future<void> updateCurrentUser(UserModel user) async {
    await _saveSession(user);
    
    await _supabase.from('users').upsert({
      'id': user.id,
      'name': user.name,
      'phone_number': user.phoneNumber,
      'date_of_birth': user.dateOfBirth,
    });
  }

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
