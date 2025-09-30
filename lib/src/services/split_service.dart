import '../enums/drop_zone_type.dart';
import '../enums/split_direction.dart';
import '../models/split_panel.dart';
import '../models/tab_data.dart';
import 'workspace_helpers.dart';

/// Result of a split operation that may create empty groups.
class SplitResult {
  /// The new workspace state after the split
  final SplitPanel newState;

  /// ID of any group that became empty (null if none)
  final String? emptyGroupId;

  /// Whether empty group cleanup is needed
  final bool needsEmptyGroupCleanup;

  const SplitResult({
    required this.newState,
    this.emptyGroupId,
    this.needsEmptyGroupCleanup = false,
  });
}

/// Result of a tab move operation.
class MoveResult {
  /// The new workspace state after the move
  final SplitPanel newState;

  /// ID of any group that became empty (null if none)
  final String? emptyGroupId;

  const MoveResult({
    required this.newState,
    this.emptyGroupId,
  });
}

/// Service providing split panel operations.
///
/// This service handles:
/// - Creating splits (nested splits supported)
/// - Moving tabs between groups
/// - Removing empty groups
/// - Updating split ratios
///
/// All methods are pure functions.
///
/// Example usage:
/// ```dart
/// // Create a split
/// final result = SplitService.createSplitWithResult(
///   workspace,
///   sourceTabId: 'tab-1',
///   dropZone: DropZoneType.splitLeft,
/// );
///
/// // Clean up if needed
/// if (result.needsEmptyGroupCleanup) {
///   final cleaned = SplitService.removeEmptyGroup(
///     result.newState,
///     result.emptyGroupId!,
///   );
/// }
/// ```
class SplitService {
  SplitService._(); // Private constructor

  /// Maximum allowed split depth (to prevent performance issues)
  static const int maxSplitDepth = 4;

  static int _nextPanelId = 1000;

  /// Generates a unique panel ID.
  static String _generatePanelId(String prefix) {
    final id = '$prefix-$_nextPanelId';
    _nextPanelId++;
    return id;
  }

  // ==========================================================================
  // Split Creation
  // ==========================================================================

  /// Creates a split, returning detailed result information.
  ///
  /// If [dropZone] is [DropZoneType.moveToGroup], returns state unchanged
  /// (use [moveTabToGroupWithEmptyCheck] instead).
  ///
  /// If [targetGroupId] is provided, creates a nested split within that group.
  /// Otherwise, creates a split at the root level.
  ///
  /// Example:
  /// ```dart
  /// // Root level split
  /// final result = SplitService.createSplitWithResult(
  ///   workspace,
  ///   sourceTabId: 'tab-1',
  ///   dropZone: DropZoneType.splitLeft,
  /// );
  ///
  /// // Nested split
  /// final result = SplitService.createSplitWithResult(
  ///   workspace,
  ///   sourceTabId: 'tab-5',
  ///   dropZone: DropZoneType.splitTop,
  ///   targetGroupId: 'group-2',
  /// );
  /// ```
  static SplitResult createSplitWithResult(
    SplitPanel state, {
    required String sourceTabId,
    required DropZoneType dropZone,
    String? targetGroupId,
  }) {
    // Central zone doesn't create a split
    if (dropZone == DropZoneType.moveToGroup) {
      return SplitResult(newState: state);
    }

    // Check max depth
    final currentDepth = WorkspaceHelpers.calculateDepth(state);
    if (currentDepth >= maxSplitDepth) {
      return SplitResult(newState: state);
    }

    // Target specific group or root
    if (targetGroupId != null) {
      return _splitSpecificGroupWithResult(
        state,
        sourceTabId,
        dropZone,
        targetGroupId,
      );
    } else {
      return _splitRootGroup(state, sourceTabId, dropZone);
    }
  }

  /// Backward compatible method (returns only the state).
  static SplitPanel createSplit(
    SplitPanel state, {
    required String sourceTabId,
    required DropZoneType dropZone,
    String? targetGroupId,
  }) {
    final result = createSplitWithResult(
      state,
      sourceTabId: sourceTabId,
      dropZone: dropZone,
      targetGroupId: targetGroupId,
    );
    return result.newState;
  }

