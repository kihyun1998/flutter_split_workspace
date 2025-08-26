import 'package:flutter/material.dart';

/// Theme configuration for scrollbars in the workspace tab system.
///
/// Controls the appearance and behavior of scrollbars that appear when
/// the tab bar content exceeds the available horizontal space and
/// horizontal scrolling is needed.
///
/// When colors are not specified, they fallback to the workspace's
/// [SplitWorkspaceColorSchemeTheme] for consistent theming.
///
/// Example usage:
/// ```dart
/// const scrollbarTheme = SplitWorkspaceScrollbarTheme(
///   thickness: 6.0,
///   alwaysVisible: true,
///   trackVisible: true,
/// );
/// ```
class SplitWorkspaceScrollbarTheme {
  /// Whether to show the scrollbar at all.
  ///
  /// When false, no scrollbar will be displayed even if content
  /// is scrollable. Set to true to enable scrollbar functionality.
  final bool visible;

  /// Whether the scrollbar is always visible or appears only during scrolling.
  ///
  /// When true, the scrollbar thumb is permanently visible.
  /// When false, it appears only when scrolling is active and fades out
  /// after a period of inactivity for a cleaner appearance.
  final bool alwaysVisible;

  /// Whether to show the scrollbar track (background).
  ///
  /// When true, displays a background track that shows the full scrollable
  /// area. When false, only the thumb (draggable indicator) is visible
  /// for a more minimal appearance.
  final bool trackVisible;

  /// Thickness of the scrollbar in pixels.
  ///
  /// Determines how wide the scrollbar appears. Larger values make it
  /// easier to target with the cursor but take up more screen space.
  final double thickness;

  /// Border radius for rounded scrollbar corners in pixels.
  ///
  /// Applied to both the thumb and track elements when visible.
  /// Set to 0.0 for square corners or a positive value for rounded edges.
  final double radius;

  /// Color of the scrollbar thumb (the draggable part).
  ///
  /// When null, uses [SplitWorkspaceColorSchemeTheme.onSurfaceVariant]
  /// with reduced opacity for automatic color scheme integration.
  final Color? thumbColor;

  /// Color of the scrollbar track (background area).
  ///
  /// When null, uses [SplitWorkspaceColorSchemeTheme.surfaceContainerHighest]
  /// for automatic color scheme integration.
  final Color? trackColor;

  /// Color of the scrollbar when hovered with the mouse.
  ///
  /// When null, uses a lighter variant of [thumbColor] or the
  /// color scheme's hover color for interactive feedback.
  final Color? hoverColor;

  /// Creates a scrollbar theme with configurable appearance options.
  ///
  /// All parameters have defaults optimized for a clean, modern
  /// scrollbar appearance that works well in most contexts.
  const SplitWorkspaceScrollbarTheme({
    this.visible = true,
    this.alwaysVisible = false,
    this.trackVisible = false,
    this.thickness = 3.0,
    this.radius = 4.0,
    this.thumbColor,
    this.trackColor,
    this.hoverColor,
  });

  /// Creates a copy of this scrollbar theme with some properties replaced.
  ///
  /// This method allows for easy customization of specific scrollbar
  /// properties while preserving the rest of the theme configuration.
  ///
  /// Example:
  /// ```dart
  /// final customScrollbarTheme = SplitWorkspaceScrollbarTheme.defaultTheme.copyWith(
  ///   thickness: 12.0,
  ///   alwaysVisible: true,
  ///   trackVisible: true,
  /// );
  /// ```
  SplitWorkspaceScrollbarTheme copyWith({
    bool? visible,
    bool? alwaysVisible,
    bool? trackVisible,
    double? thickness,
    double? radius,
    Color? thumbColor,
    Color? trackColor,
    Color? hoverColor,
  }) {
    return SplitWorkspaceScrollbarTheme(
      visible: visible ?? this.visible,
      alwaysVisible: alwaysVisible ?? this.alwaysVisible,
      trackVisible: trackVisible ?? this.trackVisible,
      thickness: thickness ?? this.thickness,
      radius: radius ?? this.radius,
      thumbColor: thumbColor ?? this.thumbColor,
      trackColor: trackColor ?? this.trackColor,
      hoverColor: hoverColor ?? this.hoverColor,
    );
  }

  /// Default scrollbar theme with balanced visibility and sizing.
  ///
  /// Provides a clean appearance that shows during scrolling but fades
  /// when not in use, with medium thickness suitable for most interfaces.
  static const SplitWorkspaceScrollbarTheme defaultTheme =
      SplitWorkspaceScrollbarTheme();

  /// Hidden scrollbar theme that completely disables scrollbar display.
  ///
  /// Useful when you want scrolling functionality without visual indicators,
  /// creating a completely clean interface.
  static const SplitWorkspaceScrollbarTheme hidden =
      SplitWorkspaceScrollbarTheme(
        visible: false,
        alwaysVisible: false,
        trackVisible: false,
      );

  /// Minimal scrollbar theme optimized for subtle, unobtrusive scrolling.
  ///
  /// Features a thin scrollbar that appears only when needed,
  /// perfect for interfaces where screen space is at a premium.
  static const SplitWorkspaceScrollbarTheme minimal =
      SplitWorkspaceScrollbarTheme(
        visible: true,
        alwaysVisible: false,
        trackVisible: false,
        thickness: 4.0,
        radius: 2.0,
      );
}
