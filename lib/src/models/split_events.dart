import '../enums/drop_zone_type.dart';

/// Event data for split creation requests.
///
/// This event is fired when a user drops a tab onto a split zone,
/// requesting the creation of a new split panel.
///
/// Example usage:
/// ```dart
/// SplitWorkspace(
///   workspace: myWorkspace,
///   onSplitRequested: (event) {
///     setState(() {
///       final result = SplitService.createSplit(
///         myWorkspace,
///         sourceTabId: event.sourceTabId,
///         dropZone: event.dropZone,
///         targetGroupId: event.targetGroupId,
///       );
///       myWorkspace = result.newState;
///     });
///   },
/// )
/// ```
class SplitEvent {
  /// ID of the tab being moved to create the split
  final String sourceTabId;

  /// The drop zone type determining split direction and position
  final DropZoneType dropZone;

  /// Target group ID where the split should be created.
  ///
  /// If null, the split is created at the root level.
  /// If not null, the split is created within the specified group (nested split).
  final String? targetGroupId;

  /// Creates a split event.
  const SplitEvent({
    required this.sourceTabId,
    required this.dropZone,
    this.targetGroupId,
  });

  @override
  String toString() {
    return 'SplitEvent(tab: $sourceTabId, zone: ${dropZone.description}, target: $targetGroupId)';
  }
}

/// Event data for tab movement between groups.
///
/// This event is fired when a user drops a tab into the center zone
/// of another group, requesting the tab be moved to that group.
///
/// Example usage:
/// ```dart
/// SplitWorkspace(
///   workspace: myWorkspace,
///   onTabMove: (event) {
///     setState(() {
///       final result = SplitService.moveTabToGroup(
///         myWorkspace,
///         tabId: event.tabId,
///         targetGroupId: event.targetGroupId,
///         insertIndex: event.insertIndex,
///       );
///       myWorkspace = result.newState;
///     });
///   },
/// )
/// ```
class TabMoveEvent {
  /// ID of the tab being moved
  final String tabId;

  /// ID of the group receiving the tab
  final String targetGroupId;

  /// Index position where the tab should be inserted.
  ///
  /// If null, the tab is appended to the end of the group.
  final int? insertIndex;

  /// Creates a tab move event.
  const TabMoveEvent({
    required this.tabId,
    required this.targetGroupId,
    this.insertIndex,
  });

  @override
  String toString() {
    return 'TabMoveEvent(tab: $tabId, target: $targetGroupId, index: $insertIndex)';
  }
}

/// Event data for split ratio changes.
///
/// This event is fired when a user drags the resizable splitter
/// to adjust the split ratio between two panels.
///
/// Example usage:
/// ```dart
/// SplitWorkspace(
///   workspace: myWorkspace,
///   onRatioChange: (event) {
///     setState(() {
///       myWorkspace = SplitService.updateSplitRatio(
///         myWorkspace,
///         event.panelId,
///         event.newRatio,
///       );
///     });
///   },
/// )
/// ```
class RatioChangeEvent {
  /// ID of the split panel whose ratio is being changed
  final String panelId;

  /// New ratio value (0.0 to 1.0)
  ///
  /// Represents the proportion of space allocated to the first child.
  /// For example, 0.3 means 30% for first child, 70% for second child.
  final double newRatio;

  /// Creates a ratio change event.
  const RatioChangeEvent({
    required this.panelId,
    required this.newRatio,
  });

  @override
  String toString() {
    return 'RatioChangeEvent(panel: $panelId, ratio: ${(newRatio * 100).toStringAsFixed(1)}%)';
  }
}