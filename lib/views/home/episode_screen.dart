import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/episode_controller.dart';
import '../../models/episode_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/error_state_widget.dart';

class EpisodeScreen extends StatelessWidget {
  const EpisodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EpisodeController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.portalCyan),
              SizedBox(height: 12),
              Text(
                'Memuat daftar episode...',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13.5),
              ),
            ],
          ),
        );
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return ErrorStateWidget(
          message: controller.errorMessage.value,
          onRetry: controller.fetchEpisodes,
        );
      }

      if (controller.episodes.isEmpty) {
        return EmptyStateWidget(
          icon: Icons.tv_off_rounded,
          title: 'Belum Ada Episode',
          message: 'Daftar episode tidak tersedia saat ini.',
          actionLabel: 'Muat Ulang',
          onAction: controller.fetchEpisodes,
        );
      }

      return RefreshIndicator(
        color: AppColors.portalCyan,
        onRefresh: controller.fetchEpisodes,
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 200) {
              controller.loadMoreEpisodes();
            }
            return false;
          },
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            itemCount:
                controller.episodes.length +
                1 +
                (controller.isLoadingMore.value ? 1 : 0),
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildChannelHeader(controller.episodes.length);
              }

              final epIndex = index - 1;
              if (epIndex >= controller.episodes.length) {
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

              return _EpisodeCard(episode: controller.episodes[epIndex]);
            },
          ),
        ),
      );
    });
  }

  Widget _buildChannelHeader(int count) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.spaceTealDark.withValues(alpha: 0.14),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.portalGreen.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.live_tv_rounded,
              color: AppColors.portalGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Interdimensional Cable',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count episode Rick & Morty dimuat',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFFCBD5E1),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.portalCyan.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.portalCyan.withValues(alpha: 0.45),
              ),
            ),
            child: const Text(
              'C-137 TV',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.portalCyan,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EpisodeCard extends StatelessWidget {
  final EpisodeModel episode;

  const _EpisodeCard({required this.episode});

  @override
  Widget build(BuildContext context) {
    final parsed = _parseSeasonEpisode(episode.episode);
    final seasonNum = parsed.$1;
    final epCode = parsed.$2;
    final (accent, accentSoft) = _seasonPalette(seasonNum);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accentSoft, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.1),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent, accent.withValues(alpha: 0.55)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.play_arrow_rounded,
                              size: 14,
                              color: AppColors.portalGreen,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              epCode,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 11.5,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: accentSoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Season $seasonNum',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: accent,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '#${episode.id.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    episode.name,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: accentSoft.withValues(alpha: 0.82),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 13.5,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            episode.airDate,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.people_outline_rounded,
                          size: 15,
                          color: AppColors.portalGreenDeep,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${episode.characters.length} Karakter',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  (int, String) _parseSeasonEpisode(String code) {
    final match = RegExp(
      r'S(\d+)E(\d+)',
      caseSensitive: false,
    ).firstMatch(code);
    if (match != null) {
      final season = int.tryParse(match.group(1) ?? '1') ?? 1;
      return (season, code.toUpperCase());
    }
    return (1, code.isEmpty ? 'EP ${episode.id}' : code);
  }

  (Color, Color) _seasonPalette(int season) {
    switch (season % 4) {
      case 1:
        return (AppColors.portalCyanDark, const Color(0xFFD8F0F1));
      case 2:
        return (AppColors.portalGreenDeep, const Color(0xFFE9F3D5));
      case 3:
        return (const Color(0xFF0F766E), const Color(0xFFD7F3EA));
      default:
        return (const Color(0xFF0369A1), const Color(0xFFDCECF9));
    }
  }
}
