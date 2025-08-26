import 'package:flutter/material.dart';

import '../theme/split_workspace_theme.dart';

/// A themed scrollbar widget that integrates with SplitWorkspace color scheme
///
/// This widget creates a scrollbar with proper theme integration and color scheme fallbacks,
/// ensuring visual consistency across the workspace interface.
class ThemedScrollbarWidget extends StatelessWidget {
  /// Theme configuration for styling
  final SplitWorkspaceTheme theme;

  /// Controller for the scrollbar
  final ScrollController scrollController;

  /// Child widget to be wrapped with scrollbar
  final Widget child;

  /// Whether to force show the scrollbar (overrides theme settings)
  final bool? showScrollbar;

  const ThemedScrollbarWidget({
    super.key,
    required this.theme,
    required this.scrollController,
    required this.child,
    this.showScrollbar,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;
    final scrollbarTheme = theme.scrollbar;
    final shouldShowScrollbar = showScrollbar ?? scrollbarTheme.alwaysVisible;

    // Create ScrollbarThemeData with proper color configuration
    final scrollbarThemeData = ScrollbarThemeData(
      thickness: WidgetStateProperty.all(scrollbarTheme.thickness),
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) {
          return scrollbarTheme.hoverColor ??
              scrollbarTheme.thumbColor?.withOpacity(0.8) ??
              colorScheme.outline.withOpacity(0.8);
        }
        return scrollbarTheme.thumbColor ?? colorScheme.outline;
      }),
      trackColor: WidgetStateProperty.all(
        scrollbarTheme.trackColor ?? colorScheme.surfaceContainerHighest,
      ),
      radius: Radius.circular(scrollbarTheme.radius),
      trackVisibility: WidgetStateProperty.all(scrollbarTheme.trackVisible),
      thumbVisibility: WidgetStateProperty.all(shouldShowScrollbar),
    );

    return ScrollbarTheme(
      data: scrollbarThemeData,
      child: Scrollbar(
        controller: scrollController,
        thumbVisibility: shouldShowScrollbar,
        trackVisibility: scrollbarTheme.trackVisible,
        child: child,
      ),
    );
  }
}
