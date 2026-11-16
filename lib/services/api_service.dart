import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/character_model.dart';
import '../models/episode_model.dart';

class PaginatedResponse<T> {
  final List<T> items;
  final bool hasNextPage;

  const PaginatedResponse({
    required this.items,
    required this.hasNextPage,
  });
}

class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  static const String baseUrl = 'https://rickandmortyapi.com/api';
  static const Duration _timeout = Duration(seconds: 15);

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<PaginatedResponse<CharacterModel>> fetchCharacters({
    String? status,
    String? name,
    int page = 1,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
    };

    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      queryParams['status'] = status.toLowerCase();
    }
    if (name != null && name.trim().isNotEmpty) {
      queryParams['name'] = name.trim();
    }

    final uri = Uri.parse('$baseUrl/character').replace(
      queryParameters: queryParams,
    );

    try {
      final response = await _client.get(uri).timeout(_timeout);

      // Rick & Morty API mengembalikan 404 saat filter/pencarian tidak ada hasil.
      if (response.statusCode == 404) {
        return const PaginatedResponse<CharacterModel>(
          items: [],
          hasNextPage: false,
        );
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final info = data['info'] as Map<String, dynamic>?;
        final results = (data['results'] as List<dynamic>? ?? [])
            .map((e) => CharacterModel.fromJson(e as Map<String, dynamic>))
            .toList();

        return PaginatedResponse<CharacterModel>(
          items: results,
          hasNextPage: info?['next'] != null,
        );
      }

      throw ApiException(
        'Gagal memuat data karakter (Kode: ${response.statusCode}).',
      );
    } on SocketException {
      throw const ApiException(
        'Tidak ada koneksi internet. Periksa jaringan Anda lalu coba lagi.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Gagal terhubung ke server. Periksa koneksi internet Anda lalu coba lagi.',
      );
    } on TimeoutException {
      throw const ApiException(
        'Permintaan ke server melebihi batas waktu. Silakan coba lagi.',
      );
    } on FormatException {
      throw const ApiException('Format respons dari server tidak valid.');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        'Terjadi kesalahan saat menghubungi server Rick & Morty.',
      );
    }
  }

  Future<CharacterModel> fetchCharacterDetail(int id) async {
    final uri = Uri.parse('$baseUrl/character/$id');

    try {
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return CharacterModel.fromJson(data);
      }

      if (response.statusCode == 404) {
        throw const ApiException('Detail karakter tidak ditemukan.');
      }

      throw ApiException(
        'Gagal memuat detail karakter (Kode: ${response.statusCode}).',
      );
    } on SocketException {
      throw const ApiException(
        'Tidak ada koneksi internet. Periksa jaringan Anda lalu coba lagi.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Gagal terhubung ke server. Periksa koneksi internet Anda lalu coba lagi.',
      );
    } on TimeoutException {
      throw const ApiException(
        'Permintaan detail karakter timeout. Silakan coba lagi.',
      );
    } on FormatException {
      throw const ApiException('Format data detail karakter tidak valid.');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Terjadi kesalahan saat memuat detail karakter.');
    }
  }

  Future<PaginatedResponse<EpisodeModel>> fetchEpisodes({int page = 1}) async {
    final uri = Uri.parse('$baseUrl/episode').replace(
      queryParameters: {'page': page.toString()},
    );

    try {
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode == 404) {
        return const PaginatedResponse<EpisodeModel>(
          items: [],
          hasNextPage: false,
        );
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final info = data['info'] as Map<String, dynamic>?;
        final results = (data['results'] as List<dynamic>? ?? [])
            .map((e) => EpisodeModel.fromJson(e as Map<String, dynamic>))
            .toList();

        return PaginatedResponse<EpisodeModel>(
          items: results,
          hasNextPage: info?['next'] != null,
        );
      }

      throw ApiException(
        'Gagal memuat daftar episode (Kode: ${response.statusCode}).',
      );
    } on SocketException {
      throw const ApiException(
        'Tidak ada koneksi internet. Periksa jaringan Anda lalu coba lagi.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Gagal terhubung ke server. Periksa koneksi internet Anda lalu coba lagi.',
      );
    } on TimeoutException {
      throw const ApiException(
        'Permintaan daftar episode timeout. Silakan coba lagi.',
      );
    } on FormatException {
      throw const ApiException('Format data episode tidak valid.');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Terjadi kesalahan saat memuat daftar episode.');
    }
  }
}
