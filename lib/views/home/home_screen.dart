import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/character_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/character_card.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/portal_emblem.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CharacterController>();

    return Column(
      children: [
        _buildPortalBanner(),
        _buildSearchAndFilters(controller),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.portalCyan),
                    SizedBox(height: 12),
                    Text(
                      'Memuat karakter...',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (controller.errorMessage.value.isNotEmpty) {
              return ErrorStateWidget(
                message: controller.errorMessage.value,
                onRetry: controller.fetchCharacters,
              );
            }

            if (controller.characters.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.search_off_rounded,
                title: 'Karakter Tidak Ditemukan',
                message: 'Tidak ada karakter yang cocok dengan pencarian atau filter status yang dipilih.',
                actionLabel: 'Reset Filter',
                onAction: controller.resetFilters,
              );
            }

            return RefreshIndicator(
              color: AppColors.portalCyan,
              onRefresh: controller.fetchCharacters,
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (scrollInfo.metrics.pixels >=
                      scrollInfo.metrics.maxScrollExtent - 200) {
                    controller.loadMoreCharacters();
                  }
                  return false;
                },
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 22),
                  itemCount:
                      controller.characters.length +
                      (controller.isLoadingMore.value ? 1 : 0),
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index >= controller.characters.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.portalCyan,
                            strokeWidth: 2.5,
                          ),
                        ),
                      );
                    }

                    final character = controller.characters[index];
                    return CharacterCard(
                      character: character,
                      heroTagPrefix: 'home_character',
                      onTap: () {
                        Get.toNamed(
                          '/detail',
                          arguments: {
                            'id': character.id,
                            'heroTag': 'home_character_${character.id}',
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPortalBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.portalCyan.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.spaceTealDark.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: 52,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.portalCyan.withValues(alpha: 0.1),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.blur_circular_rounded,
                            color: AppColors.portalGreen,
                            size: 13,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'PORTAL C-137',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Jelajahi Multiverse',
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontSize: 22,
                        height: 0.55,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Temukan karakter dari dimensi lain',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xFFB7D2D1),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const PortalEmblem(size: 82),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(CharacterController controller) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.spaceTealDark.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Obx(() {
              final hasQuery = controller.searchQuery.value.isNotEmpty;
              return TextField(
                controller: controller.searchTextController,
                onChanged: controller.onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Cari nama karakter (mis. Rick, Morty)...',
                  hintStyle: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13.5,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.portalCyanDark,
                  ),
                  suffixIcon: hasQuery
                      ? IconButton(
                          onPressed: controller.clearSearch,
                          tooltip: 'Hapus pencarian',
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.textMuted,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: CharacterController.statusFilters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final status = CharacterController.statusFilters[index];
                return Obx(() {
                  final isSelected = controller.selectedStatus.value == status;
                  final color = _chipColor(status);
                  return FilterChip(
                    selected: isSelected,
                    showCheckmark: false,
                    avatar: status == 'All'
                        ? null
                        : Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : color,
                              shape: BoxShape.circle,
                            ),
                          ),
                    label: Text(status),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                    backgroundColor: Colors.white,
                    selectedColor: color,
                    side: BorderSide(
                      color: isSelected ? color : AppColors.border,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onSelected: (_) => controller.selectStatus(status),
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _chipColor(String status) {
    switch (status.toLowerCase()) {
      case 'alive':
        return AppColors.alive;
      case 'dead':
        return AppColors.dead;
      case 'unknown':
        return AppColors.unknown;
      default:
        return AppColors.portalCyanDark;
    }
  }
}
