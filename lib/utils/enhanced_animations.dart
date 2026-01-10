import 'package:flutter/material.dart';

/// مجموعة الرسوم المتحركة المحسنة
class EnhancedAnimations {
  
  /// رسم متحرك للظهور التدريجي
  static Widget fadeIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    Duration delay = Duration.zero,
    Curve curve = Curves.easeInOut,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// رسم متحرك للانزلاق من الأسفل
  static Widget slideUp({
    required Widget child,
    Duration duration = const Duration(milliseconds: 600),
    Duration delay = Duration.zero,
    Curve curve = Curves.easeOutCubic,
    double offset = 50.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 0.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, offset * value),
          child: Opacity(
            opacity: 1 - value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// رسم متحرك للتكبير
  static Widget scaleIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
    Duration delay = Duration.zero,
    Curve curve = Curves.elasticOut,
    double initialScale = 0.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: initialScale, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// رسم متحرك للدوران
  static Widget rotateIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 800),
    Duration delay = Duration.zero,
    Curve curve = Curves.elasticOut,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -0.5, end: 0.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value * 3.14159,
          child: child,
        );
      },
      child: child,
    );
  }

  /// رسم متحرك للانزلاق من اليسار
  static Widget slideFromLeft({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    Duration delay = Duration.zero,
    Curve curve = Curves.easeOutCubic,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -1.0, end: 0.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(value * 300, 0),
          child: child,
        );
      },
      child: child,
    );
  }

  /// رسم متحرك للانزلاق من اليمين
  static Widget slideFromRight({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    Duration delay = Duration.zero,
    Curve curve = Curves.easeOutCubic,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 0.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(value * 300, 0),
          child: child,
        );
      },
      child: child,
    );
  }

  /// رسم متحرك للنبض
  static Widget pulse({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1000),
    double minScale = 0.95,
    double maxScale = 1.05,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: minScale, end: maxScale),
      duration: duration,
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      onEnd: () {
        // يمكن إضافة منطق لتكرار الرسم المتحرك
      },
      child: child,
    );
  }

  /// رسم متحرك للاهتزاز
  static Widget shake({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    double offset = 10.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.elasticIn,
      builder: (context, value, child) {
        final shakeValue = (value * 10).round() % 2 == 0 ? offset : -offset;
        return Transform.translate(
          offset: Offset(shakeValue * (1 - value), 0),
          child: child,
        );
      },
      child: child,
    );
  }

  /// رسم متحرك للتدرج اللوني
  static Widget colorTransition({
    required Widget child,
    required Color fromColor,
    required Color toColor,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(begin: fromColor, end: toColor),
      duration: duration,
      curve: curve,
      builder: (context, color, child) {
        return ColorFiltered(
          colorFilter: ColorFilter.mode(
            color ?? Colors.transparent,
            BlendMode.modulate,
          ),
          child: child,
        );
      },
      child: child,
    );
  }

  /// رسم متحرك للتمدد
  static Widget stretch({
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.elasticOut,
    double stretchFactor = 1.2,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: stretchFactor),
      duration: duration ~/ 2,
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(
          scaleX: value,
          child: child,
        );
      },
      onEnd: () {
        // العودة للحجم الطبيعي
      },
      child: child,
    );
  }
}

/// ويدجت للرسوم المتحركة المتتالية
class StaggeredAnimation extends StatefulWidget {
  final List<Widget> children;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final AnimationType type;

  const StaggeredAnimation({
    super.key,
    required this.children,
    this.delay = const Duration(milliseconds: 100),
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOutCubic,
    this.type = AnimationType.fadeIn,
  });

  @override
  State<StaggeredAnimation> createState() => _StaggeredAnimationState();
}

class _StaggeredAnimationState extends State<StaggeredAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.children.length,
      (index) => AnimationController(
        duration: widget.duration,
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: widget.curve),
      );
    }).toList();
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(widget.delay * i, () {
        if (mounted) {
          _controllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.children.length, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return _buildAnimatedChild(index, _animations[index].value);
          },
        );
      }),
    );
  }

  Widget _buildAnimatedChild(int index, double value) {
    final child = widget.children[index];

    switch (widget.type) {
      case AnimationType.fadeIn:
        return Opacity(
          opacity: value,
          child: child,
        );
      case AnimationType.slideUp:
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      case AnimationType.scaleIn:
        return Transform.scale(
          scale: value,
          child: child,
        );
      case AnimationType.slideFromLeft:
        return Transform.translate(
          offset: Offset(-300 * (1 - value), 0),
          child: child,
        );
      default:
        return child;
    }
  }
}

/// أنواع الرسوم المتحركة
enum AnimationType {
  fadeIn,
  slideUp,
  scaleIn,
  slideFromLeft,
}

/// ويدجت للرسوم المتحركة التفاعلية
class InteractiveAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double scaleOnTap;
  final VoidCallback? onTap;

  const InteractiveAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 150),
    this.curve = Curves.easeInOut,
    this.scaleOnTap = 0.95,
    this.onTap,
  });

  @override
  State<InteractiveAnimation> createState() => _InteractiveAnimationState();
}

class _InteractiveAnimationState extends State<InteractiveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleOnTap,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}
