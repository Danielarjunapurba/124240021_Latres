import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/favorite_controller.dart';
import '../../controllers/main_nav_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/portal_emblem.dart';
import '../../widgets/rick_silhouette_icon.dart';
import 'episode_screen.dart';
import 'favorite_screen.dart';
import 'home_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static const List<String> _titles = ['Rick & Morty', 'Favorites', 'Episodes'];

  @override
  Widget build(BuildContext context) {
    final navController = Get.find<MainNavController>();
    final authController = Get.find<AuthController>();
    final favoriteController = Get.find<FavoriteController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(78),
        child: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(gradient: AppColors.headerGradient),
              ),
              Positioned(
                right: -34,
                top: -72,
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.portalCyan.withValues(alpha: 0.18),
                      width: 22,
                    ),
                  ),
                ),
              ),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 3,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.portalGreen.withValues(alpha: 0.14),
                          border: Border.all(
                            color: AppColors.portalGreen.withValues(alpha: 0.4),
                          ),
                        ),
                        child: const PortalEmblem(size: 42),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Obx(() {
                          final idx = navController.currentIndex.value;
                          final userName = authController.currentUserName.value;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _titles[idx],
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              if (userName.isNotEmpty)
                                Text(
                                  'EXPLORER  •  $userName',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.1,
                                    color: Color(0xFFB7D2D1),
                                  ),
                                ),
                            ],
                          );
                        }),
                      ),
                      Material(
                        color: Colors.white.withValues(alpha: 0.11),
                        shape: const CircleBorder(
                          side: BorderSide(color: Colors.white24),
                        ),
                        child: IconButton(
                          onPressed: () => _confirmLogout(authController),
                          tooltip: 'Logout',
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: Colors.white,
                            size: 19,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Obx(
        () => IndexedStack(
          index: navController.currentIndex.value,
          children: const [HomeScreen(), FavoriteScreen(), EpisodeScreen()],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.spaceTealDark.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Obx(
                () => NavigationBar(
                  height: 68,
                  selectedIndex: navController.currentIndex.value,
                  onDestinationSelected: navController.changeTab,
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  indicatorColor: AppColors.portalCyanSoft,
                  destinations: [
                    const NavigationDestination(
                      icon: RickSilhouetteIcon(
                        size: 24,
                        color: Color(0xFF6B808A),
                      ),
                      selectedIcon: RickSilhouetteIcon(
                        size: 24,
                        color: AppColors.portalCyanDark,
                      ),
                      label: 'Characters',
                    ),
                    NavigationDestination(
                      icon: Badge(
                        isLabelVisible: favoriteController.favorites.isNotEmpty,
                        label: Text('${favoriteController.favorites.length}'),
                        backgroundColor: AppColors.favorite,
                        child: const Icon(
                          Icons.favorite_border_rounded,
                          color: Color(0xFF6B808A),
                        ),
                      ),
                      selectedIcon: Badge(
                        isLabelVisible: favoriteController.favorites.isNotEmpty,
                        label: Text('${favoriteController.favorites.length}'),
                        backgroundColor: AppColors.favorite,
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: AppColors.favorite,
                        ),
                      ),
                      label: 'Favorites',
                    ),
                    const NavigationDestination(
                      icon: Icon(Icons.tv_outlined, color: Color(0xFF6B808A)),
                      selectedIcon: Icon(
                        Icons.tv_rounded,
                        color: AppColors.portalCyanDark,
                      ),
                      label: 'Episodes',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmLogout(AuthController authController) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppColors.dead),
            SizedBox(width: 10),
            Text(
              'Konfirmasi Logout',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun ini? Daftar favorit Anda tetap tersimpan.',
          style: TextStyle(color: AppColors.textSecondary, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => authController.logout(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dead,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
