import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Deep Rick & Morty Lab / Space Teal (tenang, elegan, kontras tinggi)
  static const Color spaceTealDark = Color(0xFF0D2129);
  static const Color spaceTeal = Color(0xFF133440);

  // Palet Utama Portal Rick & Morty
  static const Color portalCyan = Color(0xFF007C89);
  static const Color portalCyanDark = Color(0xFF00636D);
  static const Color portalCyanSoft = Color(0xFFE4F5F6);

  static const Color portalGreen = Color(0xFF97CE4C);
  static const Color portalGreenDeep = Color(0xFF426B18);
  static const Color portalGreenSoft = Color(0xFFF0F7E8);

  // Netral Lembut & Nyaman di Mata
  static const Color background = Color(0xFFF0F6F5);
  static const Color surface = Colors.white;
  static const Color surfaceSubtle = Color(0xFFF7FAF9);
  static const Color border = Color(0xFFDCE9E7);

  // Tipografi
  static const Color textPrimary = Color(0xFF0F1F26);
  static const Color textSecondary = Color(0xFF475C66);
  static const Color textMuted = Color(0xFF6B808A);

  // Status Karakter & Favorit
  static const Color alive = Color(0xFF16A34A);
  static const Color aliveSoft = Color(0xFFECFDF5);

  static const Color dead = Color(0xFFE11D48);
  static const Color deadSoft = Color(0xFFFFF1F2);

  static const Color unknown = Color(0xFFD97706);
  static const Color unknownSoft = Color(0xFFFFFBEB);

  static const Color favorite = Color(0xFFF43F5E);
  static const Color favoriteSoft = Color(0xFFFFF1F2);

  static const LinearGradient headerGradient = LinearGradient(
    colors: [spaceTealDark, Color(0xFF17434C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.portalCyan,
        primary: AppColors.portalCyan,
        secondary: AppColors.portalGreenDeep,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    return baseTheme.copyWith(
      textTheme: GoogleFonts.plusJakartaSansTextTheme(baseTheme.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.spaceTealDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceSubtle,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.portalCyan, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.dead),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.dead, width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.portalCyan,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.portalCyan.withValues(alpha: 0.14),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return TextStyle(
            color: isSelected ? AppColors.portalCyanDark : AppColors.textMuted,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.portalCyan,
        circularTrackColor: AppColors.portalCyanSoft,
      ),
    );
  }
}
