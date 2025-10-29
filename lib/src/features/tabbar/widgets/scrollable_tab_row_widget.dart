import 'package:flutter/material.dart';

import '../../../theme/split_workspace_theme.dart';
import '../../drag_drop/models/drag_data.dart';
import '../../drag_drop/widgets/drop_zone_indicator.dart';
import '../../tab/models/tab_data.dart';
import '../../tab/widgets/tab_item_widget.dart';

/// A scrollable row widget that displays tab items horizontally
///
/// This widget creates a horizontally scrollable container with all tab items
/// arranged in a row, handling overflow when there are more tabs than can fit
/// in the available width.
///
/// **External State Control**: This widget does not manage drop zone state internally.
/// Users must provide [activeDropZoneIndex] and handle state updates via callbacks.
class ScrollableTabRowWidget extends StatelessWidget {
  /// List of tabs to display
  final List<TabData> tabs;

  /// Currently active tab ID
  final String? activeTabId;

  /// Callback when a tab is tapped
  final Function(String tabId)? onTabTap;

  /// Callback when a tab's close button is tapped
  final Function(String tabId)? onTabClose;

  /// Workspace identifier for drag and drop operations
  final String workspaceId;

  /// Theme configuration for styling
  final SplitWorkspaceTheme? theme;

  /// Controller for horizontal scrolling
  final ScrollController scrollController;

  /// Callback when tabs are reordered via drag and drop
  final Function(int oldIndex, int newIndex)? onTabReorder;

  /// Available width for the tab area (used for scroll optimization)
  final double? availableWidth;

  /// Active drop zone index (externally controlled, -1 means none active)
  final int? activeDropZoneIndex;

  /// Callback when a drop zone should be activated
  final Function(int index)? onDropZoneActivate;

  /// Callback when drop zones should be deactivated
  final VoidCallback? onDropZoneDeactivate;

  const ScrollableTabRowWidget({
    super.key,
    required this.tabs,
    this.activeTabId,
    this.onTabTap,
    this.onTabClose,
    required this.workspaceId,
    this.theme,
    required this.scrollController,
    this.onTabReorder,
    this.availableWidth,
    this.activeDropZoneIndex,
    this.onDropZoneActivate,
    this.onDropZoneDeactivate,
  });

  @override
  Widget build(BuildContext context) {
    final workspaceTheme = theme ?? SplitWorkspaceTheme.defaultTheme;

    // Calculate required width for all tabs
    final tabWidth = workspaceTheme.tab.width;
    final tabCount = tabs.length;

    // Stack width should only be based on actual tab content + last indicator
    final totalWidth = tabCount * tabWidth;

    // Use available width if provided and tabs fit within it, otherwise use calculated total width
    final containerWidth =
        availableWidth != null && totalWidth <= availableWidth!
        ? availableWidth!
        : totalWidth;

    final tabsRow = Row(
      children: tabs.asMap().entries.map((entry) {
        final index = entry.key;
        final tab = entry.value;

        return TabItemWidget(
          tab: tab,
          isActive: tab.id == activeTabId,
          onTap: () => onTabTap?.call(tab.id),
          onClose: tab.closeable ? () => onTabClose?.call(tab.id) : null,
          tabIndex: index,
          workspaceId: workspaceId,
          theme: theme,
          onTabReorder: onTabReorder,
          onLeftHover: () => onDropZoneActivate?.call(index),
          onRightHover: () => onDropZoneActivate?.call(index + 1),
          onHoverEnd: () => onDropZoneDeactivate?.call(),
        );
      }).toList(),
    );

    final stackContent = Stack(
      children: [
        // Regular tabs row
        tabsRow,
        // Fixed positioned drop zone indicators
        ..._buildDropZoneIndicators(workspaceTheme),
      ],
    );

    // If tabs fit within available width, no need for horizontal scrolling
    if (availableWidth != null && totalWidth <= availableWidth!) {
      final remainingWidth = availableWidth! - totalWidth;

      return SizedBox(
        width: containerWidth,
        child: Stack(
          children: [
            // Original tab content
            stackContent,
            // DragTarget container showing remaining width
            if (remainingWidth > 0)
              Positioned(
                right: 0,
                top: 0,
                child: DragTarget<DragData>(
                  onAcceptWithDetails: (details) {
                    // Move tab to last position
                    if (_canAcceptDrag(details.data)) {
                      final targetIndex = tabs.length; // Last position
                      onTabReorder?.call(
                        details.data.originalIndex,
                        targetIndex,
                      );
                    }

                    // Deactivate drop zone after drop
                    onDropZoneDeactivate?.call();
                  },
                  onWillAcceptWithDetails: (details) {
                    return _canAcceptDrag(details.data);
                  },
                  onMove: (details) {
                    // Activate last drop zone indicator when dragging over
                    onDropZoneActivate?.call(tabs.length);
                  },
                  onLeave: (details) {
                    // Deactivate drop zone when leaving
                    onDropZoneDeactivate?.call();
                  },
                  builder: (context, candidateData, rejectedData) {
                    return SizedBox(
                      width: remainingWidth,
                      height: workspaceTheme.tab.height,
                    );
                  },
                ),
              ),
          ],
        ),
      );
    }

    // Otherwise, use horizontal scrolling
    return SingleChildScrollView(
      controller: scrollController,
      scrollDirection: Axis.horizontal,
      child: SizedBox(width: totalWidth, child: stackContent),
    );
  }

  /// Builds positioned drop zone indicators
  List<Widget> _buildDropZoneIndicators(SplitWorkspaceTheme workspaceTheme) {
    final List<Widget> indicators = [];
    final currentDropZone = activeDropZoneIndex ?? -1;

    // 테마에서 tabWidth 사용
    final tabWidth = workspaceTheme.tab.width;

    // Drop zone before first tab (맨 앞)
    indicators.add(
      Positioned(
        left: 0,
        top: 0,
        child: DropZoneIndicator(
          index: 0,
          isActive: currentDropZone == 0,
          theme: workspaceTheme,
          onTabReorder: onTabReorder,
          onDropComplete: () => onDropZoneDeactivate?.call(),
          workspaceId: workspaceId,
        ),
      ),
    );

    // Drop zones after each tab
    for (int i = 0; i < tabs.length; i++) {
      indicators.add(
        Positioned(
          left: (i + 1) * tabWidth - 1,
          top: 0,
          child: DropZoneIndicator(
            index: i + 1,
            isActive: currentDropZone == i + 1,
            theme: workspaceTheme,
            onTabReorder: onTabReorder,
            onDropComplete: () => onDropZoneDeactivate?.call(),
            workspaceId: workspaceId,
          ),
        ),
      );
    }

    return indicators;
  }

  /// Checks if a dragged tab can be accepted
  bool _canAcceptDrag(DragData dragData) {
    // Accept if from same workspace and not trying to move to same position
    return dragData.sourceWorkspaceId == workspaceId;
  }
}
