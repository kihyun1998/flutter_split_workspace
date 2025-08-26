// lib/src/theme/scrollbar_theme.dart
import 'package:flutter/material.dart';

/// Configuration for scrollbar appearance and behavior
class SplitWorkspaceScrollbarTheme {
  /// Whether to show scrollbar
  final bool visible;

  /// Whether scrollbar is always visible (true) or only when scrolling (false)
  final bool alwaysVisible;

  /// Whether to show the scrollbar track
  final bool trackVisible;

  /// Thickness of the scrollbar in pixels
  final double thickness;

  /// Radius of the scrollbar corners
  final double radius;

  /// Color of the scrollbar thumb
  final Color? thumbColor;

  /// Color of the scrollbar track
  final Color? trackColor;

  /// Color of the scrollbar when hovered
  final Color? hoverColor;

  const SplitWorkspaceScrollbarTheme({
    this.visible = true,
    this.alwaysVisible = true,
    this.trackVisible = true,
    this.thickness = 8.0,
    this.radius = 4.0,
    this.thumbColor,
    this.trackColor,
    this.hoverColor,
  });

  /// Creates a copy of this theme with the given fields replaced
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

  /// Default scrollbar theme
  static const SplitWorkspaceScrollbarTheme defaultTheme =
      SplitWorkspaceScrollbarTheme();

  /// Hidden scrollbar theme (invisible scrollbar)
  static const SplitWorkspaceScrollbarTheme hidden =
      SplitWorkspaceScrollbarTheme(
        visible: false,
        alwaysVisible: false,
        trackVisible: false,
      );

  /// Minimal scrollbar theme (thin and subtle)
  static const SplitWorkspaceScrollbarTheme minimal =
      SplitWorkspaceScrollbarTheme(
        visible: true,
        alwaysVisible: false,
        trackVisible: false,
        thickness: 4.0,
        radius: 2.0,
      );
}
