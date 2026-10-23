import 'package:flutter/material.dart';

/// Smooth slide + fade page transition used everywhere in the app.
Route<T> appRoute<T>(Widget page) => PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, a, __, child) {
        final curved = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0.04),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );

/// Fades and slides its child in the first time it appears.
/// Gives the home screen a lively, app-like feel (PW style).
class AnimatedIn extends StatefulWidget {
  final Widget child;
  final int index;
  const AnimatedIn({super.key, required this.child, this.index = 0});
  @override
  State<AnimatedIn> createState() => _AnimatedInState();
}

class _AnimatedInState extends State<AnimatedIn> {
  bool _show = false;

  @override
  void initState() {
    super.initState();
    final d = Duration(milliseconds: 70 * widget.index.clamp(0, 8));
    Future.delayed(d, () {
      if (mounted) setState(() => _show = true);
    });
  }

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOut,
        opacity: _show ? 1 : 0,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutCubic,
          offset: _show ? Offset.zero : const Offset(0, 0.09),
          child: widget.child,
        ),
      );
}

/// A soft, gently pulsing highlight used on feature cards.
class SoftPulse extends StatefulWidget {
  final Widget child;
  const SoftPulse({super.key, required this.child});
  @override
  State<SoftPulse> createState() => _SoftPulseState();
}

class _SoftPulseState extends State<SoftPulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1600))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, child) => Transform.scale(scale: 1 + 0.015 * _c.value, child: child),
        child: widget.child,
      );
}
