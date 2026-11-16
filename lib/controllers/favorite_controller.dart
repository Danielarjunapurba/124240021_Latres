import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/character_model.dart';
import '../services/storage_service.dart';

class FavoriteController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  final RxList<CharacterModel> favorites = <CharacterModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  void loadFavorites() {
    favorites.assignAll(_storage.getFavorites());
  }

  bool isFavorite(int characterId) {
    return favorites.any((item) => item.id == characterId);
  }

  Future<void> toggleFavorite(CharacterModel character) async {
    final existingIndex = favorites.indexWhere((c) => c.id == character.id);

    if (existingIndex != -1) {
      favorites.removeAt(existingIndex);
      await _storage.saveFavorites(favorites);
      _showFavoriteSnackbar(
        title: 'Dihapus dari Favorit',
        message: '${character.name} telah dihapus dari daftar favorit.',
        added: false,
      );
    } else {
      favorites.insert(0, character);
      await _storage.saveFavorites(favorites);
      _showFavoriteSnackbar(
        title: 'Ditambahkan ke Favorit',
        message: '${character.name} telah ditambahkan ke daftar favorit.',
        added: true,
      );
    }
  }

  Future<void> removeFavorite(CharacterModel character) async {
    favorites.removeWhere((c) => c.id == character.id);
    await _storage.saveFavorites(favorites);
    _showFavoriteSnackbar(
      title: 'Dihapus dari Favorit',
      message: '${character.name} berhasil dihapus dari favorit.',
      added: false,
    );
  }

  void _showFavoriteSnackbar({
    required String title,
    required String message,
    required bool added,
  }) {
    if (Get.testMode || Get.overlayContext == null) return;
    try {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
    } catch (_) {
      // Abaikan jika snackbar sebelumnya belum selesai inisialisasi controller.
    }

    try {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
        backgroundColor:
            added ? const Color(0xFF0D2129) : const Color(0xFF334155),
        colorText: Colors.white,
        icon: Icon(
          added ? Icons.favorite_rounded : Icons.heart_broken_rounded,
          color: added ? const Color(0xFF97CE4C) : const Color(0xFFFDA4AF),
        ),
        duration: const Duration(seconds: 2),
      );
    } catch (_) {
      // Abaikan jika overlay belum siap.
    }
  }
}
