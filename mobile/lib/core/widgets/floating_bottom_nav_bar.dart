import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_mobile/app/theme.dart';

class FloatingBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const FloatingBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    final navBg = isDark
        ? const Color(0xEB1A1F28) // rgba(26, 31, 40, 0.92)
        : Colors.white.withValues(alpha: 0.90);
    final navBorder = isDark ? const Color(0xFF2B3240) : Colors.white;

    return SafeArea(
      child: Container(
        height: 64,
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.35) : const Color(0xFF3E679B).withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: navBg,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: navBorder, width: 1.2),
              ),
              child: Row(
                children: [
                  _buildNavItem(
                    context: context,
                    index: 0,
                    label: 'Dashboard',
                    icon: Icons.grid_view_outlined,
                    selectedIcon: Icons.grid_view_rounded,
                    route: '/dashboard',
                  ),
                  _buildNavItem(
                    context: context,
                    index: 1,
                    label: 'Tasks',
                    icon: Icons.checklist_outlined,
                    selectedIcon: Icons.checklist_rounded,
                    route: '/tasks',
                  ),
                  _buildNavItem(
                    context: context,
                    index: 2,
                    label: 'Meetings',
                    icon: Icons.mic_none_outlined,
                    selectedIcon: Icons.mic_rounded,
                    route: '/meetings',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required String label,
    required IconData icon,
    required IconData selectedIcon,
    required String route,
  }) {
    final isSelected = currentIndex == index;
    final isDark = AppTheme.isDark(context);

    final activeBg = AppTheme.selectedPillBg(context);
    final activeBorder = AppTheme.selectedPillBorder(context);
    final activeColor = AppTheme.selectedPillText(context);
    final inactiveColor = isDark ? const Color(0xFF7D8696) : AppTheme.textMuted;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            if (!isSelected) {
              context.go(route);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: isSelected ? activeBg : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
              border: isSelected ? Border.all(color: activeBorder, width: 1.1) : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSelected ? selectedIcon : icon,
                  size: 20,
                  color: isSelected ? activeColor : inactiveColor,
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? activeColor : inactiveColor,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