  /// Splits a specific group (supports external tabs and nested splits).
  static SplitResult _splitSpecificGroupWithResult(
    SplitPanel state,
    String sourceTabId,
    DropZoneType dropZone,
    String targetGroupId,
  ) {
    // Find target group
    final targetGroup = WorkspaceHelpers.findGroupById(state, targetGroupId);
    if (targetGroup == null) {
      return SplitResult(newState: state);
    }

    // Find source group (may be same or different)
    final sourceGroup = WorkspaceHelpers.findGroupByTabId(state, sourceTabId);
    if (sourceGroup == null) {
      return SplitResult(newState: state);
    }

    final isSameGroup = sourceGroup.id == targetGroup.id;
    final isExternalTab = !isSameGroup;

    // Validate: can't split if target would be empty
    if (isSameGroup && targetGroup.tabCount <= 1) {
      return SplitResult(newState: state);
    }

    // Get the tab
    final sourceTab = sourceGroup.tabs?.firstWhere(
      (tab) => tab.id == sourceTabId,
      orElse: () => TabData(id: '', title: ''),
    );
    if (sourceTab == null || sourceTab.id.isEmpty) {
      return SplitResult(newState: state);
    }

    // Execute the split
    final splitResult = _executeSplitLogic(
      targetGroup,
      sourceTab,
      dropZone,
      isExternalTab,
    );

    // Replace target group with new split
    SplitPanel newState = WorkspaceHelpers.replacePanel(
      state,
      targetGroupId,
      splitResult,
    );

    // If external tab, remove from source group
    if (isExternalTab) {
      final updatedSourceGroup = sourceGroup.removeTab(sourceTabId);
      newState = WorkspaceHelpers.replacePanel(
        newState,
        sourceGroup.id,
        updatedSourceGroup,
      );

      // Check if source group became empty
      if (updatedSourceGroup.tabCount == 0) {
        return SplitResult(
          newState: newState,
          emptyGroupId: sourceGroup.id,
          needsEmptyGroupCleanup: true,
        );
      }
    }

    return SplitResult(newState: newState);
  }

  /// Splits the root group.
  static SplitResult _splitRootGroup(
    SplitPanel state,
    String sourceTabId,
    DropZoneType dropZone,
  ) {
    // Must be a leaf with multiple tabs
    if (!state.isLeaf || state.tabs == null || state.tabs!.length <= 1) {
      return SplitResult(newState: state);
    }

    // Find the tab
    final sourceTab = state.tabs!.firstWhere(
      (tab) => tab.id == sourceTabId,
      orElse: () => TabData(id: '', title: ''),
    );
    if (sourceTab.id.isEmpty) {
      return SplitResult(newState: state);
    }

    // Execute split logic
    final splitResult = _executeSplitLogic(
      state,
      sourceTab,
      dropZone,
      false, // Same group
    );

    return SplitResult(newState: splitResult);
  }

  /// Core split logic: creates the split structure.
  static SplitPanel _executeSplitLogic(
    SplitPanel targetGroup,
    TabData sourceTab,
    DropZoneType dropZone,
    bool isExternalTab,
  ) {
    // Remove source tab from target (if not external)
    final remainingTabs = isExternalTab
        ? (targetGroup.tabs ?? [])
        : (targetGroup.tabs ?? [])
            .where((tab) => tab.id != sourceTab.id)
            .toList();

    // Determine new active tab for existing group
    String? existingActiveId = targetGroup.activeTabId;
    if (!isExternalTab && existingActiveId == sourceTab.id) {
      existingActiveId =
          remainingTabs.isNotEmpty ? remainingTabs.first.id : null;
    }

    // Create existing group with remaining tabs
    final existingGroup = SplitPanel.singleGroup(
      id: targetGroup.id,
      tabs: remainingTabs,
      activeTabId: existingActiveId,
    );

    // Create new group with source tab
    final newGroup = SplitPanel.singleGroup(
      id: _generatePanelId('group'),
      tabs: [sourceTab],
      activeTabId: sourceTab.id,
    );

    // Determine split direction and order
    final direction = dropZone.splitDirection!;
    final isNewFirst = dropZone.isNewGroupFirst;

    final children = isNewFirst
        ? [newGroup, existingGroup]
        : [existingGroup, newGroup];

    // Create split container
    return SplitPanel.split(
      id: _generatePanelId('split'),
      direction: direction,
      children: children,
      ratio: 0.5,
    );
  }

  // ==========================================================================
  // Tab Movement
  // ==========================================================================

