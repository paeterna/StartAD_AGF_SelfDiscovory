import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// =====================================================
// Responsive Breakpoints & Utilities
// =====================================================
//
// This file provides a complete responsive layout system for web + desktop.
// Breakpoints follow Material Design and common device widths.

/// Responsive breakpoints in logical pixels
class Breakpoints {
  const Breakpoints._();

  /// Extra small: phones in portrait (< 600px)
  static const double xs = 600.0;

  /// Small: large phones, small tablets (600-899px)
  static const double sm = 900.0;

  /// Medium: tablets, small laptops (900-1199px)
  static const double md = 1200.0;

  /// Large: laptops, desktops (1200-1599px)
  static const double lg = 1600.0;

  /// Extra large: large desktops, ultrawide (≥ 1600px)
  /// xl breakpoint starts at lg value
}

/// Responsive size categories
enum ResponsiveSize {
  xs, // < 600
  sm, // 600-899
  md, // 900-1199
  lg, // 1200-1599
  xl; // ≥ 1600

  /// Check if this is a mobile size
  bool get isMobile => this == xs || this == sm;

  /// Check if this is a tablet size
  bool get isTablet => this == md;

  /// Check if this is a desktop size
  bool get isDesktop => this == lg || this == xl;
}

/// Extension on BuildContext for responsive helpers
extension ResponsiveContext on BuildContext {
  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Check if extra small (phone)
  bool get isXs => screenWidth < Breakpoints.xs;

  /// Check if small (large phone / small tablet)
  bool get isSm =>
      screenWidth >= Breakpoints.xs && screenWidth < Breakpoints.sm;

  /// Check if medium (tablet / small laptop)
  bool get isMd =>
      screenWidth >= Breakpoints.sm && screenWidth < Breakpoints.md;

  /// Check if large (laptop / desktop)
  bool get isLg =>
      screenWidth >= Breakpoints.md && screenWidth < Breakpoints.lg;

  /// Check if extra large (large desktop / ultrawide)
  bool get isXl => screenWidth >= Breakpoints.lg;

  /// Get current responsive size
  ResponsiveSize get responsiveSize {
    if (isXl) return ResponsiveSize.xl;
    if (isLg) return ResponsiveSize.lg;
    if (isMd) return ResponsiveSize.md;
    if (isSm) return ResponsiveSize.sm;
    return ResponsiveSize.xs;
  }

  /// Check if mobile (xs or sm)
  bool get isMobile => isXs || isSm;

  /// Check if tablet (md)
  bool get isTablet => isMd;

  /// Check if desktop (lg or xl)
  bool get isDesktop => isLg || isXl;

  /// Responsive value selector
  ///
  /// Returns the appropriate value based on current breakpoint.
  /// Falls back to smaller breakpoint if specific size not provided.
  ///
  /// Example:
  /// ```dart
  /// final columns = context.responsive(
  ///   xs: 1,
  ///   sm: 2,
  ///   md: 3,
  ///   lg: 4,
  ///   xl: 5,
  /// );
  /// ```
  T responsive<T>({
    required T xs,
    T? sm,
    T? md,
    T? lg,
    T? xl,
  }) {
    if (isXl && xl != null) return xl;
    if (isLg && lg != null) return lg;
    if (isMd && md != null) return md;
    if (isSm && sm != null) return sm;
    return xs;
  }

  /// Get responsive padding
  EdgeInsets get responsivePadding {
    return EdgeInsets.symmetric(
      horizontal: responsive(
        xs: 16.0,
        sm: 20.0,
        md: 24.0,
        lg: 28.0,
        xl: 32.0,
      ),
      vertical: responsive(
        xs: 12.0,
        sm: 16.0,
        md: 20.0,
        lg: 24.0,
        xl: 28.0,
      ),
    );
  }

  /// Get responsive card padding
  EdgeInsets get cardPadding {
    return EdgeInsets.all(
      responsive(
        xs: 16.0,
        sm: 18.0,
        md: 20.0,
        lg: 24.0,
        xl: 28.0,
      ),
    );
  }

  /// Get responsive card elevation
  double get cardElevation {
    return responsive(
      xs: 1.0,
      sm: 1.5,
      md: 2.0,
      lg: 2.5,
      xl: 3.0,
    );
  }

  /// Get responsive border radius
  double get borderRadius {
    return responsive(
      xs: 12.0,
      sm: 14.0,
      md: 16.0,
      lg: 18.0,
      xl: 20.0,
    );
  }

  /// Get grid column count
  int get gridColumns {
    return responsive(
      xs: 1,
      sm: 2,
      md: 3,
      lg: 4,
      xl: 5,
    );
  }

  /// Get grid spacing
  double get gridSpacing {
    return responsive(
      xs: 12.0,
      sm: 14.0,
      md: 16.0,
      lg: 18.0,
      xl: 20.0,
    );
  }
}

