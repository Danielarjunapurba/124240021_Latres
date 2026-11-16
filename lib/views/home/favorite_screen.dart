import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/favorite_controller.dart';
import '../../controllers/main_nav_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/character_card.dart';
import '../../widgets/empty_state_widget.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteController = Get.find<FavoriteController>();

    return Obx(() {
      if (favoriteController.favorites.isEmpty) {
        return EmptyStateWidget(
          icon: Icons.favorite_border_rounded,
          title: 'Belum Ada Karakter Favorit',
          message:
              'Belum ada karakter favorit. Tandai karakter favoritmu di halaman Characters!',
          actionLabel: 'Jelajahi Karakter',
          onAction: () => Get.find<MainNavController>().changeTab(0),
        );
      }

      return Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: AppColors.portalCyanSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.portalCyan.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.swipe_left_rounded,
                  size: 18,
                  color: AppColors.portalCyanDark,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Geser kartu ke kiri untuk menghapus (${favoriteController.favorites.length} favorit)',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.spaceTeal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 22),
              itemCount: favoriteController.favorites.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final character = favoriteController.favorites[index];

                return Dismissible(
                  key: ValueKey('fav_${character.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.dead,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Hapus',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                  onDismissed: (_) =>
                      favoriteController.removeFavorite(character),
                  child: CharacterCard(
                    character: character,
                    heroTagPrefix: 'fav_character',
                    onTap: () {
                      Get.toNamed(
                        '/detail',
                        arguments: {
                          'id': character.id,
                          'heroTag': 'fav_character_${character.id}',
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
