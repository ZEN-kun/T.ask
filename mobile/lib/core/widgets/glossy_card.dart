import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:task_mobile/app/theme.dart';

/// An executive frosted-glass container with BackdropFilter blur, specular border,
/// and diffuse ambient shadow for authentic glassmorphism throughout T.ask.
class GlossyCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Border? border;
  final Color? color;
  final VoidCallback? onTap;

  const GlossyCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.border,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final radius = borderRadius ?? BorderRadius.circular(22);

    final cardContent = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.25) : const Color(0xFF3E679B).withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: padding ?? const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: color ?? AppTheme.cardBg(context),
              borderRadius: radius,
              border: border ?? Border.all(color: AppTheme.cardBorder(context), width: 1.1),
            ),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: cardContent,
      );
    }

    return cardContent;
  }
}
