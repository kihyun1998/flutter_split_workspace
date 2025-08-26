import 'package:flutter/material.dart';

/// Theme configuration for individual tabs within the workspace.
///
/// This theme controls the visual appearance and dimensions of tabs,
/// including colors, sizes, text styles, and interactive elements.
/// When colors are not specified, they fallback to the workspace's
/// [SplitWorkspaceColorSchemeTheme] for consistent theming.
///
/// Example usage:
/// ```dart
/// const tabTheme = SplitWorkspaceTabTheme(
///   height: 40.0,
///   borderRadius: 8.0,
///   showDragHandle: true,
///   textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
/// );
/// ```
class SplitWorkspaceTabTheme {
  /// Height of the tab bar in pixels.
  ///
  /// This determines the overall vertical space occupied by the tab bar.
  /// Defaults to 36.0 pixels, providing comfortable touch targets
  /// while maintaining a compact appearance.
  final double height;

  /// Preferred width of each tab in pixels.
  ///
  /// Individual tabs will attempt to use this width, but may be
  /// constrained by [minWidth] and [maxWidth] limits, or adjusted
  /// to fit the available horizontal space.
  final double width;

  /// Minimum width constraint for tabs in pixels.
  ///
  /// Prevents tabs from becoming too narrow to be usable.
  /// When null, no minimum constraint is applied.
  final double? minWidth;

  /// Maximum width constraint for tabs in pixels.
  ///
  /// Prevents tabs from becoming excessively wide with long titles.
  /// When null, no maximum constraint is applied.
  final double? maxWidth;

  /// Border radius for rounded tab corners in pixels.
  ///
  /// Applied to the top corners of tabs. Set to 0.0 for square tabs
  /// or a positive value for rounded corners. Defaults to 0.0.
  final double borderRadius;

  /// Background color for active (selected) tabs.
  ///
  /// When null, uses [SplitWorkspaceColorSchemeTheme.surface] for
  /// automatic color scheme integration.
  final Color? activeBackgroundColor;

  /// Background color for inactive (unselected) tabs.
  ///
  /// When null, uses [SplitWorkspaceColorSchemeTheme.surfaceContainerHighest]
  /// for automatic color scheme integration.
  final Color? inactiveBackgroundColor;

  /// Text color for active tab titles.
  ///
  /// When null, uses [SplitWorkspaceColorSchemeTheme.onSurface]
  /// for automatic color scheme integration.
  final Color? activeTextColor;

  /// Text color for inactive tab titles.
  ///
  /// When null, uses [SplitWorkspaceColorSchemeTheme.onSurfaceVariant]
  /// for automatic color scheme integration with reduced emphasis.
  final Color? inactiveTextColor;

  /// Border color for tab outlines.
  ///
  /// When null, uses [SplitWorkspaceColorSchemeTheme.outline]
  /// for automatic color scheme integration.
  final Color? borderColor;

  /// Text style for active tab titles.
  ///
  /// Defines font size, weight, and other text properties for
  /// the currently selected tab. When null, uses a default style
  /// that works well with the tab dimensions.
  final TextStyle? textStyle;

  /// Text style for inactive tab titles.
  ///
  /// Defines font size, weight, and other text properties for
  /// unselected tabs. When null, uses [textStyle] as the base
  /// with appropriate color adjustments.
  final TextStyle? inactiveTextStyle;

  /// Whether to show drag handle icons on tabs.
  ///
  /// When true, displays a grip icon (⋮⋮) that indicates tabs can be
  /// dragged for reordering. Set to false for a cleaner appearance
  /// if drag functionality is not needed or obvious from context.
  final bool showDragHandle;

  /// Size of the drag handle icon in pixels.
  ///
  /// Controls the visual size of the drag indicator icon.
  /// Should be proportional to the tab height for good visual balance.
  final double dragHandleSize;

  /// Size of the close button icon in pixels.
  ///
  /// Controls the size of the × button that appears on closeable tabs.
  /// Should be large enough for easy clicking but not overwhelming
  /// relative to the tab content.
  final double closeButtonSize;

  /// Creates a tab theme with default values.
  ///
  /// All parameters are optional and have sensible defaults suitable
  /// for most use cases. Customize specific properties as needed for
  /// your design requirements.
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

  /// Creates a copy of this tab theme with some properties replaced.
  ///
  /// This method allows for easy customization of specific tab properties
  /// while preserving the rest of the theme configuration.
  ///
  /// Example:
  /// ```dart
  /// final customTabTheme = SplitWorkspaceTabTheme.defaultTheme.copyWith(
  ///   height: 40.0,
  ///   borderRadius: 12.0,
  ///   showDragHandle: false,
  /// );
  /// ```
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

  /// Standard tab theme with default dimensions and styling.
  ///
  /// Provides a balanced appearance suitable for most applications
  /// with comfortable touch targets and readable text.
  static const SplitWorkspaceTabTheme defaultTheme = SplitWorkspaceTabTheme();

  /// Compact tab theme optimized for space-constrained layouts.
  ///
  /// Uses smaller dimensions to fit more tabs in limited horizontal
  /// space while maintaining usability.
  static const SplitWorkspaceTabTheme compact = SplitWorkspaceTabTheme(
    height: 28.0,
    width: 120.0,
    dragHandleSize: 10.0,
    closeButtonSize: 14.0,
  );

  /// Rounded tab theme with curved corners for a softer appearance.
  ///
  /// Applies border radius to create rounded tab corners while
  /// maintaining all other default styling properties.
  static const SplitWorkspaceTabTheme rounded = SplitWorkspaceTabTheme(
    borderRadius: 8.0,
  );
}
