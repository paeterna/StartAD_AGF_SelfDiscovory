import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A widget that displays a custom SVG icon
///
/// This widget wraps [SvgPicture] to provide a consistent API
/// similar to Flutter's [Icon] widget.
///
/// Usage:
/// ```dart
/// AppIcon(
///   AppIcons.dashboard,
///   size: 24,
///   color: Theme.of(context).colorScheme.primary,
/// )
/// ```
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.assetPath, {
    super.key,
    this.size = 24.0,
    this.color,
    this.semanticLabel,
  });

  /// Path to the SVG asset
  final String assetPath;

  /// Size of the icon (width and height)
  final double size;

  /// Color to apply to the icon
  /// If null, uses the current text color from the theme
  final Color? color;

  /// Semantic label for accessibility
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? IconTheme.of(context).color ?? Theme.of(context).iconTheme.color;

    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      colorFilter: iconColor != null
          ? ColorFilter.mode(iconColor, BlendMode.srcIn)
          : null,
      semanticsLabel: semanticLabel,
      fit: BoxFit.contain,
    );
  }
}

/// A button with a custom SVG icon
///
/// Similar to [IconButton] but uses custom SVG icons.
///
/// Usage:
/// ```dart
/// AppIconButton(
///   icon: AppIcons.settings,
///   onPressed: () => print('Settings'),
///   tooltip: 'Settings',
/// )
/// ```
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 24.0,
    this.color,
    this.tooltip,
    this.padding = const EdgeInsets.all(8.0),
  });

  /// Path to the SVG asset
  final String icon;

  /// Callback when the button is pressed
  final VoidCallback? onPressed;

  /// Size of the icon
  final double size;

  /// Color of the icon
  final Color? color;

  /// Tooltip text
  final String? tooltip;

  /// Padding around the icon
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final button = InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(size / 2),
      child: Padding(
        padding: padding,
        child: AppIcon(
          icon,
          size: size,
          color: color,
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip,
        child: button,
      );
    }

    return button;
  }
}
