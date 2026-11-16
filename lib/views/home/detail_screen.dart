import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/character_controller.dart';
import '../../controllers/favorite_controller.dart';
import '../../models/character_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/status_badge.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final CharacterController _characterController =
      Get.find<CharacterController>();
  final FavoriteController _favoriteController = Get.find<FavoriteController>();

  late final int _characterId;
  late final String _heroTag;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      _characterId = (args['id'] as num).toInt();
      _heroTag = (args['heroTag'] ?? 'character_$_characterId').toString();
    } else if (args is int) {
      _characterId = args;
      _heroTag = 'home_character_$args';
    } else {
      _characterId = 1;
      _heroTag = 'character_1';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _characterController.fetchCharacterDetail(_characterId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.headerGradient,
          ),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
        ),
        title: Text(
          'Detail Karakter',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 19,
          ),
        ),
        actions: [
          Obx(() {
            final character = _characterController.selectedCharacter.value;
            if (character == null) {
              return const SizedBox.shrink();
            }
            final isFav = _favoriteController.isFavorite(character.id);
            return IconButton(
              onPressed: () => _favoriteController.toggleFavorite(character),
              tooltip: isFav ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Icon(
                  isFav
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  key: ValueKey<bool>(isFav),
                  color: isFav ? AppColors.favorite : Colors.white,
                  size: 26,
                ),
              ),
            );
          }),
          const SizedBox(width: 6),
        ],
      ),
      body: Obx(() {
        if (_characterController.isDetailLoading.value) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.portalCyan),
                SizedBox(height: 12),
                Text(
                  'Mengambil detail karakter...',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          );
        }

        if (_characterController.detailErrorMessage.value.isNotEmpty) {
          return ErrorStateWidget(
            message: _characterController.detailErrorMessage.value,
            onRetry: () =>
                _characterController.fetchCharacterDetail(_characterId),
          );
        }

        final character = _characterController.selectedCharacter.value;
        if (character == null) {
          return ErrorStateWidget(
            message: 'Data karakter tidak tersedia.',
            onRetry: () =>
                _characterController.fetchCharacterDetail(_characterId),
          );
        }

        return _buildContent(character);
      }),
    );
  }

  Widget _buildContent(CharacterModel character) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
            decoration: const BoxDecoration(
              gradient: AppColors.headerGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.portalGreen.withValues(alpha: 0.28),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Hero(
                      tag: _heroTag,
                      child: SizedBox(
                        width: 196,
                        height: 196,
                        child: Image.network(
                          character.image,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: AppColors.spaceTeal,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.portalGreen,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.spaceTeal,
                              child: const Icon(
                                Icons.broken_image_outlined,
                                size: 56,
                                color: Colors.white70,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  character.name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    StatusBadge(status: character.status),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.tv_rounded,
                            size: 13.5,
                            color: AppColors.portalGreen,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${character.episode.length} Episode',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.biotech_outlined,
                        iconColor: AppColors.portalCyanDark,
                        iconBg: AppColors.portalCyanSoft,
                        label: 'Spesies',
                        value: character.species,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.wc_rounded,
                        iconColor: AppColors.portalGreenDeep,
                        iconBg: AppColors.portalGreenSoft,
                        label: 'Gender',
                        value: character.gender,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.spaceTealDark.withValues(alpha: 0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Karakter',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildInfoRow(
                        icon: Icons.monitor_heart_outlined,
                        iconColor: AppColors.alive,
                        iconBg: AppColors.aliveSoft,
                        label: 'Status',
                        value: character.status,
                      ),
                      const Divider(height: 22, color: AppColors.border),
                      _buildInfoRow(
                        icon: Icons.public_rounded,
                        iconColor: AppColors.portalCyanDark,
                        iconBg: AppColors.portalCyanSoft,
                        label: 'Origin',
                        value: character.origin.name,
                      ),
                      const Divider(height: 22, color: AppColors.border),
                      _buildInfoRow(
                        icon: Icons.location_on_outlined,
                        iconColor: AppColors.unknown,
                        iconBg: AppColors.unknownSoft,
                        label: 'Location',
                        value: character.location.name,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Obx(() {
                  final isFav = _favoriteController.isFavorite(character.id);
                  return SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _favoriteController.toggleFavorite(character),
                      icon: Icon(
                        isFav
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                      ),
                      label: Text(
                        isFav ? 'Hapus dari Favorit' : 'Tambahkan ke Favorit',
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isFav ? AppColors.favorite : AppColors.portalCyan,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.spaceTealDark.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? 'Unknown' : value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? 'Unknown' : value,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
