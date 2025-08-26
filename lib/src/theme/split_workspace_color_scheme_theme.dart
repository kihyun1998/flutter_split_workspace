import 'package:flutter/material.dart';

/// Centralized color scheme for consistent theming across the workspace.
///
/// This color scheme follows Material Design 3 principles and provides
/// a cohesive color system for all workspace components. It acts as the
/// foundation for theming tabs, backgrounds, borders, and text elements.
///
/// The color scheme integrates with [SplitWorkspaceTheme] to provide
/// automatic color resolution when component-specific colors are not defined.
///
/// Example usage:
/// ```dart
/// const colorScheme = SplitWorkspaceColorSchemeTheme(
///   primary: Colors.blue,
///   background: Colors.white,
///   surface: Color(0xFFF5F5F5),
/// );
/// ```
class SplitWorkspaceColorSchemeTheme {
  /// Primary color used for active elements and highlights.
  ///
  /// Applied to active tab indicators, buttons, and focus states.
  /// Should provide good contrast against [primaryContainer].
  final Color primary;

  /// Container color for primary elements.
  ///
  /// Used for active tab backgrounds, button backgrounds,
  /// and other primary element containers.
  final Color primaryContainer;

  /// Text/icon color used on [primaryContainer] backgrounds.
  ///
  /// Must provide sufficient contrast against [primaryContainer]
  /// for accessibility compliance.
  final Color onPrimaryContainer;

  /// Main background color of the workspace.
  ///
  /// Used as the default background for the entire workspace
  /// when no specific background color is provided.
  final Color background;

  /// Surface color for content areas.
  ///
  /// Applied to tab content areas, panels, and other surface elements.
  /// Should be lighter than [background] in light themes.
  final Color surface;

  /// Primary text/icon color used on [surface] backgrounds.
  ///
  /// Used for tab titles, content text, and icons that appear
  /// on surface elements.
  final Color onSurface;

  /// Color for elevated surface elements.
  ///
  /// Used for inactive tab backgrounds, hover states, and
  /// subtle elevated elements. Should be between [surface] and [background].
  final Color surfaceContainerHighest;

  /// Secondary text/icon color for less prominent elements.
  ///
  /// Applied to placeholder text, secondary labels, and disabled elements.
  /// Should have lower contrast than [onSurface] for hierarchy.
  final Color onSurfaceVariant;

  /// Border and outline color.
  ///
  /// Used for tab borders, workspace borders, focus rings,
  /// and other structural elements that need definition.
  final Color outline;

  /// Color for dividers and separators.
  ///
  /// Applied to visual separators between tabs, content sections,
  /// and other UI divisions. Usually lighter than [outline].
  final Color dividerColor;

  /// Creates a color scheme with default Material Design colors.
  ///
  /// All colors have sensible defaults that work well together,
  /// but can be customized for specific brand or design requirements.
  const SplitWorkspaceColorSchemeTheme({
    this.primary = Colors.blueGrey,
    this.primaryContainer = Colors.blueGrey,
    this.onPrimaryContainer = Colors.white,
    this.background = Colors.white,
    this.surface = Colors.white,
    this.onSurface = Colors.black87,
    this.surfaceContainerHighest = Colors.black12,
    this.onSurfaceVariant = Colors.black54,
    this.outline = Colors.grey,
    this.dividerColor = Colors.black26,
  });

  /// Creates a copy of this color scheme with some colors replaced.
  ///
  /// This method allows for easy customization of specific colors
  /// while maintaining the coherence of the overall color scheme.
  ///
  /// Example:
  /// ```dart
  /// final customColorScheme = baseColorScheme.copyWith(
  ///   primary: Colors.purple,
  ///   primaryContainer: Colors.purple.shade100,
  /// );
  /// ```
  SplitWorkspaceColorSchemeTheme copyWith({
    Color? primary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? background,
    Color? surface,
    Color? onSurface,
    Color? surfaceContainerHighest,
    Color? onSurfaceVariant,
    Color? outline,
    Color? dividerColor,
  }) {
    return SplitWorkspaceColorSchemeTheme(
      primary: primary ?? this.primary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      surfaceContainerHighest:
          surfaceContainerHighest ?? this.surfaceContainerHighest,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      outline: outline ?? this.outline,
      dividerColor: dividerColor ?? this.dividerColor,
    );
  }
}
