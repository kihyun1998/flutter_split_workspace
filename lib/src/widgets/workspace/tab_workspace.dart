// lib/src/widgets/tab_workspace.dart (수정)
import 'package:flutter/material.dart';
import 'package:flutter_split_workspace/src/theme/split_workspace_color_scheme_theme.dart';

import '../../enums/drop_zone_type.dart';
import '../../models/drag_data.dart';
import '../../models/tab_data.dart';
import '../../theme/split_workspace_theme.dart';
import '../../utils/drop_zone_calculator.dart';
import '../drag_config.dart';
import '../drop_target_content.dart';
import '../split_preview_overlay.dart';
import '../tabbar/tab_bar_widget.dart';

/// Main workspace widget that combines tab bar and content area
///
/// This widget provides a complete tab management interface including:
/// - Tab bar with drag and drop functionality
/// - Content area displaying the active tab's content
/// - Consistent theming with colorScheme integration
/// - Fallback UI when no tabs are active
class TabWorkspace extends StatelessWidget {
  /// List of tabs to display
  final List<TabData> tabs;

  /// Currently active tab ID
  final String? activeTabId;

  /// Callback when a tab is selected
  final Function(String tabId)? onTabTap;

  /// Callback when a tab is closed
  final Function(String tabId)? onTabClose;

  /// Callback when add tab button is pressed
  final VoidCallback? onAddTab;

  /// Callback when tabs are reordered (within same group)
  final Function(String groupId, int oldIndex, int newIndex)? onTabReorder;

  /// Callback when a tab is moved to a different group
  final Function(String tabId, String targetGroupId, int insertIndex)?
  onTabMoveToGroup;

  /// Callback when a tab is dropped to create a split
  final Function(String sourceTabId, DropZoneType dropZone)? onSplitRequest;

  /// Unique workspace identifier
  final String? workspaceId;

  /// Group identifier for this tab group
  final String? groupId;

  /// Theme configuration for styling the entire workspace.
  ///
  /// When null, uses [SplitWorkspaceTheme.defaultTheme]. The theme
  /// controls colors, dimensions, and behavior for all workspace components.
  final SplitWorkspaceTheme? theme;

  /// Creates a tab workspace with the specified configuration.
  ///
  /// The [tabs] parameter is required and contains the list of tabs to display.
  /// All other parameters are optional and provide callbacks for user interactions
  /// and customization options.
  ///
  /// Example:
  /// ```dart
  /// TabWorkspace(
  ///   tabs: myTabs,
  ///   activeTabId: 'tab_1',
  ///   onTabTap: (tabId) => setState(() => activeTab = tabId),
  ///   onTabReorder: (oldIndex, newIndex) => reorderTabs(oldIndex, newIndex),
  ///   theme: SplitWorkspaceTheme.dark,
  /// )
  /// ```
  const TabWorkspace({
    super.key,
    required this.tabs,
    this.activeTabId,
    this.onTabTap,
    this.onTabClose,
    this.onAddTab,
    this.onTabReorder,
    this.onTabMoveToGroup,
    this.onSplitRequest,
    this.workspaceId,
    this.groupId,
    this.theme,
  });

  /// Returns the currently active tab data, if any.
  ///
  /// Searches for a tab with an ID matching [activeTabId] and returns it.
  /// Returns null if no active tab ID is set or if no matching tab is found.
  TabData? get activeTab {
    if (activeTabId == null) return null;
    try {
      return tabs.firstWhere((tab) => tab.id == activeTabId);
    } catch (e) {
      return null;
    }
  }

