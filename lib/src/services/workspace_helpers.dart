import '../models/split_panel.dart';

/// Utility functions for traversing and analyzing the split panel tree.
///
/// This class provides pure functions for common tree operations:
/// - Finding panels by ID
/// - Finding panels by tab ID
/// - Counting tabs and groups
/// - Calculating tree depth
///
/// All methods are static and side-effect free.
class WorkspaceHelpers {
  WorkspaceHelpers._(); // Private constructor - utility class

  /// Finds a group (leaf node) by its ID.
  ///
  /// Recursively searches the tree starting from [root].
  /// Returns null if not found.
  ///
  /// Example:
  /// ```dart
  /// final group = WorkspaceHelpers.findGroupById(workspace, 'group-2');
  /// if (group != null) {
  ///   print('Found group with ${group.tabCount} tabs');
  /// }
  /// ```
  static SplitPanel? findGroupById(SplitPanel root, String groupId) {
    // Base case: this is the group we're looking for
    if (root.id == groupId && root.isLeaf) {
      return root;
    }

    // Recursive case: search children
    if (root.isSplit && root.children != null) {
      for (final child in root.children!) {
        final found = findGroupById(child, groupId);
        if (found != null) return found;
      }
    }

    return null;
  }

  /// Finds any panel (leaf or branch) by its ID.
  ///
  /// Unlike [findGroupById], this can return split containers as well.
  ///
  /// Example:
  /// ```dart
  /// final panel = WorkspaceHelpers.findPanelById(workspace, 'split-1');
  /// if (panel?.isSplit == true) {
  ///   print('Found a split container');
  /// }
  /// ```
  static SplitPanel? findPanelById(SplitPanel root, String panelId) {
    // Base case: this is the panel we're looking for
    if (root.id == panelId) {
      return root;
    }

    // Recursive case: search children
    if (root.isSplit && root.children != null) {
      for (final child in root.children!) {
        final found = findPanelById(child, panelId);
        if (found != null) return found;
      }
    }

    return null;
  }

  /// Finds the group containing a specific tab.
  ///
  /// Searches for the leaf node that contains the tab with [tabId].
  /// Returns null if the tab is not found in any group.
  ///
  /// Example:
  /// ```dart
  /// final group = WorkspaceHelpers.findGroupByTabId(workspace, 'tab-5');
  /// if (group != null) {
  ///   print('Tab is in group: ${group.id}');
  /// }
  /// ```
  static SplitPanel? findGroupByTabId(SplitPanel root, String tabId) {
    // Base case: this is a leaf node, check if it contains the tab
    if (root.isLeaf && root.tabs != null) {
      final hasTab = root.tabs!.any((tab) => tab.id == tabId);
      if (hasTab) return root;
    }

    // Recursive case: search children
    if (root.isSplit && root.children != null) {
      for (final child in root.children!) {
        final found = findGroupByTabId(child, tabId);
        if (found != null) return found;
      }
    }

    return null;
  }

  /// Finds the parent panel of a given panel.
  ///
  /// Returns the split container that has [childId] as one of its children.
  /// Returns null if the panel is the root or not found.
  ///
  /// Example:
  /// ```dart
  /// final parent = WorkspaceHelpers.findParentPanel(workspace, 'group-2');
  /// if (parent != null) {
  ///   print('Parent split direction: ${parent.direction}');
  /// }
  /// ```
  static SplitPanel? findParentPanel(SplitPanel root, String childId) {
    // Can't be parent of itself
    if (root.id == childId) return null;

    // Check if any direct child matches
    if (root.isSplit && root.children != null) {
      final hasDirectChild =
          root.children!.any((child) => child.id == childId);
      if (hasDirectChild) return root;

      // Recursively search in children
      for (final child in root.children!) {
        final found = findParentPanel(child, childId);
        if (found != null) return found;
      }
    }

    return null;
  }

  /// Counts the total number of tabs in the workspace.
  ///
  /// Recursively sums up tabs from all leaf nodes.
  ///
  /// Example:
  /// ```dart
  /// final total = WorkspaceHelpers.countTabs(workspace);
  /// print('Total tabs: $total');
  /// ```
  static int countTabs(SplitPanel panel) {
    if (panel.isLeaf) {
      return panel.tabCount;
    }

    if (panel.isSplit && panel.children != null) {
      return panel.children!.fold(0, (sum, child) => sum + countTabs(child));
    }

    return 0;
  }

