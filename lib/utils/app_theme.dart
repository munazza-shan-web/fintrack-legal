import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color surface;
  final Color surface2;
  final Color accent;
  final Color muted;
  final Color text;
  final Color danger;

  const AppColors({
    required this.background,
    required this.surface,
    required this.surface2,
    required this.accent,
    required this.muted,
    required this.text,
    required this.danger,
  });

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surface2,
    Color? accent,
    Color? muted,
    Color? text,
    Color? danger,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      accent: accent ?? this.accent,
      muted: muted ?? this.muted,
      text: text ?? this.text,
      danger: danger ?? this.danger,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;

    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      text: Color.lerp(text, other.text, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

class AppTheme {
  static const AppColors darkColors = AppColors(
    background: Color(0xFF090B0A),
    surface: Color(0xFF151917),
    surface2: Color(0xFF1D2420),
    accent: Color(0xFFB7FF3C),
    muted: Color(0xFF929B94),
    text: Color(0xFFF4F7F4),
    danger: Color(0xFFFF6B6B),
  );

  static const AppColors lightColors = AppColors(
    background: Color(0xFFF5F7F3),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFE9EEE7),
    accent: Color(0xFF638C20),
    muted: Color(0xFF68736A),
    text: Color(0xFF182019),
    danger: Color(0xFFCF4141),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkColors.background,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFB7FF3C),
      secondary: Color(0xFFB7FF3C),
      surface: Color(0xFF151917),
      error: Color(0xFFFF6B6B),
    ),
    cardColor: darkColors.surface,
    extensions: const <ThemeExtension<dynamic>>[
      darkColors,
    ],
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightColors.background,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF638C20),
      secondary: Color(0xFF638C20),
      surface: Color(0xFFFFFFFF),
      error: Color(0xFFCF4141),
    ),
    cardColor: lightColors.surface,
    extensions: const <ThemeExtension<dynamic>>[
      lightColors,
    ],
  );
}