// lib/src/widgets/tab_bar_widget.dart (스크롤바 색상 수정)
import 'package:flutter/material.dart';

import '../models/drag_data.dart';
import '../models/tab_data.dart';
import '../theme/split_workspace_tab_theme.dart';
import '../theme/split_workspace_theme.dart';
import 'add_tab_button_widget.dart';
import 'drag_indicator_widget.dart';
import 'scrollable_tab_row_widget.dart';
import 'tab_item_widget.dart';
import 'themed_scrollbar_widget.dart';

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
  /// Index where a dragged tab would be inserted
  int? _dragOverIndex;

  /// Whether a drag operation is currently in progress
  bool _isDragging = false;

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
    final colorScheme = workspaceTheme.colorScheme;
    final tabTheme = workspaceTheme.tab;
    final scrollbarTheme = workspaceTheme.scrollbar;

    return Container(
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
      child: DragTarget<DragData>(
        onWillAcceptWithDetails: (details) {
          setState(() {
            _isDragging = true;
          });
          return true;
        },
        onLeave: (data) {
          setState(() {
            _isDragging = false;
            _dragOverIndex = null;
          });
        },
        onMove: (details) {
          _updateDragOverIndex(details.offset);
        },
        onAcceptWithDetails: (details) {
          _handleDrop(details.data);
          setState(() {
            _isDragging = false;
            _dragOverIndex = null;
          });
        },
        builder: (context, candidateData, rejectedData) {
          return Stack(
            children: [
              // Main tab bar layout
              Row(
                children: [
                  // Scrollable tab area
                  Expanded(
                    child: scrollbarTheme.visible
                        ? ThemedScrollbarWidget(
                            theme: workspaceTheme,
                            scrollController: _scrollController,
                            child: ScrollableTabRowWidget(
                              tabs: widget.tabs,
                              activeTabId: widget.activeTabId,
                              onTabTap: widget.onTabTap,
                              onTabClose: widget.onTabClose,
                              workspaceId: widget.workspaceId,
                              theme: widget.theme,
                              scrollController: _scrollController,
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

              // Drag indicator
              if (_isDragging && _dragOverIndex != null)
                DragIndicatorWidget(
                  theme: workspaceTheme,
                  dragOverIndex: _dragOverIndex,
                  tabWidth: _calculateTabWidth(),
                ),
            ],
          );
        },
      ),
    );
  }


  /// Updates the drag over index based on the current mouse position.
  ///
  /// Calculates which tab position the mouse is currently over during
  /// a drag operation, updating the visual indicator accordingly.
  void _updateDragOverIndex(Offset offset) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    int newIndex = 0;
    double accumulatedWidth = 0;

    // Calculate the closest index based on actual tab positions
    for (int i = 0; i < widget.tabs.length; i++) {
      final tabWidth = _calculateTabWidth();
      final tabCenter = accumulatedWidth + (tabWidth / 2);

      if (offset.dx < tabCenter) {
        newIndex = i;
        break;
      }

      accumulatedWidth += tabWidth;
      newIndex = i + 1; // After last tab
    }

    // Clamp to valid range
    newIndex = newIndex.clamp(0, widget.tabs.length);

    if (newIndex != _dragOverIndex) {
      setState(() {
        _dragOverIndex = newIndex;
      });
    }
  }

  /// Calculates the optimal width for individual tabs.
  ///
  /// Determines tab width based on available space, tab count, and
  /// theme constraints (minimum and maximum width limits).
  double _calculateTabWidth() {
    final tabTheme = widget.theme?.tab ?? const SplitWorkspaceTabTheme();
    final availableWidth = MediaQuery.of(context).size.width - 36 - 50;
    final tabCount = widget.tabs.length;

    if (tabCount == 0) return 120.0;

    final calculatedWidth = availableWidth / tabCount;
    return calculatedWidth.clamp(
      tabTheme.minWidth ?? 120.0,
      tabTheme.maxWidth ?? 200.0,
    );
  }

  /// Handles the completion of drag and drop operations.
  ///
  /// Processes the dropped tab data to determine if reordering should occur,
  /// and triggers the appropriate callback with the old and new indices.
  void _handleDrop(DragData dragData) {
    // Handle reordering within the same workspace
    if (dragData.sourceWorkspaceId == widget.workspaceId &&
        _dragOverIndex != null) {
      final oldIndex = dragData.originalIndex;
      final newIndex = _dragOverIndex!;

      // Only trigger callback if position actually changed
      if (oldIndex != newIndex) {
        widget.onTabReorder?.call(oldIndex, newIndex);
      }
    }

    // TODO: Handle cross-workspace drops in future versions
  }
}
