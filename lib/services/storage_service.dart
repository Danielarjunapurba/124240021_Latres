import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/character_model.dart';

class StorageService extends GetxService {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserName = 'userName';
  static const String _keyUserEmail = 'userEmail';
  static const String _keyFavorites = 'favoriteCharacters';

  late final SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  bool get isLoggedIn => _prefs.getBool(_keyIsLoggedIn) ?? false;

  String get userName => _prefs.getString(_keyUserName) ?? '';

  String get userEmail => _prefs.getString(_keyUserEmail) ?? '';

  Future<void> saveLoginSession({
    required String name,
    required String email,
  }) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserName, name);
    await _prefs.setString(_keyUserEmail, email);
  }

  Future<void> clearSession() async {
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserName);
    await _prefs.remove(_keyUserEmail);
  }

  List<CharacterModel> getFavorites() {
    final rawJson = _prefs.getString(_keyFavorites);
    if (rawJson == null || rawJson.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(rawJson) as List<dynamic>;
      return decoded
          .map((item) => CharacterModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveFavorites(List<CharacterModel> favorites) async {
    final encoded = jsonEncode(favorites.map((c) => c.toJson()).toList());
    await _prefs.setString(_keyFavorites, encoded);
  }
}
