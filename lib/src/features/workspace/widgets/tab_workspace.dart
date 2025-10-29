// lib/src/widgets/tab_workspace.dart (수정)
import 'package:flutter/material.dart';
import 'package:flutter_split_workspace/src/theme/split_workspace_color_scheme_theme.dart';

import '../../../theme/split_workspace_theme.dart';
import '../../tab/models/tab_data.dart';
import '../../tabbar/widgets/tab_bar_widget.dart';

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

  /// Callback when tabs are reordered
  final Function(int oldIndex, int newIndex)? onTabReorder;

  /// Unique workspace identifier
  final String? workspaceId;

  /// Theme configuration for styling the entire workspace.
  ///
  /// When null, uses [SplitWorkspaceTheme.defaultTheme]. The theme
  /// controls colors, dimensions, and behavior for all workspace components.
  final SplitWorkspaceTheme? theme;

  /// Active drop zone index (externally controlled, -1 means none active)
  final int? activeDropZoneIndex;

  /// Callback when a drop zone should be activated
  final Function(int index)? onDropZoneActivate;

  /// Callback when drop zones should be deactivated
  final VoidCallback? onDropZoneDeactivate;

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
    this.workspaceId,
    this.theme,
    this.activeDropZoneIndex,
    this.onDropZoneActivate,
    this.onDropZoneDeactivate,
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

  @override
  Widget build(BuildContext context) {
    final workspaceTheme = theme ?? SplitWorkspaceTheme.defaultTheme;
    final colorScheme = workspaceTheme.colorScheme;
    final effectiveWorkspaceId = workspaceId ?? 'default';

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
            onTabReorder: onTabReorder,
            workspaceId: effectiveWorkspaceId,
            theme: workspaceTheme,
            activeDropZoneIndex: activeDropZoneIndex,
            onDropZoneActivate: onDropZoneActivate,
            onDropZoneDeactivate: onDropZoneDeactivate,
          ),

          // Content area
          Expanded(child: _buildContentArea(workspaceTheme, colorScheme)),
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
}
