import 'package:flutter/material.dart';

import '../../../theme/split_workspace_theme.dart';

/// A drag indicator widget that shows where a dragged tab would be inserted
///
/// This widget displays a colored line that indicates where a dragged tab would be
/// inserted if dropped at the current position. Uses the theme's primary color
/// for visibility and consistency.
class DragIndicatorWidget extends StatelessWidget {
  /// Theme configuration for styling
  final SplitWorkspaceTheme theme;

  /// Index position where the indicator should be displayed
  final int? dragOverIndex;

  /// Width of each tab for position calculation
  final double tabWidth;

  const DragIndicatorWidget({
    super.key,
    required this.theme,
    required this.dragOverIndex,
    required this.tabWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (dragOverIndex == null) return const SizedBox.shrink();

    final colorScheme = theme.colorScheme;
    final indicatorX = dragOverIndex! * tabWidth;

    return Positioned(
      left: indicatorX,
      top: 0,
      child: Container(
        width: 3,
        height: theme.tab.height,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(1.5),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.3),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}
