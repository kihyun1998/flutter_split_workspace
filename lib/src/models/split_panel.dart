import '../enums/split_direction.dart';
import 'tab_data.dart';

/// A model representing a panel in the split workspace tree structure.
///
/// The split workspace uses a tree structure where each node is a [SplitPanel]:
/// - **Branch nodes** (split containers): have [direction] and [children]
/// - **Leaf nodes** (tab groups): have [tabs] and [activeTabId]
///
/// Example tree structure:
/// ```
/// Root (Split, vertical)
/// ├─ Group A (Leaf, [Tab1, Tab2])
/// └─ Split (horizontal)
///    ├─ Group B (Leaf, [Tab3])
///    └─ Group C (Leaf, [Tab4, Tab5])
/// ```
///
/// Visual representation:
/// ```
/// ┌────────┬────────────┐
/// │        │   Tab3     │
/// │ Tab1   ├────────────┤
/// │ Tab2   │ Tab4       │
/// │        │ Tab5       │
/// └────────┴────────────┘
/// ```
class SplitPanel {
  /// Unique identifier for this panel
  final String id;

  /// Split direction for branch nodes (null for leaf nodes)
  ///
  /// - [SplitDirection.horizontal]: children stacked vertically
  /// - [SplitDirection.vertical]: children arranged horizontally
  /// - `null`: this is a leaf node (tab group)
  final SplitDirection? direction;

  /// Child panels for branch nodes (null for leaf nodes)
  ///
  /// A split container always has exactly 2 children.
  final List<SplitPanel>? children;

  /// Tabs in this group (only for leaf nodes, null for branch nodes)
  final List<TabData>? tabs;

  /// Active tab ID for this group (only for leaf nodes)
  final String? activeTabId;

  /// Split ratio for this panel (0.0 to 1.0)
  ///
  /// Represents the ratio of the first child to the total space.
  /// For example, 0.5 means 50:50 split, 0.3 means 30:70 split.
  ///
  /// Default is 0.5 (equal split).
  final double ratio;

  /// Creates a split panel with the specified configuration.
  ///
  /// Use the named constructors [SplitPanel.singleGroup] or [SplitPanel.split]
  /// instead of this constructor for better type safety.
  const SplitPanel({
    required this.id,
    this.direction,
    this.children,
    this.tabs,
    this.activeTabId,
    this.ratio = 0.5,
  });

  /// Creates a single tab group (leaf node).
  ///
  /// Example:
  /// ```dart
  /// final group = SplitPanel.singleGroup(
  ///   id: 'group-1',
  ///   tabs: [
  ///     TabData(id: '1', title: 'Tab 1'),
  ///     TabData(id: '2', title: 'Tab 2'),
  ///   ],
  ///   activeTabId: '1',
  /// );
  /// ```
  SplitPanel.singleGroup({
    required this.id,
    required List<TabData> tabs,
    this.activeTabId,
  })  : direction = null,
        children = null,
        tabs = tabs,
        ratio = 0.5;

  /// Creates a split container (branch node) with two children.
  ///
  /// Example:
  /// ```dart
  /// final splitPanel = SplitPanel.split(
  ///   id: 'split-1',
  ///   direction: SplitDirection.vertical,
  ///   children: [leftGroup, rightGroup],
  ///   ratio: 0.6, // 60% left, 40% right
  /// );
  /// ```
  SplitPanel.split({
    required this.id,
    required this.direction,
    required List<SplitPanel> children,
    this.ratio = 0.5,
  })  : assert(children.length == 2, 'Split panel must have exactly 2 children'),
        children = children,
        tabs = null,
        activeTabId = null;

  /// Returns true if this is a leaf node (tab group).
  bool get isLeaf => tabs != null;

  /// Returns true if this is a branch node (split container).
  bool get isSplit => children != null;

  /// Returns the currently active tab, or null if none.
  ///
  /// Only applicable for leaf nodes.
  TabData? get activeTab {
    if (!isLeaf || tabs == null || activeTabId == null) return null;

    try {
      return tabs!.firstWhere((tab) => tab.id == activeTabId);
    } catch (e) {
      return null;
    }
  }

  /// Returns the number of tabs in this group.
  ///
  /// Returns 0 for branch nodes.
  int get tabCount => isLeaf ? (tabs?.length ?? 0) : 0;

  /// Creates a copy of this panel with some properties replaced.
  ///
  /// Example:
  /// ```dart
  /// final updated = panel.copyWith(
  ///   activeTabId: 'new-active-id',
  /// );
  /// ```
  SplitPanel copyWith({
    String? id,
    SplitDirection? direction,
    List<SplitPanel>? children,
    List<TabData>? tabs,
    String? activeTabId,
    double? ratio,
  }) {
    return SplitPanel(
      id: id ?? this.id,
      direction: direction ?? this.direction,
      children: children ?? this.children,
      tabs: tabs ?? this.tabs,
      activeTabId: activeTabId ?? this.activeTabId,
      ratio: ratio ?? this.ratio,
    );
  }

