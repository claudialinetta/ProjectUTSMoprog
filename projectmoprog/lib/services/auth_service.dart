import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';
import 'notification_service.dart';

class AuthService {
  static const _sessionKey = 'current_user';
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<UserModel> register({
    required String name,
    required String phoneNumber,
    required String password,
  }) async {
    final cleanName = name.trim();
    final cleanPhone = phoneNumber.trim();
    final cleanPass = password.trim();

    if (cleanName.isEmpty || cleanPhone.isEmpty) {
      throw AuthException('Nama dan nomor telepon wajib diisi.');
    }
    if (cleanPass.length < 4) {
      throw AuthException('Kata sandi minimal 4 karakter.');
    }

    try {
      final existingUser = await _supabase
          .from('users')
          .select('phone_number')
          .eq('phone_number', cleanPhone)
          .maybeSingle();

      if (existingUser != null) {
        throw AuthException('Nomor telepon ini sudah terdaftar. Silakan login.');
      }

      final insertedData = await _supabase.from('users').insert({
        'id': cleanPhone,
        'name': cleanName,
        'phone_number': cleanPhone,
        'password': cleanPass,
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
          title: 'Pengaturan Tanggal Lahir',
          message: 'Silakan lengkapi tanggal lahir Anda untuk melengkapi profil.',
          type: 'birthday',
        );
      } catch (e) {
        debugPrint('Gagal membuat notifikasi registrasi: $e');
      }

      return user;
    } on PostgrestException catch (e) {
      throw AuthException('Database Error: ${e.message}');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Terjadi kesalahan registrasi: $e');
    }
  }

  Future<UserModel> login({
    required String phoneNumber,
    required String password,
  }) async {
    final cleanPhone = phoneNumber.trim();
    final cleanPass = password.trim();

    if (cleanPhone.isEmpty || cleanPass.isEmpty) {
      throw AuthException('Nomor telepon dan kata sandi wajib diisi.');
    }

    try {
      final data = await _supabase
          .from('users')
          .select()
          .eq('phone_number', cleanPhone)
          .maybeSingle();

      if (data == null) {
        throw AuthException('Nomor telepon belum terdaftar. Silakan daftar akun terlebih dahulu.');
      }

      if (data['password'] != cleanPass) {
        throw AuthException('Kata sandi salah. Silakan coba lagi.');
      }

      final user = UserModel(
        id: data['id'].toString(),
        name: data['name'] ?? 'User',
        phoneNumber: data['phone_number'] ?? cleanPhone,
        dateOfBirth: data['date_of_birth'],
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
    } on PostgrestException catch (e) {
      throw AuthException('Database Error: ${e.message}');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Terjadi kesalahan login: $e');
    }
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

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
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