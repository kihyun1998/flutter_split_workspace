import '../models/split_panel.dart';
import '../models/tab_data.dart';
import 'workspace_helpers.dart';

/// Result of a tab removal operation that may leave an empty group.
class RemoveTabResult {
  /// The new workspace state after removal
  final SplitPanel newState;

  /// ID of the group that became empty (null if no group is empty)
  final String? emptyGroupId;

  /// Whether the root itself became empty
  final bool rootBecameEmpty;

  const RemoveTabResult({
    required this.newState,
    this.emptyGroupId,
    this.rootBecameEmpty = false,
  });
}

/// Service providing tab manipulation operations.
///
/// All methods are pure functions that take the current state and
/// return a new state, without side effects.
///
/// Example usage:
/// ```dart
/// // Add a tab
/// final newState = TabService.addTab(
///   workspace,
///   title: 'New Tab',
///   content: MyWidget(),
/// );
///
/// // Remove a tab
/// final result = TabService.removeTabWithEmptyCheck(workspace, 'tab-5');
/// setState(() {
///   workspace = result.newState;
///   if (result.emptyGroupId != null) {
///     // Handle empty group cleanup
///   }
/// });
/// ```
class TabService {
  TabService._(); // Private constructor - utility class

  static int _nextTabId = 1;

  /// Creates a new tab with auto-generated ID.
  ///
  /// If [title] is not provided, generates "Tab N".
  /// The [content] widget is optional.
  ///
  /// Example:
  /// ```dart
  /// final tab = TabService.createTab(
  ///   title: 'My Tab',
  ///   content: Container(child: Text('Content')),
  /// );
  /// ```
  static TabData createTab({String? title, dynamic content}) {
    final id = _nextTabId.toString();
    _nextTabId++;

    return TabData(
      id: id,
      title: title ?? 'Tab $id',
      content: content,
      closeable: true,
    );
  }

  /// Creates a welcome tab (useful for initial state).
  ///
  /// Example:
  /// ```dart
  /// final workspace = SplitPanel.singleGroup(
  ///   id: 'root',
  ///   tabs: [TabService.createWelcomeTab()],
  ///   activeTabId: '1',
  /// );
  /// ```
  static TabData createWelcomeTab() {
    return TabData(
      id: '1',
      title: 'Welcome',
      content: null,
      closeable: true,
    );
  }

  /// Adds a tab to the active group in the workspace.
  ///
  /// If the workspace is a single group, adds to that group.
  /// If the workspace is split, adds to the first leaf node found.
  ///
  /// Returns the modified workspace tree.
  ///
  /// Example:
  /// ```dart
  /// final updated = TabService.addTab(
  ///   workspace,
  ///   title: 'New Tab',
  ///   makeActive: true,
  /// );
  /// ```
  static SplitPanel addTab(
    SplitPanel state, {
    String? title,
    dynamic content,
    bool makeActive = true,
  }) {
    final tab = createTab(title: title, content: content);

    // If root is a leaf, add directly
    if (state.isLeaf) {
      return state.addTab(tab, makeActive: makeActive);
    }

    // Otherwise, find first group and add there
    final firstGroup = _findFirstGroup(state);
    if (firstGroup == null) return state;

    final updatedGroup = firstGroup.addTab(tab, makeActive: makeActive);
    return WorkspaceHelpers.replacePanel(state, firstGroup.id, updatedGroup);
  }

  /// Adds a tab to a specific group.
  ///
  /// Returns the modified workspace tree.
  ///
  /// Example:
  /// ```dart
  /// final updated = TabService.addTabToGroup(
  ///   workspace,
  ///   'group-2',
  ///   title: 'New Tab',
  /// );
  /// ```
  static SplitPanel addTabToGroup(
    SplitPanel state,
    String groupId, {
    String? title,
    dynamic content,
    bool makeActive = true,
  }) {
    final tab = createTab(title: title, content: content);
    final group = WorkspaceHelpers.findGroupById(state, groupId);

    if (group == null) return state;

    final updatedGroup = group.addTab(tab, makeActive: makeActive);
    return WorkspaceHelpers.replacePanel(state, groupId, updatedGroup);
  }