  /// Handles tab drop on content area.
  ///
  /// If drop zone is center (moveToGroup), moves the tab to this group.
  /// Otherwise, creates a split via onSplitRequest callback.
  void _handleDrop(
    DragData dragData,
    DropZoneType dropZone,
    String targetGroupId,
  ) {
    // If same group, ignore
    if (dragData.sourceGroupId == targetGroupId) {
      return;
    }

    // Center zone: move tab to this group
    if (dropZone == DropZoneType.moveToGroup) {
      onTabMoveToGroup?.call(
        dragData.tab.id,
        targetGroupId,
        tabs.length, // Insert at end
      );
    }
    // Edge zones: create split
    else {
      onSplitRequest?.call(dragData.tab.id, dropZone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final workspaceTheme = theme ?? SplitWorkspaceTheme.defaultTheme;
    final colorScheme = workspaceTheme.colorScheme;
    final effectiveWorkspaceId = workspaceId ?? 'default';
    final effectiveGroupId = groupId ?? effectiveWorkspaceId;

    return Container(
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
      child: Column(
        children: [
          // Tab bar
          TabBarWidget(
            tabs: tabs,
            activeTabId: activeTabId,
            onTabTap: onTabTap,
            onTabClose: onTabClose,
            onAddTab: onAddTab,
            onTabReorder: onTabReorder != null
                ? (oldIndex, newIndex) =>
                      onTabReorder!(effectiveGroupId, oldIndex, newIndex)
                : null,
            onTabMoveToGroup: onTabMoveToGroup,
            workspaceId: effectiveWorkspaceId,
            groupId: effectiveGroupId,
            theme: workspaceTheme,
          ),

          // Content area with drop target and preview overlay
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final dragState = context.dragState;
                final isDragging = dragState?.isDragging ?? false;
                final showPreview =
                    isDragging &&
                    dragState?.targetGroupId == effectiveGroupId &&
                    dragState?.currentDropZone != null;

                return Stack(
                  children: [
                    // Main content with drop target
                    DropTargetContent(
                      groupId: effectiveGroupId,
                      onDrop: (dragData, dropZone) =>
                          _handleDrop(dragData, dropZone, effectiveGroupId),
                      child: _buildContentArea(workspaceTheme, colorScheme),
                    ),

                    // DEBUG: Show drop zones
                    _buildDebugDropZones(
                      Size(constraints.maxWidth, constraints.maxHeight),
                      colorScheme,
                    ),

                    // Preview overlay (shown during drag) with smooth transitions
                    RepaintBoundary(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 150),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: showPreview
                            ? SplitPreviewOverlay(
                                dropZone: dragState?.currentDropZone,
                                size: Size(
                                  constraints.maxWidth,
                                  constraints.maxHeight,
                                ),
                                theme: workspaceTheme,
                              )
                            : SizedBox.shrink(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the main content area using colorScheme
  Widget _buildContentArea(
    SplitWorkspaceTheme workspaceTheme,
    SplitWorkspaceColorSchemeTheme colorScheme,
  ) {
    // Show active tab content if available
    if (activeTab?.content != null) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: workspaceTheme.borderRadius > 0
              ? BorderRadius.only(
                  bottomLeft: Radius.circular(workspaceTheme.borderRadius),
                  bottomRight: Radius.circular(workspaceTheme.borderRadius),
                )
              : null,
        ),
        child: activeTab!.content!,
      );
    }

    // Show fallback UI when no active tab
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: workspaceTheme.borderRadius > 0
            ? BorderRadius.only(
                bottomLeft: Radius.circular(workspaceTheme.borderRadius),
                bottomRight: Radius.circular(workspaceTheme.borderRadius),
              )
            : null,
      ),
      child: _buildEmptyState(workspaceTheme, colorScheme),
    );
  }

  /// Builds the empty state UI using colorScheme
  Widget _buildEmptyState(
    SplitWorkspaceTheme workspaceTheme,
    SplitWorkspaceColorSchemeTheme colorScheme,
  ) {
    final tabTheme = workspaceTheme.tab;
    final hasAddTabButton = onAddTab != null;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Empty state icon
          Icon(
            tabs.isEmpty ? Icons.tab : Icons.description_outlined,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),

          const SizedBox(height: 16),

          // Primary message
          Text(
            tabs.isEmpty ? 'No tabs available' : 'No active tab',
            style: (tabTheme.textStyle ?? const TextStyle(fontSize: 16))
                .copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
          ),

          const SizedBox(height: 8),

          // Secondary message
          Text(
            tabs.isEmpty
                ? hasAddTabButton
                      ? 'Click the + button to add your first tab'
                      : 'Add tabs to get started'
                : 'Select a tab to view its content',
            style: (tabTheme.textStyle ?? const TextStyle(fontSize: 14))
                .copyWith(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),

          // Optional action button for empty workspace
          if (tabs.isEmpty && hasAddTabButton) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAddTab,
              icon: Icon(
                Icons.add,
                size: 18,
                color: colorScheme.onPrimaryContainer,
              ),
              label: Text(
                'Add First Tab',
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],

          // Debug info (only in debug mode)
          if (tabs.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'Debug Info',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total tabs: ${tabs.length}',
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Active tab ID: ${activeTabId ?? 'none'}',
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// DEBUG: Builds visual overlay showing drop zones
  Widget _buildDebugDropZones(
    Size size,
    SplitWorkspaceColorSchemeTheme colorScheme,
  ) {
    return IgnorePointer(
      child: Stack(
        children: [
          // Left zone
          _buildDebugZone(
            DropZoneCalculator.getDropZoneRect(DropZoneType.splitLeft, size),
            Colors.red.withOpacity(0.2),
            'LEFT\n33%',
          ),
          // Right zone
          _buildDebugZone(
            DropZoneCalculator.getDropZoneRect(DropZoneType.splitRight, size),
            Colors.blue.withOpacity(0.2),
            'RIGHT\n33%',
          ),
          // Top zone
          _buildDebugZone(
            DropZoneCalculator.getDropZoneRect(DropZoneType.splitTop, size),
            Colors.green.withOpacity(0.2),
            'TOP\n34%w×33%h',
          ),
          // Bottom zone
          _buildDebugZone(
            DropZoneCalculator.getDropZoneRect(DropZoneType.splitBottom, size),
            Colors.orange.withOpacity(0.2),
            'BOTTOM\n34%w×33%h',
          ),
          // Center zone
          _buildDebugZone(
            DropZoneCalculator.getDropZoneRect(DropZoneType.moveToGroup, size),
            Colors.purple.withOpacity(0.2),
            'CENTER\n34%×34%',
          ),
        ],
      ),
    );
  }

  Widget _buildDebugZone(Rect rect, Color color, String label) {
    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: color.withOpacity(0.8), width: 2),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              shadows: [
                Shadow(
                  color: Colors.black,
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
