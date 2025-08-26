// ignore_for_file: public_member_api_docs, sort_constructors_first
// lib/src/theme/split_workspace_theme.dart
import 'package:flutter/material.dart';

import 'split_workspace_color_scheme_theme.dart';
import 'split_workspace_scrollbar_theme.dart';
import 'split_workspace_tab_theme.dart';

/// Main theme configuration for the Split Workspace package
class SplitWorkspaceTheme {
  /// Theme configuration for tabs
  final SplitWorkspaceTabTheme tab;

  /// Theme configuration for scrollbars
  final SplitWorkspaceScrollbarTheme scrollbar;

  final SplitWorkspaceColorSchemeTheme colorScheme;

  /// Background color for the workspace
  final Color? backgroundColor;

  /// Border color for the workspace
  final Color borderColor;

  /// Border width for the workspace
  final double borderWidth;

  /// Border radius for the workspace
  final double borderRadius;

  const SplitWorkspaceTheme({
    this.tab = const SplitWorkspaceTabTheme(),
    this.scrollbar = const SplitWorkspaceScrollbarTheme(),
    this.colorScheme = const SplitWorkspaceColorSchemeTheme(),
    this.backgroundColor,
    this.borderColor = Colors.black,
    this.borderWidth = 1.0,
    this.borderRadius = 0.0,
  });

  /// Creates a copy of this theme with the given fields replaced
  SplitWorkspaceTheme copyWith({
    SplitWorkspaceTabTheme? tab,
    SplitWorkspaceScrollbarTheme? scrollbar,
    SplitWorkspaceColorSchemeTheme? colorScheme,
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    double? borderRadius,
  }) {
    return SplitWorkspaceTheme(
      tab: tab ?? this.tab,
      scrollbar: scrollbar ?? this.scrollbar,
      colorScheme: colorScheme ?? this.colorScheme,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  /// Default theme using Flutter's Material Design
  static const SplitWorkspaceTheme defaultTheme = SplitWorkspaceTheme();

  /// Dark theme preset
  static const SplitWorkspaceTheme dark = SplitWorkspaceTheme(
    tab: SplitWorkspaceTabTheme(
      activeBackgroundColor: Color(0xFF2D2D2D),
      inactiveBackgroundColor: Color(0xFF1E1E1E),
      activeTextColor: Colors.white,
      inactiveTextColor: Color(0xFFB3B3B3),
      borderColor: Color(0xFF404040),
    ),
    scrollbar: SplitWorkspaceScrollbarTheme(
      thickness: 6.0,
      thumbColor: Color(0xFF606060),
      trackColor: Color(0xFF2D2D2D),
    ),
    backgroundColor: Color(0xFF1E1E1E),
    borderColor: Color(0xFF404040),
  );

  /// Light theme preset
  static const SplitWorkspaceTheme light = SplitWorkspaceTheme(
    tab: SplitWorkspaceTabTheme(
      activeBackgroundColor: Colors.white,
      inactiveBackgroundColor: Color(0xFFF5F5F5),
      activeTextColor: Color(0xFF212121),
      inactiveTextColor: Color(0xFF757575),
      borderColor: Color(0xFFE0E0E0),
    ),
    scrollbar: SplitWorkspaceScrollbarTheme(
      thickness: 8.0,
      thumbColor: Color(0xFFBDBDBD),
      trackColor: Color(0xFFF5F5F5),
    ),
    backgroundColor: Colors.white,
    borderColor: Color(0xFFE0E0E0),
  );

  /// Minimal theme (clean and simple)
  static const SplitWorkspaceTheme minimal = SplitWorkspaceTheme(
    tab: SplitWorkspaceTabTheme(borderRadius: 4.0, showDragHandle: false),
    scrollbar: SplitWorkspaceScrollbarTheme.minimal,
    borderWidth: 0.0,
  );

  /// Compact theme (smaller dimensions)
  static const SplitWorkspaceTheme compact = SplitWorkspaceTheme(
    tab: SplitWorkspaceTabTheme.compact,
    scrollbar: SplitWorkspaceScrollbarTheme(thickness: 6.0, radius: 3.0),
  );
}
