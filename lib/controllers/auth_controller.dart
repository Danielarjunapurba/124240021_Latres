import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/user_model.dart';
import '../services/db_helper.dart';
import '../services/storage_service.dart';

class AuthController extends GetxController {
  final DbHelper _dbHelper = DbHelper.instance;
  final StorageService _storage = Get.find<StorageService>();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordHidden = true.obs;
  final RxString errorMessage = ''.obs;
  final RxString currentUserName = ''.obs;
  final RxString currentUserEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _syncSessionData();
  }

  void _syncSessionData() {
    currentUserName.value = _storage.userName;
    currentUserEmail.value = _storage.userEmail;
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void clearError() {
    if (errorMessage.value.isNotEmpty) {
      errorMessage.value = '';
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final normalizedEmail = email.trim().toLowerCase();
      final exists = await _dbHelper.isEmailRegistered(normalizedEmail);

      if (exists) {
        const msg =
            'Email sudah terdaftar. Silakan gunakan email lain atau login.';
        errorMessage.value = msg;
        _showFeedbackSnackbar(
          title: 'Registrasi Gagal',
          message: msg,
          isError: true,
        );
        return false;
      }

      final newUser = UserModel(
        name: name.trim(),
        email: normalizedEmail,
        password: password,
      );

      await _dbHelper.insertUser(newUser);

      Get.offAllNamed('/login');
      Future.delayed(const Duration(milliseconds: 150), () {
        _showFeedbackSnackbar(
          title: 'Registrasi Berhasil',
          message: 'Akun berhasil dibuat. Silakan login dengan akun Anda.',
          isError: false,
        );
      });
      return true;
    } catch (e) {
      final msg = e.toString().toLowerCase().contains('unique')
          ? 'Email sudah terdaftar. Silakan gunakan email lain atau login.'
          : 'Terjadi kesalahan saat menyimpan akun. Coba lagi.';
      errorMessage.value = msg;
      _showFeedbackSnackbar(
        title: 'Registrasi Gagal',
        message: msg,
        isError: true,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final user = await _dbHelper.loginUser(email, password);

      if (user == null) {
        const msg = 'Email atau password salah. Pastikan akun sudah terdaftar.';
        errorMessage.value = msg;
        _showFeedbackSnackbar(
          title: 'Login Gagal',
          message: msg,
          isError: true,
        );
        return false;
      }

      await _storage.saveLoginSession(
        name: user.name,
        email: user.email,
      );
      _syncSessionData();

      Get.offAllNamed('/main');
      Future.delayed(const Duration(milliseconds: 150), () {
        _showFeedbackSnackbar(
          title: 'Selamat Datang, ${user.name}!',
          message: 'Berhasil masuk ke Rick & Morty Character Explorer.',
          isError: false,
        );
      });
      return true;
    } catch (_) {
      const msg = 'Terjadi kesalahan saat memproses login. Coba lagi.';
      errorMessage.value = msg;
      _showFeedbackSnackbar(
        title: 'Login Gagal',
        message: msg,
        isError: true,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _storage.clearSession();
    currentUserName.value = '';
    currentUserEmail.value = '';
    errorMessage.value = '';

    Get.offAllNamed('/login');
    Future.delayed(const Duration(milliseconds: 150), () {
      _showFeedbackSnackbar(
        title: 'Logout Berhasil',
        message: 'Anda telah keluar dari aplikasi.',
        isError: false,
      );
    });
  }

  void _showFeedbackSnackbar({
    required String title,
    required String message,
    required bool isError,
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
            isError ? const Color(0xFFE11D48) : const Color(0xFF0D2129),
        colorText: Colors.white,
        icon: Icon(
          isError
              ? Icons.error_outline_rounded
              : Icons.check_circle_outline_rounded,
          color: isError ? Colors.white : const Color(0xFF97CE4C),
        ),
        duration: const Duration(seconds: 3),
      );
    } catch (_) {
      // Abaikan jika overlay belum siap.
    }
  }
}