  /// Moves a tab to another group with empty group detection.
  ///
  /// Example:
  /// ```dart
  /// final result = SplitService.moveTabToGroupWithEmptyCheck(
  ///   workspace,
  ///   tabId: 'tab-3',
  ///   targetGroupId: 'group-2',
  ///   insertIndex: 1,
  /// );
  ///
  /// if (result.emptyGroupId != null) {
  ///   // Clean up empty source group
  /// }
  /// ```
  static MoveResult moveTabToGroupWithEmptyCheck(
    SplitPanel state, {
    required String tabId,
    required String targetGroupId,
    int? insertIndex,
  }) {
    // Find source and target groups
    final sourceGroup = WorkspaceHelpers.findGroupByTabId(state, tabId);
    final targetGroup = WorkspaceHelpers.findGroupById(state, targetGroupId);

    if (sourceGroup == null || targetGroup == null) {
      return MoveResult(newState: state);
    }

    // Can't move to same group
    if (sourceGroup.id == targetGroup.id) {
      return MoveResult(newState: state);
    }

    // Get the tab
    final tab = sourceGroup.tabs?.firstWhere(
      (t) => t.id == tabId,
      orElse: () => TabData(id: '', title: ''),
    );
    if (tab == null || tab.id.isEmpty) {
      return MoveResult(newState: state);
    }

    // Remove from source
    final updatedSource = sourceGroup.removeTab(tabId);

    // Add to target
    final updatedTarget = insertIndex != null
        ? targetGroup.insertTabAt(tab, insertIndex, makeActive: true)
        : targetGroup.addTab(tab, makeActive: true);

    // Update both groups
    SplitPanel newState = WorkspaceHelpers.replacePanel(
      state,
      sourceGroup.id,
      updatedSource,
    );
    newState = WorkspaceHelpers.replacePanel(
      newState,
      targetGroup.id,
      updatedTarget,
    );

    // Check if source became empty
    if (updatedSource.tabCount == 0) {
      return MoveResult(
        newState: newState,
        emptyGroupId: sourceGroup.id,
      );
    }

    return MoveResult(newState: newState);
  }

  // ==========================================================================
  // Empty Group Removal
  // ==========================================================================

  /// Removes an empty group and restructures the tree.
  ///
  /// When a group becomes empty, it should be removed and its sibling
  /// should replace the parent split container.
  ///
  /// Example:
  /// ```
  /// Before: Split(root)
  ///           ├─ Group(left): []      ← empty
  ///           └─ Group(right): [A, B]
  ///
  /// After:  Group(right): [A, B]      ← sibling promoted
  /// ```
  ///
  /// Usage:
  /// ```dart
  /// final cleaned = SplitService.removeEmptyGroup(workspace, 'group-left');
  /// ```
  static SplitPanel removeEmptyGroup(SplitPanel state, String emptyGroupId) {
    // Find the empty group
    final emptyGroup = WorkspaceHelpers.findGroupById(state, emptyGroupId);
    if (emptyGroup == null || emptyGroup.tabCount > 0) {
      return state;
    }

    // If this is the root, can't remove it
    if (state.id == emptyGroupId) {
      return state;
    }

    // Find parent
    final parent = WorkspaceHelpers.findParentPanel(state, emptyGroupId);
    if (parent == null || !parent.isSplit || parent.children == null) {
      return state;
    }

    // Find sibling (the other child)
    final sibling = parent.children!.firstWhere(
      (child) => child.id != emptyGroupId,
    );

    // Replace parent with sibling
    final grandparent = WorkspaceHelpers.findParentPanel(state, parent.id);

    // If parent is root, sibling becomes new root
    if (grandparent == null) {
      return sibling;
    }

    // Otherwise, replace parent with sibling in tree
    return WorkspaceHelpers.replacePanel(state, parent.id, sibling);
  }

  // ==========================================================================
  // Ratio Update
  // ==========================================================================

  /// Updates the split ratio of a panel.
  ///
  /// The [newRatio] should be between 0.1 and 0.9 (10% to 90%).
  ///
  /// Example:
  /// ```dart
  /// final updated = SplitService.updateSplitRatio(
  ///   workspace,
  ///   'split-1',
  ///   0.6, // 60% : 40%
  /// );
  /// ```
  static SplitPanel updateSplitRatio(
    SplitPanel state,
    String panelId,
    double newRatio,
  ) {
    // Clamp ratio to reasonable range
    final clampedRatio = newRatio.clamp(0.1, 0.9);

    final panel = WorkspaceHelpers.findPanelById(state, panelId);
    if (panel == null || !panel.isSplit) {
      return state;
    }

    final updatedPanel = panel.copyWith(ratio: clampedRatio);
    return WorkspaceHelpers.replacePanel(state, panelId, updatedPanel);
  }
}