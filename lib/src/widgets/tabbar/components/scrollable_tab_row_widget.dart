import 'package:flutter/material.dart';

import '../../../models/drag_data.dart';
import '../../../models/tab_data.dart';
import '../../../theme/split_workspace_theme.dart';
import '../../tab_item/tab_item_widget.dart';
import 'drop_zone_indicator.dart';

/// A scrollable row widget that displays tab items horizontally
///
/// This widget creates a horizontally scrollable container with all tab items
/// arranged in a row, handling overflow when there are more tabs than can fit
/// in the available width.
class ScrollableTabRowWidget extends StatefulWidget {
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
  });

  @override
  State<ScrollableTabRowWidget> createState() => _ScrollableTabRowWidgetState();
}

class _ScrollableTabRowWidgetState extends State<ScrollableTabRowWidget> {
  /// Active drop zone index (-1 means none active)
  int _activeDropZone = -1;

  @override
  Widget build(BuildContext context) {
    final workspaceTheme = widget.theme ?? SplitWorkspaceTheme.defaultTheme;

    // Calculate required width for all tabs
    final tabWidth = workspaceTheme.tab.width;
    final tabCount = widget.tabs.length;

    // Stack width should only be based on actual tab content + last indicator
    final totalWidth = tabCount * tabWidth;

    // Use available width if provided and tabs fit within it, otherwise use calculated total width
    final containerWidth =
        widget.availableWidth != null && totalWidth <= widget.availableWidth!
        ? widget.availableWidth!
        : totalWidth;

    final tabsRow = Row(
      children: widget.tabs.asMap().entries.map((entry) {
        final index = entry.key;
        final tab = entry.value;

        return TabItemWidget(
          tab: tab,
          isActive: tab.id == widget.activeTabId,
          onTap: () => widget.onTabTap?.call(tab.id),
          onClose: tab.closeable ? () => widget.onTabClose?.call(tab.id) : null,
          tabIndex: index,
          workspaceId: widget.workspaceId,
          theme: widget.theme,
          onTabReorder: widget.onTabReorder,
          onLeftHover: () => _activateDropZone(index),
          onRightHover: () => _activateDropZone(index + 1),
          onHoverEnd: () => _deactivateDropZone(),
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
    if (widget.availableWidth != null && totalWidth <= widget.availableWidth!) {
      final remainingWidth = widget.availableWidth! - totalWidth;

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
                      final targetIndex = widget.tabs.length; // Last position
                      widget.onTabReorder?.call(
                        details.data.originalIndex,
                        targetIndex,
                      );
                    }

                    // Deactivate drop zone after drop
                    _deactivateDropZone();
                  },
                  onWillAcceptWithDetails: (details) {
                    return _canAcceptDrag(details.data);
                  },
                  onMove: (details) {
                    // Activate last drop zone indicator when dragging over
                    _activateDropZone(widget.tabs.length);
                  },
                  onLeave: (details) {
                    // Deactivate drop zone when leaving
                    _deactivateDropZone();
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
      controller: widget.scrollController,
      scrollDirection: Axis.horizontal,
      child: SizedBox(width: totalWidth, child: stackContent),
    );
  }

  /// Builds positioned drop zone indicators
  List<Widget> _buildDropZoneIndicators(SplitWorkspaceTheme workspaceTheme) {
    final List<Widget> indicators = [];

    // 테마에서 tabWidth 사용
    final tabWidth = workspaceTheme.tab.width;

    // Drop zone before first tab (맨 앞)
    indicators.add(
      Positioned(
        left: 0,
        top: 0,
        child: DropZoneIndicator(
          index: 0,
          isActive: _activeDropZone == 0,
          theme: workspaceTheme,
          onTabReorder: widget.onTabReorder,
          onDropComplete: () => _deactivateDropZone(),
          workspaceId: widget.workspaceId,
        ),
      ),
    );

    // Drop zones after each tab
    for (int i = 0; i < widget.tabs.length; i++) {
      indicators.add(
        Positioned(
          left: (i + 1) * tabWidth - 1,
          top: 0,
          child: DropZoneIndicator(
            index: i + 1,
            isActive: _activeDropZone == i + 1,
            theme: workspaceTheme,
            onTabReorder: widget.onTabReorder,
            onDropComplete: () => _deactivateDropZone(),
            workspaceId: widget.workspaceId,
          ),
        ),
      );
    }

    return indicators;
  }

  /// Activates a drop zone at the given index
  void _activateDropZone(int index) {
    if (_activeDropZone != index) {
      setState(() {
        _activeDropZone = index;
      });
    }
  }

  /// Deactivates all drop zones
  void _deactivateDropZone() {
    if (_activeDropZone != -1) {
      setState(() {
        _activeDropZone = -1;
      });
    }
  }

  /// Checks if a dragged tab can be accepted
  bool _canAcceptDrag(DragData dragData) {
    // Accept if from same workspace and not trying to move to same position
    return dragData.sourceWorkspaceId == widget.workspaceId;
  }
}
