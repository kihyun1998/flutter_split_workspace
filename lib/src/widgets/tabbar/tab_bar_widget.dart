// lib/src/widgets/tab_bar_widget.dart (스크롤바 색상 수정)
import 'package:flutter/material.dart';

import '../../models/tab_data.dart';
import '../../theme/split_workspace_theme.dart';
import 'components/add_tab_button_widget.dart';
import 'components/scrollable_tab_row_widget.dart';
import 'components/themed_scrollbar_widget.dart';

/// Tab bar widget that displays multiple tabs with drag and drop support
///
/// This widget handles:
/// - Horizontal scrolling of tabs
/// - Drag and drop reordering
/// - Drop zone indicators
/// - Add new tab functionality
/// - Theme integration with colorScheme
class TabBarWidget extends StatefulWidget {
  /// List of tabs to display
  final List<TabData> tabs;

  /// Currently active tab ID
  final String? activeTabId;

  /// Callback when a tab is tapped
  final Function(String tabId)? onTabTap;

  /// Callback when a tab's close button is tapped
  final Function(String tabId)? onTabClose;

  /// Callback when the add tab button is tapped
  final VoidCallback? onAddTab;

  /// Callback when tabs are reordered via drag and drop
  final Function(int oldIndex, int newIndex)? onTabReorder;

  /// Workspace identifier for drag and drop operations
  final String workspaceId;

  /// Theme configuration for styling
  final SplitWorkspaceTheme? theme;

  const TabBarWidget({
    super.key,
    required this.tabs,
    this.activeTabId,
    this.onTabTap,
    this.onTabClose,
    this.onAddTab,
    this.onTabReorder,
    required this.workspaceId,
    this.theme,
  });

  @override
  State<TabBarWidget> createState() => _TabBarWidgetState();
}

class _TabBarWidgetState extends State<TabBarWidget> {
  /// Whether the tab bar is currently being hovered
  bool _isHovered = false;

  /// Controller for horizontal scrolling of tabs
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workspaceTheme = widget.theme ?? SplitWorkspaceTheme.defaultTheme;
    final tabTheme = workspaceTheme.tab;
    final scrollbarTheme = workspaceTheme.scrollbar;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        height: tabTheme.height,
        decoration: BoxDecoration(
          color: workspaceTheme.effectiveBackgroundColor,
          border: Border(
            bottom: BorderSide(
              color: workspaceTheme.effectiveBorderColor,
              width: workspaceTheme.borderWidth,
            ),
          ),
        ),
        child: Row(
          children: [
            // Scrollable tab area
            Expanded(
              child: scrollbarTheme.visible
                  ? ThemedScrollbarWidget(
                      theme: workspaceTheme,
                      scrollController: _scrollController,
                      showScrollbar: _isHovered,
                      child: ScrollableTabRowWidget(
                        tabs: widget.tabs,
                        activeTabId: widget.activeTabId,
                        onTabTap: widget.onTabTap,
                        onTabClose: widget.onTabClose,
                        workspaceId: widget.workspaceId,
                        theme: widget.theme,
                        scrollController: _scrollController,
                        onTabReorder: widget.onTabReorder,
                      ),
                    )
                  : ScrollableTabRowWidget(
                      tabs: widget.tabs,
                      activeTabId: widget.activeTabId,
                      onTabTap: widget.onTabTap,
                      onTabClose: widget.onTabClose,
                      workspaceId: widget.workspaceId,
                      theme: widget.theme,
                      scrollController: _scrollController,
                      onTabReorder: widget.onTabReorder,
                    ),
            ),

            // Add tab button (always visible)
            if (widget.onAddTab != null)
              AddTabButtonWidget(
                theme: workspaceTheme,
                onAddTab: widget.onAddTab,
              ),
          ],
        ),
      ),
    );
  }
}
