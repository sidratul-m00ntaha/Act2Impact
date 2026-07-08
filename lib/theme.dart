import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Act2Impact palette: a warm, calm "sanctuary" feel — the opposite of a
/// loud social-media app.
const kBackground = Color(0xFFFAF6EF); // warm cream
const kInk = Color(0xFF23302C); // deep green-black for text
const kPrimary = Color(0xFF0E6B5C); // deep teal
const kAccent = Color(0xFFF2A65A); // soft amber
const kCard = Colors.white;
const kMuted = Color(0xFF7A8783);

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kPrimary,
      surface: kBackground,
    ),
    scaffoldBackgroundColor: kBackground,
  );

  return base.copyWith(
    textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).copyWith(
      displaySmall: GoogleFonts.fraunces(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: kInk,
      ),
      headlineSmall: GoogleFonts.fraunces(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: kInk,
      ),
      titleMedium: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: kInk,
      ),
      bodyMedium: GoogleFonts.nunito(fontSize: 15, color: kInk, height: 1.45),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: kBackground,
      elevation: 0,
      foregroundColor: kInk,
      titleTextStyle: GoogleFonts.fraunces(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: kInk,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: kCard,
      indicatorColor: kPrimary.withValues(alpha: 0.12),
      labelTextStyle: WidgetStatePropertyAll(
        GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: kInk),
      ),
    ),
  );
}

/// Rounded white card used across all screens.
class SoftCard extends StatelessWidget {
  const SoftCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kInk.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
