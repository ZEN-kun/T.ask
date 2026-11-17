import 'package:flutter/material.dart';

class AppTheme {
  // Light Mode Brand Palette (Derived from T.ask Logo)
  static const Color brandBlue = Color(0xFF3E679B); // Slate Blue Accent
  static const Color brandTint = Color(0xFFEDF3FA); // Soft Blue Surface Tint
  static const Color brandGold = Color(0xFFFBE094); // Pastel Butter Gold
  static const Color brandDark = Color(0xFF1C1F24); // Deep Obsidian / Primary CTA
  static const Color canvasBg = Color(0xFFF7F8FA); // Soft airy canvas background
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFECEEF2); // Subtle 1px card border
  static const Color textMain = Color(0xFF14171D); // Primary bold headings
  static const Color textMuted = Color(0xFF6E7685); // Secondary metadata grey

  // Light Mode Status Colors (Muted & Refined)
  static const Color statusCompletedBg = Color(0xFFE8F5EE);
  static const Color statusCompletedText = Color(0xFF1F7A4C);
  static const Color statusPendingBg = Color(0xFFFEF6DC);
  static const Color statusPendingText = Color(0xFF9A7414);
  static const Color statusOverdueBg = Color(0xFFFDECEC);
  static const Color statusOverdueText = Color(0xFFC83E3E);

  // Dark Mode Brand Palette (Refined low-glare obsidian + luminous logo accents)
  static const Color darkCanvasBg = Color(0xFF0F1217); // Deep Matte Obsidian Canvas
  static const Color darkCardBg = Color(0xFF171B22); // Dark Slate Charcoal Card Surface
  static const Color darkBorder = Color(0xFF242933); // Hairline 1px border
  static const Color darkRecessed = Color(0xFF1E232D); // Secondary surfaces, inputs, squircles
  static const Color darkRecessedBorder = Color(0xFF2A303D);
  static const Color darkBrandBlue = Color(0xFF5D8CC7); // Lifted Slate Blue for dark surfaces
  static const Color darkBrandTint = Color(0x295D8CC7); // rgba(93, 140, 199, 0.16)
  static const Color darkGoldTint = Color(0x1FFBE094); // rgba(251, 224, 148, 0.12)
  static const Color darkCtaBg = Color(0xFFF3F5F8); // High-contrast Soft Alabaster Primary CTA
  static const Color darkCtaText = Color(0xFF111318);
  static const Color darkTextMain = Color(0xFFF2F4F8); // Primary headings
  static const Color darkTextSub = Color(0xFF9BA3B2); // Body & subtitles
  static const Color darkTextMuted = Color(0xFF636B7A); // Metadata & placeholders

  // Dark Mode Semantic Status Pills (Translucent Dark Tints)
  static const Color darkStatusCompletedBg = Color(0x2634B876); // rgba(52, 184, 118, 0.15)
  static const Color darkStatusCompletedText = Color(0xFF5CD699);
  static const Color darkStatusPendingBg = Color(0x24FBE094); // rgba(251, 224, 148, 0.14)
  static const Color darkStatusPendingText = Color(0xFFFBE094);
  static const Color darkStatusOverdueBg = Color(0x29EB5757); // rgba(235, 87, 87, 0.16)
  static const Color darkStatusOverdueText = Color(0xFFF57C7C);
  static const Color darkOverdueBorder = Color(0x47F57C7C); // rgba(245, 124, 124, 0.28)

  // Legacy mappings for backwards-compatibility
  static const Color primary = brandDark;
  static const Color primaryLight = brandBlue;
  static const Color accent = brandBlue;
  static const Color background = canvasBg;
  static const Color statusPending = statusPendingText;
  static const Color statusCompleted = statusCompletedText;
  static const Color statusOverdue = statusOverdueText;

  // Context-aware dynamic theme helpers
  static bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  static Color cardBg(BuildContext context) =>
      isDark(context) ? darkCardBg.withValues(alpha: 0.92) : Colors.white.withValues(alpha: 0.88);

  static Color cardBorder(BuildContext context) =>
      isDark(context) ? darkBorder : Colors.white;

  static Color solidCardBg(BuildContext context) =>
      isDark(context) ? darkCardBg : Colors.white;

  static Color solidCardBorder(BuildContext context) =>
      isDark(context) ? darkBorder : border;

  static Color recessedSurface(BuildContext context) =>
      isDark(context) ? darkRecessed : brandTint;

  static Color recessedBorder(BuildContext context) =>
      isDark(context) ? darkRecessedBorder : border;

  static Color textPrimary(BuildContext context) =>
      isDark(context) ? darkTextMain : textMain;

  static Color textSecondary(BuildContext context) =>
      isDark(context) ? darkTextSub : textMuted;

  static Color textTertiary(BuildContext context) =>
      isDark(context) ? darkTextMuted : textMuted;

  static Color accentBlue(BuildContext context) =>
      isDark(context) ? darkBrandBlue : brandBlue;

  static Color accentTint(BuildContext context) =>
      isDark(context) ? darkBrandTint : brandTint;

  static Color ctaBackground(BuildContext context) =>
      isDark(context) ? darkCtaBg : brandDark;

  static Color ctaForeground(BuildContext context) =>
      isDark(context) ? darkCtaText : Colors.white;

  static Color statusCompletedBackground(BuildContext context) =>
      isDark(context) ? darkStatusCompletedBg : statusCompletedBg;

  static Color statusCompletedTextColor(BuildContext context) =>
      isDark(context) ? darkStatusCompletedText : statusCompletedText;

  static Color statusPendingBackground(BuildContext context) =>
      isDark(context) ? darkStatusPendingBg : statusPendingBg;

  static Color statusPendingTextColor(BuildContext context) =>
      isDark(context) ? darkStatusPendingText : statusPendingText;

  static Color statusOverdueBackground(BuildContext context) =>
      isDark(context) ? darkStatusOverdueBg : statusOverdueBg;

  static Color statusOverdueTextColor(BuildContext context) =>
      isDark(context) ? darkStatusOverdueText : statusOverdueText;

  static Color overdueBorderColor(BuildContext context) =>
      isDark(context) ? darkOverdueBorder : const Color(0xFFF8D0D0);

  static List<BoxShadow> cardShadow(BuildContext context) => isDark(context)
      ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ]
      : [
          BoxShadow(
            color: const Color(0xFF3E679B).withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ];

  // Glassy selection helpers (for items that turn active/selected)
  // In Light Mode (default): clean white with subtle border and textMain
  // In Dark Mode: luminous translucent frosted glass (rgba(255, 255, 255, 0.18)) with translucent border
  static Color selectedPillBg(BuildContext context) =>
      isDark(context) ? const Color(0x2EFFFFFF) : Colors.white;

  static Color selectedPillBorder(BuildContext context) =>
      isDark(context) ? const Color(0x52FFFFFF) : const Color(0xFFECEEF2);

  static Color selectedPillText(BuildContext context) =>
      isDark(context) ? Colors.white : textMain;

  static Color unselectedPillBg(BuildContext context) =>
      isDark(context) ? darkRecessed : brandTint;

  static Color unselectedPillBorder(BuildContext context) =>
      isDark(context) ? darkRecessedBorder : const Color(0xFFE2E8F0);

  static Color unselectedPillText(BuildContext context) =>
      isDark(context) ? darkTextSub : textMuted;

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: brandDark,
        onPrimary: Colors.white,
        secondary: brandBlue,
        surface: surface,
        onSurface: textMain,
        error: statusOverdueText,
      ),
      scaffoldBackgroundColor: canvasBg,
      canvasColor: canvasBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textMain,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textMain,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.4,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandDark,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: brandBlue, width: 1.5),
        ),
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: darkCtaBg,
        onPrimary: darkCtaText,
        secondary: darkBrandBlue,
        surface: darkCardBg,
        onSurface: darkTextMain,
        error: darkStatusOverdueText,
      ),
      scaffoldBackgroundColor: darkCanvasBg,
      canvasColor: darkCanvasBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: darkTextMain,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: darkTextMain,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.4,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCardBg,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkCtaBg,
          foregroundColor: darkCtaText,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkRecessed,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkRecessedBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkRecessedBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkBrandBlue, width: 1.5),
        ),
        hintStyle: const TextStyle(color: darkTextMuted, fontSize: 14),
        labelStyle: const TextStyle(color: darkTextSub, fontSize: 14),
      ),
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
      ),
    );
  }
}
