// lib/src/theme/split_workspace_theme.dart (수정)
import 'package:flutter/material.dart';

import 'split_workspace_color_scheme_theme.dart';
import 'split_workspace_scrollbar_theme.dart';
import 'split_workspace_tab_theme.dart';

/// Main theme configuration for the Split Workspace package
///
/// This theme system provides a cohesive way to style the entire workspace
/// by using a centralized color scheme and individual component themes.
class SplitWorkspaceTheme {
  /// Theme configuration for tabs
  final SplitWorkspaceTabTheme tab;

  /// Theme configuration for scrollbars
  final SplitWorkspaceScrollbarTheme scrollbar;

  /// Centralized color scheme for consistent theming
  final SplitWorkspaceColorSchemeTheme colorScheme;

  /// Background color for the workspace
  /// If null, uses colorScheme.background
  final Color? backgroundColor;

  /// Border color for the workspace
  /// If null, uses colorScheme.outline
  final Color? borderColor;

  /// Border width for the workspace
  final double borderWidth;

  /// Border radius for the workspace
  final double borderRadius;

  const SplitWorkspaceTheme({
    this.tab = const SplitWorkspaceTabTheme(),
    this.scrollbar = const SplitWorkspaceScrollbarTheme(),
    this.colorScheme = const SplitWorkspaceColorSchemeTheme(),
    this.backgroundColor,
    this.borderColor,
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

  /// Effective background color (fallback to colorScheme if null)
  Color get effectiveBackgroundColor =>
      backgroundColor ?? colorScheme.background;

  /// Effective border color (fallback to colorScheme if null)
  Color get effectiveBorderColor => borderColor ?? colorScheme.outline;

  /// Default theme using Flutter's Material Design
  static const SplitWorkspaceTheme defaultTheme = SplitWorkspaceTheme(
    colorScheme: SplitWorkspaceColorSchemeTheme(),
    tab: SplitWorkspaceTabTheme(),
    scrollbar: SplitWorkspaceScrollbarTheme(),
  );

  /// Dark theme preset with coordinated color scheme
  static const SplitWorkspaceTheme dark = SplitWorkspaceTheme(
    colorScheme: SplitWorkspaceColorSchemeTheme(
      primary: Color(0xFFBB86FC),
      primaryContainer: Color(0xFF3700B3),
      onPrimaryContainer: Colors.white,
      background: Color(0xFF121212),
      surface: Color(0xFF1E1E1E),
      onSurface: Color(0xFFE1E1E1),
      surfaceContainerHighest: Color(0xFF2D2D2D),
      onSurfaceVariant: Color(0xFFB3B3B3),
      outline: Color(0xFF404040),
      dividerColor: Color(0xFF404040),
    ),
    tab: SplitWorkspaceTabTheme(
      // Colors will be derived from colorScheme in widgets
      textStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
    ),
    scrollbar: SplitWorkspaceScrollbarTheme(
      thickness: 6.0,
      // Colors will be derived from colorScheme in widgets
    ),
  );

  /// Light theme preset with coordinated color scheme
  static const SplitWorkspaceTheme light = SplitWorkspaceTheme(
    colorScheme: SplitWorkspaceColorSchemeTheme(
      primary: Color(0xFF6200EE),
      primaryContainer: Color(0xFFBB86FC),
      onPrimaryContainer: Color(0xFF000000),
      background: Color(0xFFFFFBFE),
      surface: Colors.white,
      onSurface: Color(0xFF1C1B1F),
      surfaceContainerHighest: Color(0xFFF5F5F5),
      onSurfaceVariant: Color(0xFF757575),
      outline: Color(0xFFE0E0E0),
      dividerColor: Color(0xFFE0E0E0),
    ),
    tab: SplitWorkspaceTabTheme(
      textStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
    ),
    scrollbar: SplitWorkspaceScrollbarTheme(thickness: 8.0),
  );

  /// Minimal theme (clean and simple) with subtle colors
  static const SplitWorkspaceTheme minimal = SplitWorkspaceTheme(
    colorScheme: SplitWorkspaceColorSchemeTheme(
      primary: Color(0xFF6366F1),
      primaryContainer: Color(0xFFEEF2FF),
      onPrimaryContainer: Color(0xFF1E1B4B),
      background: Color(0xFFFAFAFA),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF111827),
      surfaceContainerHighest: Color(0xFFF9FAFB),
      onSurfaceVariant: Color(0xFF6B7280),
      outline: Color(0xFFE5E7EB),
      dividerColor: Color(0xFFE5E7EB),
    ),
    tab: SplitWorkspaceTabTheme(
      borderRadius: 4.0,
      showDragHandle: false,
      textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    ),
    scrollbar: SplitWorkspaceScrollbarTheme.minimal,
    borderWidth: 0.0,
  );

  /// Compact theme (smaller dimensions) with efficient use of space
  static const SplitWorkspaceTheme compact = SplitWorkspaceTheme(
    colorScheme: SplitWorkspaceColorSchemeTheme(
      primary: Color(0xFF059669),
      primaryContainer: Color(0xFFD1FAE5),
      onPrimaryContainer: Color(0xFF064E3B),
      background: Color(0xFFF8FAFC),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF0F172A),
      surfaceContainerHighest: Color(0xFFF1F5F9),
      onSurfaceVariant: Color(0xFF64748B),
      outline: Color(0xFFCBD5E1),
      dividerColor: Color(0xFFE2E8F0),
    ),
    tab: SplitWorkspaceTabTheme.compact,
    scrollbar: SplitWorkspaceScrollbarTheme(thickness: 6.0, radius: 3.0),
  );

  /// High contrast theme for accessibility
  static const SplitWorkspaceTheme highContrast = SplitWorkspaceTheme(
    colorScheme: SplitWorkspaceColorSchemeTheme(
      primary: Color(0xFF000000),
      primaryContainer: Color(0xFF000000),
      onPrimaryContainer: Color(0xFFFFFFFF),
      background: Color(0xFFFFFFFF),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF000000),
      surfaceContainerHighest: Color(0xFFF0F0F0),
      onSurfaceVariant: Color(0xFF333333),
      outline: Color(0xFF000000),
      dividerColor: Color(0xFF000000),
    ),
    tab: SplitWorkspaceTabTheme(
      borderRadius: 0,
      textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    ),
    scrollbar: SplitWorkspaceScrollbarTheme(
      thickness: 10.0,
      alwaysVisible: true,
      trackVisible: true,
    ),
    borderWidth: 2.0,
  );
}