  /// Adds a tab to the end of this group (leaf nodes only).
  ///
  /// Example:
  /// ```dart
  /// final updated = panel.addTab(
  ///   TabData(id: '3', title: 'New Tab'),
  ///   makeActive: true,
  /// );
  /// ```
  SplitPanel addTab(TabData tab, {bool makeActive = false}) {
    if (!isLeaf) return this;

    final List<TabData> updatedTabs = [...(tabs ?? []), tab];
    final newActiveTabId = makeActive ? tab.id : activeTabId;

    return copyWith(
      tabs: updatedTabs,
      activeTabId: newActiveTabId,
    );
  }

  /// Inserts a tab at the specified index (leaf nodes only).
  ///
  /// The index is clamped to valid range [0, tabCount].
  ///
  /// Example:
  /// ```dart
  /// final updated = panel.insertTabAt(
  ///   TabData(id: '3', title: 'New Tab'),
  ///   1, // Insert at position 1
  ///   makeActive: true,
  /// );
  /// ```
  SplitPanel insertTabAt(TabData tab, int index, {bool makeActive = false}) {
    if (!isLeaf) return this;

    final List<TabData> updatedTabs = List<TabData>.from(tabs ?? []);
    final clampedIndex = index.clamp(0, updatedTabs.length);
    updatedTabs.insert(clampedIndex, tab);

    final newActiveTabId = makeActive ? tab.id : activeTabId;

    return copyWith(
      tabs: updatedTabs,
      activeTabId: newActiveTabId,
    );
  }

  /// Removes a tab by ID (leaf nodes only).
  ///
  /// If the removed tab was active, activates the tab at the same position
  /// (or the previous tab if it was the last one).
  ///
  /// Example:
  /// ```dart
  /// final updated = panel.removeTab('tab-2');
  /// ```
  SplitPanel removeTab(String tabId) {
    if (!isLeaf || tabs == null) return this;

    final updatedTabs = tabs!.where((tab) => tab.id != tabId).toList();

    // If removed tab was active, activate another tab
    String? newActiveTabId = activeTabId;
    if (activeTabId == tabId && updatedTabs.isNotEmpty) {
      final deletedIndex = tabs!.indexWhere((tab) => tab.id == tabId);
      final newActiveIndex = deletedIndex >= updatedTabs.length
          ? updatedTabs.length - 1
          : deletedIndex;
      newActiveTabId = updatedTabs[newActiveIndex].id;
    } else if (updatedTabs.isEmpty) {
      newActiveTabId = null;
    }

    return copyWith(
      tabs: updatedTabs,
      activeTabId: newActiveTabId,
    );
  }

  /// Activates a tab by ID (leaf nodes only).
  ///
  /// Example:
  /// ```dart
  /// final updated = panel.activateTab('tab-2');
  /// ```
  SplitPanel activateTab(String tabId) {
    if (!isLeaf || tabs == null) return this;

    final hasTab = tabs!.any((tab) => tab.id == tabId);
    if (!hasTab) return this;

    return copyWith(activeTabId: tabId);
  }

  /// Reorders a tab to a new position (leaf nodes only).
  ///
  /// Example:
  /// ```dart
  /// final updated = panel.reorderTab('tab-1', 2); // Move to index 2
  /// ```
  SplitPanel reorderTab(String tabId, int newIndex) {
    if (!isLeaf || tabs == null) return this;

    final updatedTabs = List<TabData>.from(tabs!);
    final tabIndex = updatedTabs.indexWhere((tab) => tab.id == tabId);

    if (tabIndex == -1) return this;

    // Remove and reinsert at new position
    final tab = updatedTabs.removeAt(tabIndex);
    final clampedIndex = newIndex.clamp(0, updatedTabs.length);
    updatedTabs.insert(clampedIndex, tab);

    return copyWith(tabs: updatedTabs);
  }

  /// Returns a string representation for debugging.
  @override
  String toString() {
    if (isLeaf) {
      return 'SplitPanel.leaf(id: $id, tabs: ${tabs?.length ?? 0}, active: $activeTabId)';
    } else {
      return 'SplitPanel.split(id: $id, direction: $direction, children: ${children?.length ?? 0})';
    }
  }

  /// Returns a tree structure representation for debugging.
  ///
  /// Example output:
  /// ```
  /// ├─ Split(root): vertical
  ///   ├─ Group(left): [Tab1, Tab2] active:Tab1
  ///   └─ Group(right): [Tab3, Tab4] active:Tab3
  /// ```
  String toTreeString([int indent = 0]) {
    final prefix = '  ' * indent;

    if (isLeaf) {
      final tabTitles = tabs?.map((t) => t.title).join(', ') ?? '';
      return '$prefix└─ Group($id): [$tabTitles] active:$activeTabId';
    } else {
      final lines = <String>[];
      lines.add('$prefix├─ Split($id): ${direction?.name ?? 'unknown'}');

      if (children != null) {
        for (int i = 0; i < children!.length; i++) {
          lines.add(children![i].toTreeString(indent + 1));
        }
      }

      return lines.join('\n');
    }
  }
}