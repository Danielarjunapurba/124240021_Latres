import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:latihanresponsi/controllers/favorite_controller.dart';
import 'package:latihanresponsi/controllers/main_nav_controller.dart';
import 'package:latihanresponsi/models/character_model.dart';
import 'package:latihanresponsi/models/user_model.dart';
import 'package:latihanresponsi/services/api_service.dart';
import 'package:latihanresponsi/services/db_helper.dart';
import 'package:latihanresponsi/services/storage_service.dart';

void main() {
  group('ApiService tests', () {
    test('fetchCharacters parses 200 response properly', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/character');
        expect(request.url.queryParameters['status'], 'alive');
        expect(request.url.queryParameters['name'], 'rick');

        return http.Response(
          jsonEncode({
            'info': {'count': 1, 'pages': 1, 'next': null, 'prev': null},
            'results': [
              {
                'id': 1,
                'name': 'Rick Sanchez',
                'status': 'Alive',
                'species': 'Human',
                'type': '',
                'gender': 'Male',
                'origin': {'name': 'Earth (C-137)', 'url': ''},
                'location': {'name': 'Citadel of Ricks', 'url': ''},
                'image': 'https://rickandmortyapi.com/api/character/avatar/1.jpeg',
                'episode': ['https://rickandmortyapi.com/api/episode/1'],
                'url': 'https://rickandmortyapi.com/api/character/1',
              },
            ],
          }),
          200,
        );
      });

      final api = ApiService(client: mockClient);
      final result = await api.fetchCharacters(status: 'Alive', name: 'rick');

      expect(result.items.length, 1);
      expect(result.items.first.name, 'Rick Sanchez');
      expect(result.items.first.origin.name, 'Earth (C-137)');
      expect(result.hasNextPage, false);
    });

    test('fetchCharacters treats 404 as empty search result', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'error': 'There is nothing here'}),
          404,
        );
      });

      final api = ApiService(client: mockClient);
      final result = await api.fetchCharacters(name: 'nonexistentxyz');

      expect(result.items, isEmpty);
      expect(result.hasNextPage, false);
    });

    test('fetchCharacterDetail parses 200 detail response', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/character/2');
        return http.Response(
          jsonEncode({
            'id': 2,
            'name': 'Morty Smith',
            'status': 'Alive',
            'species': 'Human',
            'type': '',
            'gender': 'Male',
            'origin': {'name': 'unknown', 'url': ''},
            'location': {'name': 'Citadel of Ricks', 'url': ''},
            'image': 'https://rickandmortyapi.com/api/character/avatar/2.jpeg',
            'episode': [],
            'url': '',
          }),
          200,
        );
      });

      final api = ApiService(client: mockClient);
      final detail = await api.fetchCharacterDetail(2);

      expect(detail.id, 2);
      expect(detail.name, 'Morty Smith');
      expect(detail.species, 'Human');
      expect(detail.gender, 'Male');
    });

    test('fetchEpisodes parses 200 episode response', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/episode');
        return http.Response(
          jsonEncode({
            'info': {'next': null},
            'results': [
              {
                'id': 1,
                'name': 'Pilot',
                'air_date': 'December 2, 2013',
                'episode': 'S01E01',
                'characters': ['https://rickandmortyapi.com/api/character/1'],
                'url': '',
              },
            ],
          }),
          200,
        );
      });

      final api = ApiService(client: mockClient);
      final result = await api.fetchEpisodes();

      expect(result.items.length, 1);
      expect(result.items.first.name, 'Pilot');
      expect(result.items.first.airDate, 'December 2, 2013');
      expect(result.items.first.episode, 'S01E01');
    });
  });

  group('StorageService and Controller tests', () {
    setUp(() {
      Get.reset();
      Get.testMode = true;
    });

    test('Session and Favorites persist independently across logout', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService().init();
      Get.put<StorageService>(storage);

      expect(storage.isLoggedIn, false);

      await storage.saveLoginSession(name: 'Daniel', email: 'daniel@test.com');
      expect(storage.isLoggedIn, true);
      expect(storage.userName, 'Daniel');

      final favController = Get.put<FavoriteController>(FavoriteController());
      const rick = CharacterModel(
        id: 1,
        name: 'Rick Sanchez',
        status: 'Alive',
        species: 'Human',
        type: '',
        gender: 'Male',
        origin: CharacterLocation(name: 'Earth (C-137)', url: ''),
        location: CharacterLocation(name: 'Citadel of Ricks', url: ''),
        image: 'https://example.com/1.png',
        episode: [],
        url: '',
      );

      await favController.toggleFavorite(rick);
      expect(favController.isFavorite(1), true);
      expect(storage.getFavorites().length, 1);

      await storage.clearSession();
      expect(storage.isLoggedIn, false);
      expect(storage.getFavorites().length, 1);

      await favController.removeFavorite(rick);
      expect(favController.isFavorite(1), false);
      expect(storage.getFavorites(), isEmpty);
    });

    test('MainNavController changes tab index reactively', () {
      final nav = MainNavController();
      expect(nav.currentIndex.value, 0);
      nav.changeTab(2);
      expect(nav.currentIndex.value, 2);
    });

    test('DbHelper registers, rejects duplicate email, and validates login',
        () async {
      SharedPreferences.setMockInitialValues({});
      final db = DbHelper.instance;

      expect(await db.isEmailRegistered('daniel@test.com'), false);

      final id = await db.insertUser(
        const UserModel(
          name: 'Daniel Arjuna',
          email: 'Daniel@Test.com',
          password: 'password123',
        ),
      );
      expect(id, greaterThan(0));
      expect(await db.isEmailRegistered('daniel@test.com'), true);

      final loggedIn = await db.loginUser('DANIEL@test.com', 'password123');
      expect(loggedIn, isNotNull);
      expect(loggedIn!.name, 'Daniel Arjuna');

      final wrongPass = await db.loginUser('daniel@test.com', 'wrongpass');
      expect(wrongPass, isNull);
    });
  });
}
