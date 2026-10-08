import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';
import 'notification_service.dart';

class AuthService {
  static const _sessionKey = 'current_user';
  final SupabaseClient _supabase = Supabase.instance.client;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password); 
    final digest = sha256.convert(bytes); 
    return digest.toString(); 
  }

  Future<UserModel> login({
    required String phoneNumber,
    required String password,
  }) async {
    final cleanPhone = phoneNumber.trim();
    final cleanPass = password.trim();

    if (cleanPhone.isEmpty || cleanPass.isEmpty) {
      throw AuthException('Phone number and password are required.');
    }
    if (cleanPass.length < 7) {
      throw AuthException('Password must be at least 8 characters.');
    }

    try {
      final data = await _supabase
          .from('users')
          .select()
          .eq('phone_number', cleanPhone)
          .maybeSingle();

      if (data == null) {
        throw AuthException('Phone number is not registered.');
      }

      final hashedInputPass = _hashPassword(cleanPass);
      if (data['password'] != hashedInputPass) {
        throw AuthException('Invalid password.');
      }

      final user = UserModel(
        id: data['id'].toString(),
        name: data['name'] ?? 'GetContact User',
        phoneNumber: data['phone_number'] ?? cleanPhone,
        dateOfBirth: data['date_of_birth'],
      );

      await _saveSession(user);

      try {
        final notificationService = NotificationService();
        await notificationService.createNotification(
          ownerId: user.id,
          title: 'Login Successful',
          message: 'There is a new login activity on your account using this device.',
          type: 'login',
        );
      } catch (e) {
        debugPrint('Failed to load login notification: $e');
      }

      return user;
    } on PostgrestException catch (e) {
      throw AuthException('Database Error: ${e.message}');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Login failed: $e');
    }
  }

  Future<UserModel> register({
    required String name,
    required String phoneNumber,
    required String password,
  }) async {
    final cleanName = name.trim();
    final cleanPhone = phoneNumber.trim();
    final cleanPass = password.trim();

    if (cleanName.isEmpty || cleanPhone.isEmpty) {
      throw AuthException('Name and phone number are required.');
    }
    if (cleanPass.length < 7) {
      throw AuthException('Password must be at least 8 characters.');
    }
    if (!RegExp(r'^\+?[0-9\s]+$').hasMatch(cleanPhone)) {
      throw AuthException('Phone number can only contain numbers');
    }

    try {
      final existingUser = await _supabase
          .from('users')
          .select('phone_number')
          .eq('phone_number', cleanPhone)
          .maybeSingle();

      if (existingUser != null) {
        throw AuthException('Phone number is already registered.');
      }

      final hashedPassword = _hashPassword(cleanPass);

      final insertedData = await _supabase.from('users').insert({
        'id': cleanPhone,
        'name': cleanName,
        'phone_number': cleanPhone,
        'password': hashedPassword,
        'date_of_birth': null,
      }).select().single();

      final user = UserModel(
        id: insertedData['id'].toString(),
        name: insertedData['name'] ?? cleanName,
        phoneNumber: insertedData['phone_number'] ?? cleanPhone,
        dateOfBirth: insertedData['date_of_birth'],
      );

      await _saveSession(user);

      try {
        final notificationService = NotificationService();
        await notificationService.createNotification(
          ownerId: user.id,
          title: 'Registration Successful',
          message: 'Congratulations! Your account has been created.',
          type: 'registration',
        );

        await notificationService.createNotification(
          ownerId: user.id,
          title: 'Birthday Setting',
          message: 'Please fill in your date of birth to complete your profile.',
          type: 'birthday',
        );
      } catch (e) {
        debugPrint('Failed to load registration notification:: $e');
      }

      return user;
    } on PostgrestException catch (e) {
      throw AuthException('Database Error: ${e.message}');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Registration failed: $e');
    }
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

  Future<void> deleteAccount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_sessionKey);
      
      if (raw == null) {
        throw AuthException('No active user session found to delete.');
      }

      final localUser = UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      
      await _supabase
          .from('users')
          .delete()
          .eq('phone_number', localUser.phoneNumber);
      await prefs.remove(_sessionKey);

    } on PostgrestException catch (e) {
      throw AuthException('Database Error during deletion: ${e.message}');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Failed to delete account: $e');
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_sessionKey);
      if (raw == null) throw AuthException('No active session.');

      final localUser = UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);

      final data = await _supabase
          .from('users')
          .select('password')
          .eq('phone_number', localUser.phoneNumber)
          .single();

      final hashedOld = _hashPassword(oldPassword);
      final hashedNew = _hashPassword(newPassword);

      if (data['password'] != hashedOld) {
        throw AuthException('Incorrect old password.');
      }

      await _supabase
          .from('users')
          .update({'password': hashedNew})
          .eq('phone_number', localUser.phoneNumber);

    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Failed to change password: $e');
    }
  }

  Future<bool?> getSummaryFeedback() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_sessionKey);
      if (raw == null) return null;
      
      final localUser = UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);

      final data = await _supabase
          .from('users')
          .select('summary_feedback')
          .eq('phone_number', localUser.phoneNumber)
          .maybeSingle();

      return data?['summary_feedback'] as bool?;
    } catch (e) {
      debugPrint('Failed to fetch summary feedback: $e');
      return null;
    }
  }

  Future<void> updateSummaryFeedback(bool? isPositive) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_sessionKey);
      if (raw == null) return;
      
      final localUser = UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);

      await _supabase
          .from('users')
          .update({'summary_feedback': isPositive})
          .eq('phone_number', localUser.phoneNumber);
    } catch (e) {
      debugPrint('Failed to update summary feedback: $e');
    }
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}