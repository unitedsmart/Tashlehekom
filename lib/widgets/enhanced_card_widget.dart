import 'package:flutter/material.dart';
import 'package:tashlehekomv2/utils/app_theme.dart';
import 'package:tashlehekomv2/utils/enhanced_animations.dart';

/// بطاقة محسنة مع رسوم متحركة وتأثيرات بصرية
class EnhancedCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final Color? shadowColor;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enableAnimation;
  final Duration animationDuration;
  final bool enableHoverEffect;
  final bool enableRipple;

  const EnhancedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.shadowColor,
    this.borderRadius,
    this.gradient,
    this.backgroundColor,
    this.onTap,
    this.onLongPress,
    this.enableAnimation = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.enableHoverEffect = true,
    this.enableRipple = true,
  });

  @override
  State<EnhancedCard> createState() => _EnhancedCardState();
}

class _EnhancedCardState extends State<EnhancedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _elevationAnimation = Tween<double>(
      begin: widget.elevation ?? 4.0,
      end: (widget.elevation ?? 4.0) + 4.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enableAnimation) {
      setState(() {
        _isPressed = true;
      });
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enableAnimation) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.enableAnimation) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
    }
  }

  void _handleHover(bool isHovered) {
    if (widget.enableHoverEffect) {
      setState(() {
        _isHovered = isHovered;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    Widget cardContent = Container(
      padding: widget.padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: widget.gradient ?? (isDarkMode ? null : AppTheme.cardGradient),
        color: widget.backgroundColor ?? 
               (isDarkMode ? AppTheme.darkCardColor : AppTheme.cardColor),
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: widget.shadowColor ?? 
                   (isDarkMode ? Colors.black54 : AppTheme.cardShadow),
            blurRadius: _isHovered ? 12 : 8,
            offset: Offset(0, _isHovered ? 4 : 2),
            spreadRadius: _isHovered ? 2 : 0,
          ),
        ],
      ),
      child: widget.child,
    );

    if (widget.enableAnimation) {
      cardContent = AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: cardContent,
      );
    }

    if (widget.onTap != null || widget.onLongPress != null) {
      cardContent = GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: widget.enableRipple
            ? Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  onLongPress: widget.onLongPress,
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                  child: cardContent,
                ),
              )
            : cardContent,
      );
    }

    if (widget.enableHoverEffect) {
      cardContent = MouseRegion(
        onEnter: (_) => _handleHover(true),
        onExit: (_) => _handleHover(false),
        child: cardContent,
      );
    }

    return Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: cardContent,
    );
  }
}

/// بطاقة معلومات محسنة
class InfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedCard(
      backgroundColor: backgroundColor,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: iconColor ?? AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// بطاقة إحصائيات محسنة
class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String? change;
  final bool isPositiveChange;
  final IconData icon;
  final Color? color;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.change,
    this.isPositiveChange = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppTheme.primaryColor;
    
    return EnhancedCard(
      gradient: LinearGradient(
        colors: [
          cardColor.withOpacity(0.8),
          cardColor,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
              if (change != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositiveChange ? Icons.trending_up : Icons.trending_down,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        change!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// بطاقة تحميل محسنة مع Shimmer
class LoadingCard extends StatelessWidget {
  final double? height;
  final double? width;

  const LoadingCard({
    super.key,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedCard(
      enableAnimation: false,
      child: Container(
        height: height ?? 120,
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmerBox(double.infinity, 16),
            const SizedBox(height: 8),
            _buildShimmerBox(200, 14),
            const SizedBox(height: 8),
            _buildShimmerBox(150, 14),
            const Spacer(),
            Row(
              children: [
                _buildShimmerBox(80, 12),
                const Spacer(),
                _buildShimmerBox(60, 12),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerBox(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.shimmerBase,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
