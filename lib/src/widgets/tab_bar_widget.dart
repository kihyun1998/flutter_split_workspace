// lib/src/widgets/tab_bar_widget.dart (스크롤바 색상 수정)
import 'package:flutter/material.dart';

import '../models/drag_data.dart';
import '../models/tab_data.dart';
import '../theme/split_workspace_tab_theme.dart';
import '../theme/split_workspace_theme.dart';
import 'tab_item_widget.dart';

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
                        ? _buildThemedScrollbar(workspaceTheme)
                        : _buildScrollableTabRow(workspaceTheme),
                  ),

                  // Add tab button (always visible)
                  if (widget.onAddTab != null)
                    _buildAddTabButton(workspaceTheme),
                ],
              ),

              // Drag indicator
              if (_isDragging && _dragOverIndex != null)
                _buildDragIndicator(workspaceTheme),
            ],
          );
        },
      ),
    );
  }

  /// Builds a scrollbar with proper theme integration and color scheme fallbacks.
  ///
  /// Creates a themed scrollbar that uses colors from the workspace's color scheme
  /// when specific scrollbar colors aren't provided, ensuring visual consistency.
  Widget _buildThemedScrollbar(SplitWorkspaceTheme workspaceTheme) {
    final colorScheme = workspaceTheme.colorScheme;
    final scrollbarTheme = workspaceTheme.scrollbar;

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
      thumbVisibility: WidgetStateProperty.all(scrollbarTheme.alwaysVisible),
    );

    return ScrollbarTheme(
      data: scrollbarThemeData,
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: scrollbarTheme.alwaysVisible,
        trackVisibility: scrollbarTheme.trackVisible,
        child: _buildScrollableTabRow(workspaceTheme),
      ),
    );
  }

  /// Builds the scrollable row of tab items.
  ///
  /// Creates a horizontally scrollable container with all tab items
  /// arranged in a row, handling overflow when there are more tabs
  /// than can fit in the available width.
  Widget _buildScrollableTabRow(SplitWorkspaceTheme workspaceTheme) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Row(
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
          );
        }).toList(),
      ),
    );
  }

  /// Builds the add new tab button with theme-integrated colors.
  ///
  /// Creates a button that allows users to add new tabs, positioned at the
  /// end of the tab bar with styling that matches the current theme.
  Widget _buildAddTabButton(SplitWorkspaceTheme workspaceTheme) {
    final colorScheme = workspaceTheme.colorScheme;
    final tabTheme = workspaceTheme.tab;

    return Container(
      width: 36,
      height: tabTheme.height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border(
          left: BorderSide(color: colorScheme.dividerColor, width: 1),
        ),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(workspaceTheme.borderRadius),
          bottomRight: Radius.circular(workspaceTheme.borderRadius),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onAddTab,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(workspaceTheme.borderRadius),
            bottomRight: Radius.circular(workspaceTheme.borderRadius),
          ),
          child: Icon(Icons.add, size: 16, color: colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }

  /// Builds the visual indicator shown during drag operations.
  ///
  /// Displays a colored line that indicates where a dragged tab would be
  /// inserted if dropped at the current position. Uses the theme's primary
  /// color for visibility and consistency.
  Widget _buildDragIndicator(SplitWorkspaceTheme theme) {
    if (_dragOverIndex == null) return const SizedBox.shrink();

    final colorScheme = theme.colorScheme;
    final tabWidth = _calculateTabWidth();
    final indicatorX = _dragOverIndex! * tabWidth;

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
