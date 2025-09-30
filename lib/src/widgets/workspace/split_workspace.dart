import 'package:flutter/material.dart';

import '../../enums/drop_zone_type.dart';
import '../../enums/split_direction.dart';
import '../../models/split_panel.dart';
import '../../theme/split_workspace_theme.dart';
import '../drag_config.dart';
import '../splitter/splitter_widget.dart';
import 'tab_workspace.dart';

/// Main workspace widget that displays split panels recursively.
///
/// This widget takes a [SplitPanel] tree and renders it:
/// - Leaf nodes (groups) are rendered as [TabWorkspace]
/// - Branch nodes (splits) are rendered as split containers with [SplitterWidget]
///
/// Supports nested splits up to the maximum depth defined in [SplitService].
///
/// Example:
/// ```dart
/// SplitWorkspace(
///   workspace: myWorkspace,
///   onTabTap: (tabId) => handleTabTap(tabId),
///   onTabClose: (tabId) => handleTabClose(tabId),
///   onTabReorder: (oldIndex, newIndex) => handleReorder(oldIndex, newIndex),
///   onTabMoveToGroup: (tabId, groupId, index) => handleMove(tabId, groupId, index),
/// )
/// ```
class SplitWorkspace extends StatelessWidget {
  /// The workspace tree to render
  final SplitPanel workspace;

  /// Callback when a tab is selected
  final Function(String tabId)? onTabTap;

  /// Callback when a tab is closed
  final Function(String tabId)? onTabClose;

  /// Callback when add tab button is pressed
  final Function(String groupId)? onAddTab;

  /// Callback when tabs are reordered within the same group
  final Function(String groupId, int oldIndex, int newIndex)? onTabReorder;

  /// Callback when a tab is moved to a different group
  final Function(String tabId, String targetGroupId, int insertIndex)?
      onTabMoveToGroup;

  /// Callback when a tab is dropped to create a split
  final Function(String sourceTabId, String targetGroupId, DropZoneType dropZone)?
      onSplitRequest;

  /// Callback when split ratio is changed (Phase 7)
  final Function(String splitId, double newRatio)? onRatioChanged;

  /// Unique workspace identifier for drag and drop
  final String? workspaceId;

  /// Theme configuration for styling
  final SplitWorkspaceTheme? theme;

  const SplitWorkspace({
    super.key,
    required this.workspace,
    this.onTabTap,
    this.onTabClose,
    this.onAddTab,
    this.onTabReorder,
    this.onTabMoveToGroup,
    this.onSplitRequest,
    this.onRatioChanged,
    this.workspaceId,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final workspaceTheme = theme ?? SplitWorkspaceTheme.defaultTheme;
    final effectiveWorkspaceId = workspaceId ?? 'default';

    return DragConfigProvider(
      child: Container(
        decoration: BoxDecoration(
          color: workspaceTheme.effectiveBackgroundColor,
          borderRadius: BorderRadius.circular(workspaceTheme.borderRadius),
          border: workspaceTheme.borderWidth > 0
              ? Border.all(
                  color: workspaceTheme.effectiveBorderColor,
                  width: workspaceTheme.borderWidth,
                )
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(workspaceTheme.borderRadius),
          child: _buildPanel(
            workspace,
            effectiveWorkspaceId,
            workspaceTheme,
          ),
        ),
      ),
    );
  }

  /// Recursively builds a panel (leaf or branch)
  Widget _buildPanel(
    SplitPanel panel,
    String workspaceId,
    SplitWorkspaceTheme workspaceTheme,
  ) {
    // Leaf node: render as TabWorkspace
    if (panel.isLeaf) {
      return TabWorkspace(
        tabs: panel.tabs ?? [],
        activeTabId: panel.activeTabId,
        onTabTap: onTabTap,
        onTabClose: onTabClose,
        onAddTab: onAddTab != null ? () => onAddTab!(panel.id) : null,
        onTabReorder: onTabReorder != null
            ? (groupId, oldIndex, newIndex) => onTabReorder!(groupId, oldIndex, newIndex)
            : null,
        onTabMoveToGroup: onTabMoveToGroup,
        onSplitRequest: onSplitRequest != null
            ? (sourceTabId, dropZone) => onSplitRequest!(sourceTabId, panel.id, dropZone)
            : null,
        workspaceId: workspaceId,
        groupId: panel.id,
        theme: workspaceTheme,
      );
    }

    // Branch node: render as split container
    if (panel.isSplit && panel.children != null && panel.children!.length == 2) {
      final direction = panel.direction ?? SplitDirection.horizontal;
      final ratio = panel.ratio.clamp(0.1, 0.9);

      final firstChild = _buildPanel(
        panel.children![0],
        workspaceId,
        workspaceTheme,
      );

      final secondChild = _buildPanel(
        panel.children![1],
        workspaceId,
        workspaceTheme,
      );

      final splitter = SplitterWidget(
        direction: direction,
        ratio: ratio,
        theme: workspaceTheme,
        onRatioChanged: onRatioChanged != null
            ? (newRatio) => onRatioChanged!(panel.id, newRatio)
            : null,
      );

      // Horizontal split: stacked vertically
      if (direction == SplitDirection.horizontal) {
        return Column(
          children: [
            Expanded(
              flex: (ratio * 1000).toInt(),
              child: firstChild,
            ),
            splitter,
            Expanded(
              flex: ((1 - ratio) * 1000).toInt(),
              child: secondChild,
            ),
          ],
        );
      }
      // Vertical split: side by side
      else {
        return Row(
          children: [
            Expanded(
              flex: (ratio * 1000).toInt(),
              child: firstChild,
            ),
            splitter,
            Expanded(
              flex: ((1 - ratio) * 1000).toInt(),
              child: secondChild,
            ),
          ],
        );
      }
    }

    // Invalid state: show error
    return Container(
      color: Colors.red.withOpacity(0.1),
      child: Center(
        child: Text(
          'Invalid panel structure',
          style: TextStyle(color: Colors.red[900]),
        ),
      ),
    );
  }
}