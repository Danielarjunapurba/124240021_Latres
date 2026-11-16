import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/auth_controller.dart';
import 'controllers/character_controller.dart';
import 'controllers/episode_controller.dart';
import 'controllers/favorite_controller.dart';
import 'controllers/main_nav_controller.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/register_screen.dart';
import 'views/home/detail_screen.dart';
import 'views/home/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = await Get.putAsync<StorageService>(
    () => StorageService().init(),
    permanent: true,
  );

  Get.put<AuthController>(AuthController(), permanent: true);
  Get.put<FavoriteController>(FavoriteController(), permanent: true);

  runApp(
    RickMortyApp(initialRoute: storageService.isLoggedIn ? '/main' : '/login'),
  );
}

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final storage = Get.find<StorageService>();
    if (!storage.isLoggedIn) {
      return const RouteSettings(name: '/login');
    }
    return null;
  }
}

class GuestMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final storage = Get.find<StorageService>();
    if (storage.isLoggedIn) {
      return const RouteSettings(name: '/main');
    }
    return null;
  }
}

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainNavController>(() => MainNavController());
    Get.lazyPut<CharacterController>(() => CharacterController());
    Get.lazyPut<EpisodeController>(() => EpisodeController());
  }
}

class DetailBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CharacterController>()) {
      Get.lazyPut<CharacterController>(() => CharacterController());
    }
  }
}

class RickMortyApp extends StatelessWidget {
  final String initialRoute;

  const RickMortyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Rick & Morty Character Explorer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute,
      getPages: [
        GetPage(
          name: '/login',
          page: () => const LoginScreen(),
          middlewares: [GuestMiddleware()],
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/register',
          page: () => const RegisterScreen(),
          middlewares: [GuestMiddleware()],
          transition: Transition.rightToLeftWithFade,
        ),
        GetPage(
          name: '/main',
          page: () => const MainScreen(),
          binding: MainBinding(),
          middlewares: [AuthMiddleware()],
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/detail',
          page: () => const DetailScreen(),
          binding: DetailBinding(),
          middlewares: [AuthMiddleware()],
          transition: Transition.cupertino,
        ),
      ],
    );
  }
}
