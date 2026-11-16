import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../models/user_model.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._internal();
  DbHelper._internal();

  static const String _dbName = 'rick_morty_explorer.db';
  static const int _dbVersion = 1;
  static const String _usersTable = 'users';
  static const String _webUsersPrefsKey = 'local_users_table_json';

  Database? _database;

  /// sqflite mendukung Android, iOS, dan macOS secara native.
  /// Untuk Web / Windows / Linux desktop tanpa FFI, gunakan fallback SharedPreferences
  /// agar fitur Register & Login tetap berjalan mulus di semua platform.
  bool get _supportsNativeSqflite =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_usersTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<bool> isEmailRegistered(String email) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (_supportsNativeSqflite) {
      try {
        final db = await database;
        final result = await db.query(
          _usersTable,
          columns: ['id'],
          where: 'email = ?',
          whereArgs: [normalizedEmail],
          limit: 1,
        );
        return result.isNotEmpty;
      } catch (_) {
        // Fallback ke SharedPreferences jika sqflite gagal di platform tertentu.
      }
    }

    final users = await _getFallbackUsers();
    return users.any((u) => u.email.trim().toLowerCase() == normalizedEmail);
  }

  Future<int> insertUser(UserModel user) async {
    final normalizedEmail = user.email.trim().toLowerCase();
    final normalizedUser = UserModel(
      id: user.id,
      name: user.name.trim(),
      email: normalizedEmail,
      password: user.password,
    );

    if (_supportsNativeSqflite) {
      try {
        final db = await database;
        return await db.insert(
          _usersTable,
          normalizedUser.toMap(),
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      } catch (e) {
        // Jika error karena constraint UNIQUE email, lempar ulang agar terdeteksi.
        if (e.toString().toLowerCase().contains('unique')) {
          rethrow;
        }
      }
    }

    final users = await _getFallbackUsers();
    if (users.any((u) => u.email.trim().toLowerCase() == normalizedEmail)) {
      throw Exception('Email sudah terdaftar (UNIQUE constraint).');
    }

    final nextId = users.isEmpty
        ? 1
        : users.map((u) => u.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;

    final savedUser = UserModel(
      id: nextId,
      name: normalizedUser.name,
      email: normalizedUser.email,
      password: normalizedUser.password,
    );
    users.add(savedUser);
    await _saveFallbackUsers(users);
    return nextId;
  }

  Future<UserModel?> loginUser(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (_supportsNativeSqflite) {
      try {
        final db = await database;
        final result = await db.query(
          _usersTable,
          where: 'email = ? AND password = ?',
          whereArgs: [normalizedEmail, password],
          limit: 1,
        );

        if (result.isEmpty) return null;
        return UserModel.fromMap(result.first);
      } catch (_) {
        // Fallback ke SharedPreferences jika sqflite tidak tersedia.
      }
    }

    final users = await _getFallbackUsers();
    for (final user in users) {
      if (user.email.trim().toLowerCase() == normalizedEmail &&
          user.password == password) {
        return user;
      }
    }
    return null;
  }

  Future<List<UserModel>> _getFallbackUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_webUsersPrefsKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => UserModel.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveFallbackUsers(List<UserModel> users) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(users.map((u) => u.toMap()).toList());
    await prefs.setString(_webUsersPrefsKey, encoded);
  }
}
