import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Interactive Luxury Card with smooth elevate-on-hover, gold border shimmer,
/// and ambient shadow depth.
class LuxuryHoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;

  const LuxuryHoverCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = 6.0,
    this.padding = const EdgeInsets.all(18),
    this.backgroundColor = Colors.white,
  });

  @override
  State<LuxuryHoverCard> createState() => _LuxuryHoverCardState();
}

class _LuxuryHoverCardState extends State<LuxuryHoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isHovered ? -5.0 : 0.0, 0),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: _isHovered
                  ? AppColors.gold.withValues(alpha: 0.65)
                  : AppColors.border,
              width: _isHovered ? 1.2 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? AppColors.navy.withValues(alpha: 0.10)
                    : AppColors.navy.withValues(alpha: 0.03),
                blurRadius: _isHovered ? 24 : 10,
                offset: Offset(0, _isHovered ? 10 : 3),
              ),
              if (_isHovered)
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Entrance animation that smoothly fades in and rises from bottom.
class StaggeredFadeSlide extends StatefulWidget {
  final Widget child;
  final int delayMs;
  final int durationMs;
  final double slideDistance;

  const StaggeredFadeSlide({
    super.key,
    required this.child,
    this.delayMs = 0,
    this.durationMs = 600,
    this.slideDistance = 24.0,
  });

  @override
  State<StaggeredFadeSlide> createState() => _StaggeredFadeSlideState();
}

class _StaggeredFadeSlideState extends State<StaggeredFadeSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.durationMs),
    );

    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
    _slideAnimation = Tween<Offset>(
      begin: Offset(0.0, widget.slideDistance / 100),
      end: Offset.zero,
    ).animate(curved);

    if (widget.delayMs > 0) {
      Future.delayed(Duration(milliseconds: widget.delayMs), () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

