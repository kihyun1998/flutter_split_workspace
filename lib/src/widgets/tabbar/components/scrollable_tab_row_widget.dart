import 'package:flutter/material.dart';

import '../../../models/tab_data.dart';
import '../../../theme/split_workspace_theme.dart';
import '../../tab_item/tab_item_widget.dart';

/// A scrollable row widget that displays tab items horizontally
///
/// This widget creates a horizontally scrollable container with all tab items
/// arranged in a row, handling overflow when there are more tabs than can fit
/// in the available width.
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

  const ScrollableTabRowWidget({
    super.key,
    required this.tabs,
    this.activeTabId,
    this.onTabTap,
    this.onTabClose,
    required this.workspaceId,
    this.theme,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      scrollDirection: Axis.horizontal,
      child: Row(
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
          );
        }).toList(),
      ),
    );
  }
}
