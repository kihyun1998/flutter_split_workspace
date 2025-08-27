import 'package:flutter/material.dart';

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
    final totalWidth = tabCount * tabWidth + 2; // +2 for final drop zone indicator width

    return SingleChildScrollView(
      controller: widget.scrollController,
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: totalWidth,
        child: Stack(
          children: [
            // Regular tabs row
            Row(
              children: widget.tabs.asMap().entries.map((entry) {
                final index = entry.key;
                final tab = entry.value;

                return TabItemWidget(
                  tab: tab,
                  isActive: tab.id == widget.activeTabId,
                  onTap: () => widget.onTabTap?.call(tab.id),
                  onClose: tab.closeable
                      ? () => widget.onTabClose?.call(tab.id)
                      : null,
                  tabIndex: index,
                  workspaceId: widget.workspaceId,
                  theme: widget.theme,
                  onTabReorder: widget.onTabReorder,
                  onLeftHover: () => _activateDropZone(index),
                  onRightHover: () => _activateDropZone(index + 1),
                  onHoverEnd: () => _deactivateDropZone(),
                );
              }).toList(),
            ),

            // Fixed positioned drop zone indicators
            ..._buildDropZoneIndicators(workspaceTheme),
          ],
        ),
      ),
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
      final left = (i + 1) * tabWidth; // 각 탭 뒤

      indicators.add(
        Positioned(
          left: left,
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
}
