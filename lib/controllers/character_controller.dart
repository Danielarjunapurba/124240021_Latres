import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/character_model.dart';
import '../services/api_service.dart';

class CharacterController extends GetxController {
  final ApiService _apiService = ApiService();

  static const List<String> statusFilters = [
    'All',
    'Alive',
    'Dead',
    'Unknown',
  ];

  final TextEditingController searchTextController = TextEditingController();

  final RxList<CharacterModel> characters = <CharacterModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedStatus = 'All'.obs;
  final RxString searchQuery = ''.obs;
  final RxBool hasNextPage = false.obs;

  final Rxn<CharacterModel> selectedCharacter = Rxn<CharacterModel>();
  final RxBool isDetailLoading = false.obs;
  final RxString detailErrorMessage = ''.obs;

  int _currentPage = 1;
  int _requestToken = 0;
  int _detailRequestToken = 0;
  Timer? _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    fetchCharacters();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchTextController.dispose();
    super.onClose();
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      fetchCharacters();
    });
  }

  void clearSearch() {
    _searchDebounce?.cancel();
    searchTextController.clear();
    searchQuery.value = '';
    fetchCharacters();
  }

  void selectStatus(String status) {
    if (selectedStatus.value == status) return;
    _searchDebounce?.cancel();
    selectedStatus.value = status;
    fetchCharacters();
  }

  void resetFilters() {
    _searchDebounce?.cancel();
    searchTextController.clear();
    searchQuery.value = '';
    selectedStatus.value = 'All';
    fetchCharacters();
  }

  Future<void> fetchCharacters() async {
    final token = ++_requestToken;
    _currentPage = 1;
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _apiService.fetchCharacters(
        status: selectedStatus.value,
        name: searchQuery.value,
        page: _currentPage,
      );

      if (token != _requestToken) return;

      characters.assignAll(result.items);
      hasNextPage.value = result.hasNextPage;
    } on ApiException catch (e) {
      if (token != _requestToken) return;
      errorMessage.value = e.message;
      characters.clear();
      hasNextPage.value = false;
    } catch (_) {
      if (token != _requestToken) return;
      errorMessage.value = 'Gagal memuat daftar karakter.';
      characters.clear();
      hasNextPage.value = false;
    } finally {
      if (token == _requestToken) {
        isLoading.value = false;
      }
    }
  }

  Future<void> loadMoreCharacters() async {
    if (isLoading.value || isLoadingMore.value || !hasNextPage.value) return;

    final token = _requestToken;
    isLoadingMore.value = true;
    final nextPage = _currentPage + 1;

    try {
      final result = await _apiService.fetchCharacters(
        status: selectedStatus.value,
        name: searchQuery.value,
        page: nextPage,
      );

      if (token != _requestToken) return;

      _currentPage = nextPage;
      characters.addAll(result.items);
      hasNextPage.value = result.hasNextPage;
    } catch (_) {
      // Abaikan error load-more agar daftar yang sudah tampil tetap terjaga.
    } finally {
      if (token == _requestToken) {
        isLoadingMore.value = false;
      }
    }
  }

  Future<void> fetchCharacterDetail(int id) async {
    final token = ++_detailRequestToken;
    isDetailLoading.value = true;
    detailErrorMessage.value = '';
    selectedCharacter.value = null;

    try {
      final detail = await _apiService.fetchCharacterDetail(id);
      if (token != _detailRequestToken) return;
      selectedCharacter.value = detail;
    } on ApiException catch (e) {
      if (token != _detailRequestToken) return;
      detailErrorMessage.value = e.message;
    } catch (_) {
      if (token != _detailRequestToken) return;
      detailErrorMessage.value = 'Gagal memuat detail karakter.';
    } finally {
      if (token == _detailRequestToken) {
        isDetailLoading.value = false;
      }
    }
  }
}