// =====================================================
// Constrained Content Container
// =====================================================

/// Constrains main content to a readable width and centers it on wide screens
class AppScaffoldBody extends StatelessWidget {
  const AppScaffoldBody({
    super.key,
    required this.child,
    this.maxWidth = 1240.0,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? context.responsivePadding,
          child: child,
        ),
      ),
    );
  }
}

// =====================================================
// Responsive Grid Delegate
// =====================================================

/// Creates a responsive grid delegate based on breakpoint
class ResponsiveGridDelegate {
  const ResponsiveGridDelegate._();

  /// Get grid delegate for context
  static SliverGridDelegateWithFixedCrossAxisCount forContext(
    BuildContext context, {
    double? childAspectRatio,
    double? mainAxisSpacing,
    double? crossAxisSpacing,
  }) {
    final columns = context.gridColumns;
    final spacing = crossAxisSpacing ?? context.gridSpacing;

    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      childAspectRatio: childAspectRatio ?? _getAspectRatio(context),
      mainAxisSpacing: mainAxisSpacing ?? spacing,
      crossAxisSpacing: spacing,
    );
  }

  static double _getAspectRatio(BuildContext context) {
    return context.responsive(
      xs: 1.2,
      sm: 1.1,
      md: 1.1,
      lg: 1.1,
      xl: 1.15,
    );
  }
}

// =====================================================
// Responsive Card
// =====================================================

/// A card that adapts its styling based on breakpoint
class ResponsiveCard extends StatefulWidget {
  const ResponsiveCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.elevation,
    this.enableHover = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final double? elevation;
  final bool enableHover;

  @override
  State<ResponsiveCard> createState() => _ResponsiveCardState();
}

class _ResponsiveCardState extends State<ResponsiveCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final baseElevation = widget.elevation ?? context.cardElevation;
    final elevation = _isHovered && isDesktop
        ? baseElevation + 2
        : baseElevation;

    Widget card = Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.borderRadius),
      ),
      child: Padding(
        padding: widget.padding ?? context.cardPadding,
        child: widget.child,
      ),
    );

    if (widget.onTap != null) {
      card = InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(context.borderRadius),
        child: card,
      );
    }

    if (widget.enableHover && isDesktop) {
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: widget.onTap != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: AnimatedScale(
          scale: _isHovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: card,
        ),
      );
    }

    return card;
  }
}

// =====================================================
// Responsive Spacing
// =====================================================

/// Responsive spacing utilities
class ResponsiveSpacing {
  const ResponsiveSpacing._();

  /// Extra small spacing
  static double xs(BuildContext context) => context.responsive(
    xs: 4.0,
    sm: 6.0,
    md: 8.0,
  );

  /// Small spacing
  static double sm(BuildContext context) => context.responsive(
    xs: 8.0,
    sm: 10.0,
    md: 12.0,
    lg: 14.0,
  );

  /// Medium spacing
  static double md(BuildContext context) => context.responsive(
    xs: 12.0,
    sm: 14.0,
    md: 16.0,
    lg: 18.0,
    xl: 20.0,
  );

  /// Large spacing
  static double lg(BuildContext context) => context.responsive(
    xs: 16.0,
    sm: 18.0,
    md: 20.0,
    lg: 24.0,
    xl: 28.0,
  );

  /// Extra large spacing
  static double xl(BuildContext context) => context.responsive(
    xs: 20.0,
    sm: 24.0,
    md: 28.0,
    lg: 32.0,
    xl: 40.0,
  );

  /// Extra extra large spacing
  static double xxl(BuildContext context) => context.responsive(
    xs: 24.0,
    sm: 32.0,
    md: 40.0,
    lg: 48.0,
    xl: 56.0,
  );
}

// =====================================================
// Responsive Typography Scale
// =====================================================

/// Get scaled text style based on breakpoint
extension ResponsiveTextStyle on TextStyle {
  TextStyle scaleForBreakpoint(BuildContext context) {
    final scale = context.responsive(
      xs: 1.0,
      sm: 1.0,
      md: 1.05,
      lg: 1.1,
      xl: 1.15,
    );

    return copyWith(
      fontSize: fontSize != null ? fontSize! * scale : null,
      height: height != null ? height! / scale : null, // Adjust line height
    );
  }
}

// =====================================================
// Platform Helpers
// =====================================================

/// Check if running on web
bool get isWeb => kIsWeb;

/// Check if running on desktop (web with wide screen or native desktop)
bool isDesktopPlatform(BuildContext context) {
  if (kIsWeb) {
    return context.isDesktop;
  }
  return defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.windows;
}

/// Check if touch device
bool isTouchDevice() {
  if (kIsWeb) {
    return true; // Assume touch capability on web
  }
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}
