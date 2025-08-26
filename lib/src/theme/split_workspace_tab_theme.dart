// ignore_for_file: public_member_api_docs, sort_constructors_first
// lib/src/theme/tab_theme.dart
import 'package:flutter/material.dart';

/// Configuration for tab appearance and dimensions
class SplitWorkspaceTabTheme {
  /// Height of the tab bar in pixels
  final double height;

  /// Width of each tab in pixels
  final double width;

  /// Minimum width constraint for tabs
  final double? minWidth;

  /// Maximum width constraint for tabs
  final double? maxWidth;

  /// Border radius for tab corners
  final double borderRadius;

  /// Background color for active tabs
  final Color? activeBackgroundColor;

  /// Background color for inactive tabs
  final Color? inactiveBackgroundColor;

  /// Text color for active tabs
  final Color? activeTextColor;

  /// Text color for inactive tabs
  final Color? inactiveTextColor;

  /// Border color for tabs
  final Color? borderColor;

  /// Text style for tab titles
  final TextStyle? textStyle;

  final TextStyle? inactiveTextStyle;

  /// Whether to show drag handle icons
  final bool showDragHandle;

  /// Size of the drag handle icon
  final double dragHandleSize;

  /// Size of the close button icon
  final double closeButtonSize;

  const SplitWorkspaceTabTheme({
    this.height = 36.0,
    this.width = 160.0,
    this.minWidth,
    this.maxWidth,
    this.borderRadius = 0.0,
    this.activeBackgroundColor,
    this.inactiveBackgroundColor,
    this.activeTextColor,
    this.inactiveTextColor,
    this.borderColor,
    this.textStyle,
    this.inactiveTextStyle,
    this.showDragHandle = true,
    this.dragHandleSize = 12.0,
    this.closeButtonSize = 16.0,
  });

  /// Creates a copy of this theme with the given fields replaced
  SplitWorkspaceTabTheme copyWith({
    double? height,
    double? width,
    double? minWidth,
    double? maxWidth,
    double? borderRadius,
    Color? activeBackgroundColor,
    Color? inactiveBackgroundColor,
    Color? activeTextColor,
    Color? inactiveTextColor,
    Color? borderColor,
    TextStyle? textStyle,
    TextStyle? inactiveTextStyle,
    bool? showDragHandle,
    double? dragHandleSize,
    double? closeButtonSize,
  }) {
    return SplitWorkspaceTabTheme(
      height: height ?? this.height,
      width: width ?? this.width,
      minWidth: minWidth ?? this.minWidth,
      maxWidth: maxWidth ?? this.maxWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      activeBackgroundColor:
          activeBackgroundColor ?? this.activeBackgroundColor,
      inactiveBackgroundColor:
          inactiveBackgroundColor ?? this.inactiveBackgroundColor,
      activeTextColor: activeTextColor ?? this.activeTextColor,
      inactiveTextColor: inactiveTextColor ?? this.inactiveTextColor,
      borderColor: borderColor ?? this.borderColor,
      textStyle: textStyle ?? this.textStyle,
      inactiveTextStyle: inactiveTextStyle ?? this.inactiveTextStyle,
      showDragHandle: showDragHandle ?? this.showDragHandle,
      dragHandleSize: dragHandleSize ?? this.dragHandleSize,
      closeButtonSize: closeButtonSize ?? this.closeButtonSize,
    );
  }

  /// Default tab theme
  static const SplitWorkspaceTabTheme defaultTheme = SplitWorkspaceTabTheme();

  /// Compact tab theme (smaller dimensions)
  static const SplitWorkspaceTabTheme compact = SplitWorkspaceTabTheme(
    height: 28.0,
    width: 120.0,
    dragHandleSize: 10.0,
    closeButtonSize: 14.0,
  );

  /// Rounded tab theme (with border radius)
  static const SplitWorkspaceTabTheme rounded = SplitWorkspaceTabTheme(
    borderRadius: 8.0,
  );
}