  /// Removes a tab by ID from the workspace.
  ///
  /// Returns a [RemoveTabResult] containing:
  /// - The new state
  /// - The ID of any group that became empty
  /// - Whether the root became empty
  ///
  /// Example:
  /// ```dart
  /// final result = TabService.removeTabWithEmptyCheck(workspace, 'tab-5');
  /// if (result.emptyGroupId != null) {
  ///   // Need to clean up empty group
  ///   final cleaned = SplitService.removeEmptyGroup(
  ///     result.newState,
  ///     result.emptyGroupId!,
  ///   );
  ///   setState(() => workspace = cleaned);
  /// } else {
  ///   setState(() => workspace = result.newState);
  /// }
  /// ```
  static RemoveTabResult removeTabWithEmptyCheck(
    SplitPanel state,
    String tabId,
  ) {
    // Find the group containing the tab
    final group = WorkspaceHelpers.findGroupByTabId(state, tabId);
    if (group == null) {
      return RemoveTabResult(newState: state);
    }

    // Remove the tab
    final updatedGroup = group.removeTab(tabId);

    // Check if group became empty
    if (updatedGroup.tabCount == 0) {
      // If this is the root, special handling
      if (state.id == group.id) {
        return RemoveTabResult(
          newState: updatedGroup,
          rootBecameEmpty: true,
        );
      }

      // Otherwise, mark the empty group for cleanup
      final newState =
          WorkspaceHelpers.replacePanel(state, group.id, updatedGroup);
      return RemoveTabResult(
        newState: newState,
        emptyGroupId: group.id,
      );
    }

    // Group still has tabs, just update
    final newState =
        WorkspaceHelpers.replacePanel(state, group.id, updatedGroup);
    return RemoveTabResult(newState: newState);
  }

  /// Activates a tab by ID.
  ///
  /// Finds the group containing the tab and sets it as active.
  ///
  /// Example:
  /// ```dart
  /// final updated = TabService.activateTab(workspace, 'tab-3');
  /// ```
  static SplitPanel activateTab(SplitPanel state, String tabId) {
    final group = WorkspaceHelpers.findGroupByTabId(state, tabId);
    if (group == null) return state;

    final updatedGroup = group.activateTab(tabId);
    return WorkspaceHelpers.replacePanel(state, group.id, updatedGroup);
  }

  /// Reorders a tab within its group.
  ///
  /// Example:
  /// ```dart
  /// final updated = TabService.reorderTab(workspace, 'tab-2', 3);
  /// ```
  static SplitPanel reorderTab(
    SplitPanel state,
    String tabId,
    int newIndex,
  ) {
    final group = WorkspaceHelpers.findGroupByTabId(state, tabId);
    if (group == null) return state;

    final updatedGroup = group.reorderTab(tabId, newIndex);
    return WorkspaceHelpers.replacePanel(state, group.id, updatedGroup);
  }

  /// Finds the first group in the tree (leftmost leaf).
  static SplitPanel? _findFirstGroup(SplitPanel panel) {
    if (panel.isLeaf) return panel;

    if (panel.isSplit && panel.children != null && panel.children!.isNotEmpty) {
      return _findFirstGroup(panel.children!.first);
    }

    return null;
  }

  /// Gets all tabs from a specific group.
  ///
  /// Example:
  /// ```dart
  /// final tabs = TabService.getTabsFromGroup(workspace, 'group-2');
  /// print('Group has ${tabs.length} tabs');
  /// ```
  static List<TabData> getTabsFromGroup(SplitPanel state, String groupId) {
    final group = WorkspaceHelpers.findGroupById(state, groupId);
    return group?.tabs ?? [];
  }

  /// Gets the active tab from a specific group.
  ///
  /// Example:
  /// ```dart
  /// final activeTab = TabService.getActiveTabFromGroup(workspace, 'group-2');
  /// if (activeTab != null) {
  ///   print('Active: ${activeTab.title}');
  /// }
  /// ```
  static TabData? getActiveTabFromGroup(SplitPanel state, String groupId) {
    final group = WorkspaceHelpers.findGroupById(state, groupId);
    return group?.activeTab;
  }

  /// Finds a tab by ID anywhere in the workspace.
  ///
  /// Example:
  /// ```dart
  /// final tab = TabService.findTabById(workspace, 'tab-5');
  /// if (tab != null) {
  ///   print('Found: ${tab.title}');
  /// }
  /// ```
  static TabData? findTabById(SplitPanel state, String tabId) {
    final group = WorkspaceHelpers.findGroupByTabId(state, tabId);
    if (group?.tabs == null) return null;

    try {
      return group!.tabs!.firstWhere((tab) => tab.id == tabId);
    } catch (e) {
      return null;
    }
  }
}