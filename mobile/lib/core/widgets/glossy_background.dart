import 'package:flutter/material.dart';

/// An executive ambient mesh gradient canvas blending soft Slate Blue mist
/// and warm Butter Gold ambient glow derived from the T.ask logo.
/// Seamlessly transitions between Airy Light Mode and Deep Matte Obsidian Dark Mode.
class GlossyBackground extends StatelessWidget {
  final Widget child;

  const GlossyBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvasColor = isDark ? const Color(0xFF0F1217) : const Color(0xFFF7F8FA);

    return Container(
      color: canvasColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (isDark) ...[
            // Dark Mode Ambient Mesh Glow
            // 1. Muted Slate Blue Glow (Top-Left) - rgba(62, 103, 155, 0.16)
            Positioned(
              top: -100,
              left: -100,
              width: 500,
              height: 500,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0x293E679B), // rgba(62, 103, 155, 0.16)
                      Color(0x000F1217),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Warm Butter Gold Ambient Glow (Top-Right / Mid) - rgba(251, 224, 148, 0.06)
            Positioned(
              top: 100,
              right: -90,
              width: 420,
              height: 420,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0x0FFBE094), // rgba(251, 224, 148, 0.06)
                      Color(0x000F1217),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Lower Slate Blue Ambient Flow (Bottom-Left)
            Positioned(
              bottom: -90,
              left: -90,
              width: 420,
              height: 420,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0x1F3E679B), // rgba(62, 103, 155, 0.12)
                      Color(0x000F1217),
                    ],
                  ),
                ),
              ),
            ),

            // 4. Subtle Warm Gold Accent (Bottom-Right)
            Positioned(
              bottom: 20,
              right: -60,
              width: 300,
              height: 300,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0x0DFBE094), // rgba(251, 224, 148, 0.05)
                      Color(0x000F1217),
                    ],
                  ),
                ),
              ),
            ),
          ] else ...[
            // Light Mode Ambient Mesh
            // 1. Primary Slate Blue Ambient Mist (Top-Left)
            Positioned(
              top: -90,
              left: -90,
              width: 460,
              height: 460,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFFD3E3F5),
                      Color(0x00F7F8FA),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Warm Butter Gold Ambient Glow (Top-Right / Mid)
            Positioned(
              top: 130,
              right: -80,
              width: 380,
              height: 380,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFFFDE7A8),
                      Color(0x00FDF8EA),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Lower Slate Blue Ambient Flow (Bottom-Left)
            Positioned(
              bottom: -70,
              left: -70,
              width: 400,
              height: 400,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFFDBEAFC),
                      Color(0x00F7F8FA),
                    ],
                  ),
                ),
              ),
            ),

            // 4. Subtle Bottom-Right Warm Gold Accent
            Positioned(
              bottom: 30,
              right: -50,
              width: 280,
              height: 280,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFFFFF0C2),
                      Color(0x00FDF8EA),
                    ],
                  ),
                ),
              ),
            ),
          ],

          // Content Layer
          child,
        ],
      ),
    );
  }
}
