import 'package:get/get.dart';

import '../models/episode_model.dart';
import '../services/api_service.dart';

class EpisodeController extends GetxController {
  final ApiService _apiService = ApiService();

  final RxList<EpisodeModel> episodes = <EpisodeModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasNextPage = false.obs;

  int _currentPage = 1;

  @override
  void onInit() {
    super.onInit();
    fetchEpisodes();
  }

  Future<void> fetchEpisodes() async {
    _currentPage = 1;
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _apiService.fetchEpisodes(page: _currentPage);
      episodes.assignAll(result.items);
      hasNextPage.value = result.hasNextPage;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      episodes.clear();
      hasNextPage.value = false;
    } catch (_) {
      errorMessage.value = 'Gagal memuat daftar episode.';
      episodes.clear();
      hasNextPage.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreEpisodes() async {
    if (isLoading.value || isLoadingMore.value || !hasNextPage.value) return;

    isLoadingMore.value = true;
    final nextPage = _currentPage + 1;

    try {
      final result = await _apiService.fetchEpisodes(page: nextPage);
      _currentPage = nextPage;
      episodes.addAll(result.items);
      hasNextPage.value = result.hasNextPage;
    } catch (_) {
      // Pertahankan daftar episode yang sudah termuat jika pagination gagal.
    } finally {
      isLoadingMore.value = false;
    }
  }
}