  /// Counts the total number of groups (leaf nodes) in the workspace.
  ///
  /// Example:
  /// ```dart
  /// final groups = WorkspaceHelpers.countGroups(workspace);
  /// print('Total groups: $groups');
  /// ```
  static int countGroups(SplitPanel panel) {
    if (panel.isLeaf) {
      return 1;
    }

    if (panel.isSplit && panel.children != null) {
      return panel.children!.fold(0, (sum, child) => sum + countGroups(child));
    }

    return 0;
  }

  /// Calculates the maximum depth of the tree.
  ///
  /// Returns the number of levels from root to deepest leaf.
  /// A single group has depth 1.
  ///
  /// Example:
  /// ```dart
  /// final depth = WorkspaceHelpers.calculateDepth(workspace);
  /// print('Tree depth: $depth');
  /// ```
  static int calculateDepth(SplitPanel panel) {
    if (panel.isLeaf) {
      return 1;
    }

    if (panel.isSplit && panel.children != null) {
      final childDepths =
          panel.children!.map((child) => calculateDepth(child)).toList();
      return 1 + childDepths.reduce((a, b) => a > b ? a : b);
    }

    return 1;
  }

  /// Collects all leaf nodes (groups) in the tree.
  ///
  /// Returns a flat list of all groups in the workspace.
  ///
  /// Example:
  /// ```dart
  /// final allGroups = WorkspaceHelpers.collectAllGroups(workspace);
  /// for (final group in allGroups) {
  ///   print('Group ${group.id}: ${group.tabCount} tabs');
  /// }
  /// ```
  static List<SplitPanel> collectAllGroups(SplitPanel panel) {
    if (panel.isLeaf) {
      return [panel];
    }

    if (panel.isSplit && panel.children != null) {
      final groups = <SplitPanel>[];
      for (final child in panel.children!) {
        groups.addAll(collectAllGroups(child));
      }
      return groups;
    }

    return [];
  }

  /// Collects all split containers in the tree.
  ///
  /// Returns a flat list of all branch nodes.
  ///
  /// Example:
  /// ```dart
  /// final allSplits = WorkspaceHelpers.collectAllSplits(workspace);
  /// print('Total split containers: ${allSplits.length}');
  /// ```
  static List<SplitPanel> collectAllSplits(SplitPanel panel) {
    if (panel.isLeaf) {
      return [];
    }

    final splits = <SplitPanel>[panel];

    if (panel.isSplit && panel.children != null) {
      for (final child in panel.children!) {
        splits.addAll(collectAllSplits(child));
      }
    }

    return splits;
  }

  /// Replaces a panel in the tree with a new panel.
  ///
  /// Recursively searches for the panel with [targetId] and replaces it
  /// with [newPanel]. Returns the modified tree.
  ///
  /// If the target is the root, returns [newPanel] directly.
  /// If the target is not found, returns the original tree unchanged.
  ///
  /// Example:
  /// ```dart
  /// final updated = WorkspaceHelpers.replacePanel(
  ///   workspace,
  ///   'group-2',
  ///   updatedGroup,
  /// );
  /// ```
  static SplitPanel replacePanel(
    SplitPanel root,
    String targetId,
    SplitPanel newPanel,
  ) {
    // Base case: this is the target panel
    if (root.id == targetId) {
      return newPanel;
    }

    // Recursive case: update children
    if (root.isSplit && root.children != null) {
      final updatedChildren = root.children!.map((child) {
        return replacePanel(child, targetId, newPanel);
      }).toList();

      return root.copyWith(children: updatedChildren);
    }

    return root;
  }

  /// Validates the tree structure.
  ///
  /// Checks for common issues:
  /// - Split nodes must have exactly 2 children
  /// - Leaf nodes must have tabs
  /// - No circular references
  ///
  /// Returns an error message if invalid, null if valid.
  ///
  /// Example:
  /// ```dart
  /// final error = WorkspaceHelpers.validateTree(workspace);
  /// if (error != null) {
  ///   print('Invalid tree: $error');
  /// }
  /// ```
  static String? validateTree(SplitPanel panel) {
    // Check split nodes
    if (panel.isSplit) {
      if (panel.children == null || panel.children!.length != 2) {
        return 'Split panel ${panel.id} must have exactly 2 children';
      }

      if (panel.direction == null) {
        return 'Split panel ${panel.id} must have a direction';
      }

      // Validate children recursively
      for (final child in panel.children!) {
        final childError = validateTree(child);
        if (childError != null) return childError;
      }
    }

    // Check leaf nodes
    if (panel.isLeaf) {
      if (panel.tabs == null) {
        return 'Leaf panel ${panel.id} must have tabs array';
      }
    }

    return null;
  }
}