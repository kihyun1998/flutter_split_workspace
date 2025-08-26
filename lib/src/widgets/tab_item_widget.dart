// lib/src/widgets/tab_item_widget.dart (수정)
import 'package:flutter/material.dart';

import '../models/drag_data.dart';
import '../models/tab_data.dart';
import '../theme/split_workspace_theme.dart';

/// Individual tab item widget with drag and drop functionality
///
/// This widget represents a single tab in the tab bar and handles:
/// - Tab appearance (active/inactive states)
/// - Drag and drop interactions
/// - Close functionality
/// - Theme integration with colorScheme
class TabItemWidget extends StatelessWidget {
  /// The tab data to display
  final TabData tab;

  /// Whether this tab is currently active
  final bool isActive;

  /// Callback when the tab is tapped
  final VoidCallback? onTap;

  /// Callback when the close button is tapped
  final VoidCallback? onClose;

  /// Index of this tab in the tab list
  final int tabIndex;

  /// Workspace ID for drag and drop operations
  final String workspaceId;

  /// Theme configuration for styling
  final SplitWorkspaceTheme? theme;

  const TabItemWidget({
    super.key,
    required this.tab,
    required this.isActive,
    this.onTap,
    this.onClose,
    required this.tabIndex,
    required this.workspaceId,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final workspaceTheme = theme ?? SplitWorkspaceTheme.defaultTheme;

    return LongPressDraggable<DragData>(
      // Drag data payload
      data: DragData(
        tab: tab,
        originalIndex: tabIndex,
        sourceWorkspaceId: workspaceId,
      ),

      // Prevent accidental drags
      delay: const Duration(milliseconds: 200),

      // Widget shown while dragging
      feedback: _buildDragFeedback(context, workspaceTheme),

      // Widget shown at original position during drag
      childWhenDragging: _buildDragPlaceholder(context, workspaceTheme),

      // Normal tab appearance
      child: _buildNormalTab(context, workspaceTheme),
    );
  }

  /// Builds the normal tab appearance with theme-integrated colors.
  ///
  /// Creates the standard tab button with appropriate colors based on
  /// the active/inactive state, using the color scheme for consistency
  /// when specific tab colors aren't provided.
  Widget _buildNormalTab(BuildContext context, SplitWorkspaceTheme theme) {
    final colorScheme = theme.colorScheme;
    final tabTheme = theme.tab;

    // Determine colors based on active state and colorScheme
    final backgroundColor = isActive
        ? (tabTheme.activeBackgroundColor ?? colorScheme.surface)
        : (tabTheme.inactiveBackgroundColor ??
              colorScheme.surfaceContainerHighest);

    final textColor = isActive
        ? (tabTheme.activeTextColor ?? colorScheme.onSurface)
        : (tabTheme.inactiveTextColor ?? colorScheme.onSurfaceVariant);

    final borderColor = tabTheme.borderColor ?? colorScheme.dividerColor;

    return Container(
      height: tabTheme.height,
      constraints: BoxConstraints(
        minWidth: tabTheme.minWidth ?? 120,
        maxWidth: tabTheme.maxWidth ?? 200,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(tabTheme.borderRadius),
        border: Border(right: BorderSide(color: borderColor, width: 1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(tabTheme.borderRadius),
          child: Padding(
            padding: EdgeInsets.only(left: 12, right: tab.closeable ? 4 : 12),
            child: Row(
              children: [
                // Drag handle icon (if enabled)
                if (tabTheme.showDragHandle) ...[
                  Icon(
                    Icons.drag_indicator,
                    size: tabTheme.dragHandleSize,
                    color: textColor.withOpacity(0.7),
                  ),
                  const SizedBox(width: 6),
                ],

                // Tab title
                Expanded(
                  child: Text(
                    tab.title,
                    style: (tabTheme.textStyle ?? const TextStyle(fontSize: 13))
                        .copyWith(color: textColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Close button
                if (tab.closeable)
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onClose,
                        borderRadius: BorderRadius.circular(4),
                        child: Icon(
                          Icons.close,
                          size: tabTheme.closeButtonSize,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the visual feedback widget shown while dragging.
  ///
  /// Creates a floating representation of the tab being dragged,
  /// with elevated appearance and primary colors to indicate
  /// the drag state clearly to the user.
  Widget _buildDragFeedback(BuildContext context, SplitWorkspaceTheme theme) {
    final colorScheme = theme.colorScheme;
    final tabTheme = theme.tab;

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(tabTheme.borderRadius),
      child: Container(
        height: tabTheme.height,
        width: 160, // Fixed width for feedback
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withOpacity(0.9),
          borderRadius: BorderRadius.circular(tabTheme.borderRadius),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.7),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(Icons.tab, size: 16, color: colorScheme.onPrimaryContainer),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tab.title,
                  style: (tabTheme.textStyle ?? const TextStyle(fontSize: 13))
                      .copyWith(color: colorScheme.onPrimaryContainer),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the placeholder widget shown at the original tab position during drag.
  ///
  /// Creates a subtle, semi-transparent representation that indicates
  /// where the tab originally was, maintaining layout stability during
  /// the drag operation.
  Widget _buildDragPlaceholder(
    BuildContext context,
    SplitWorkspaceTheme theme,
  ) {
    final colorScheme = theme.colorScheme;
    final tabTheme = theme.tab;

    return Container(
      height: tabTheme.height,
      constraints: BoxConstraints(
        minWidth: tabTheme.minWidth ?? 120,
        maxWidth: tabTheme.maxWidth ?? 200,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: Border(
          right: BorderSide(color: colorScheme.dividerColor, width: 1),
        ),
        borderRadius: BorderRadius.circular(tabTheme.borderRadius),
      ),
      child: Center(
        child: Container(
          width: 80,
          height: 2,
          decoration: BoxDecoration(
            color: colorScheme.outline.withOpacity(0.5),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }
}
