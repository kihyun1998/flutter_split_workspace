// lib/src/widgets/tab_item_widget.dart (수정)
import 'package:flutter/material.dart';

import '../../models/drag_data.dart' show DragData;
import '../../models/tab_data.dart' show TabData;
import '../../theme/split_workspace_theme.dart' show SplitWorkspaceTheme;

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

  /// Callback when a tab is dropped before this tab
  final Function(int sourceIndex, int targetIndex)? onTabReorder;

  /// Callback when left side of tab is hovered during drag
  final VoidCallback? onLeftHover;

  /// Callback when right side of tab is hovered during drag
  final VoidCallback? onRightHover;

  /// Callback when hover ends
  final VoidCallback? onHoverEnd;

  const TabItemWidget({
    super.key,
    required this.tab,
    required this.isActive,
    this.onTap,
    this.onClose,
    required this.tabIndex,
    required this.workspaceId,
    this.theme,
    this.onTabReorder,
    this.onLeftHover,
    this.onRightHover,
    this.onHoverEnd,
  });

  @override
  Widget build(BuildContext context) {
    final workspaceTheme = theme ?? SplitWorkspaceTheme.defaultTheme;

    return SizedBox(
      height: workspaceTheme.tab.height,
      child: Stack(
        children: [
          // Main draggable tab
          LongPressDraggable<DragData>(
            data: DragData(
              tab: tab,
              originalIndex: tabIndex,
              sourceWorkspaceId: workspaceId,
            ),
            delay: const Duration(milliseconds: 200),
            feedback: _buildDragFeedback(context, workspaceTheme),
            childWhenDragging: _buildDragPlaceholder(context, workspaceTheme),
            dragAnchorStrategy: (draggable, context, position) {
              // 피드백 위젯의 좌상단이 마우스 포인터 위치가 되도록 설정
              return Offset.zero;
            },
            child: _buildNormalTab(context, workspaceTheme),
          ),

          // Left hover zone (activate left drop zone)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: workspaceTheme.tab.width / 2, // Half of minimum tab width
            child: DragTarget<DragData>(
              onWillAcceptWithDetails: (details) =>
                  _canAcceptDrag(details.data),
              onAcceptWithDetails: (details) => _handleLeftDrop(details.data),
              onMove: (details) => onLeftHover?.call(),
              onLeave: (data) => onHoverEnd?.call(),
              builder: (context, candidateData, rejectedData) {
                return Container(); // No visual decoration here
              },
            ),
          ),

          // Right hover zone (activate right drop zone)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: workspaceTheme.tab.width / 2, // Half of minimum tab width
            child: DragTarget<DragData>(
              onWillAcceptWithDetails: (details) =>
                  _canAcceptDrag(details.data),
              onAcceptWithDetails: (details) => _handleRightDrop(details.data),
              onMove: (details) => onRightHover?.call(),
              onLeave: (data) => onHoverEnd?.call(),
              builder: (context, candidateData, rejectedData) {
                return Container(); // No visual decoration here
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Checks if a dragged tab can be accepted by this tab
  bool _canAcceptDrag(DragData dragData) {
    // Accept if from same workspace and not the same tab
    return dragData.sourceWorkspaceId == workspaceId &&
        dragData.originalIndex != tabIndex;
  }

  /// Handles drop on the left side (insert before this tab)
  void _handleLeftDrop(DragData dragData) {
    if (_canAcceptDrag(dragData)) {
      final targetIndex = tabIndex;
      onTabReorder?.call(dragData.originalIndex, targetIndex);
    }
    // 드롭 후 indicator 비활성화
    onHoverEnd?.call();
  }

  /// Handles drop on the right side (insert after this tab)
  void _handleRightDrop(DragData dragData) {
    if (_canAcceptDrag(dragData)) {
      final targetIndex = tabIndex + 1;
      onTabReorder?.call(dragData.originalIndex, targetIndex);
    }
    // 드롭 후 indicator 비활성화
    onHoverEnd?.call();
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
      width: tabTheme.width, // 테마에서 width 사용
      constraints: BoxConstraints(
        minWidth: tabTheme.width,
        maxWidth: tabTheme.width,
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
      width: tabTheme.width, // 테마에서 width 사용
      constraints: BoxConstraints(
        minWidth: tabTheme.width,
        maxWidth: tabTheme.width,
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
