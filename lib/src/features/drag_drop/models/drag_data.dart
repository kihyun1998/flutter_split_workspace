import '../../tab/models/tab_data.dart';

/// Data model containing information about a tab being dragged.
///
/// This model is used internally by the drag and drop system to track
/// which tab is being moved, where it came from, and where it should
/// be placed. It enables tabs to be reordered within a workspace or
/// potentially moved between different workspaces in the future.
///
/// This class is primarily used by [TabItemWidget] when creating
/// draggable tabs and by [TabBarWidget] when handling drop operations.
class DragData {
  /// The tab data being dragged.
  ///
  /// Contains all the information about the tab including its ID,
  /// title, content, and whether it can be closed.
  final TabData tab;

  /// Original index position of the tab before dragging started.
  ///
  /// This is used to restore the tab to its original position
  /// if the drag operation is cancelled or fails.
  final int originalIndex;

  /// Identifier of the workspace where the drag originated.
  ///
  /// Used to track which workspace the tab came from, enabling
  /// future support for moving tabs between different workspaces.
  /// Currently used for validation and debugging purposes.
  final String sourceWorkspaceId;

  /// Creates a new drag data instance.
  ///
  /// All parameters are required as they're essential for tracking
  /// the drag operation and enabling proper tab reordering.
  const DragData({
    required this.tab,
    required this.originalIndex,
    required this.sourceWorkspaceId,
  });

  /// Creates a copy of this drag data with some properties replaced.
  ///
  /// This method is useful during drag operations when some aspects
  /// of the drag data need to be updated while preserving others.
  ///
  /// Example:
  /// ```dart
  /// final updatedDragData = originalDragData.copyWith(
  ///   originalIndex: newIndex,
  /// );
  /// ```
  DragData copyWith({
    TabData? tab,
    int? originalIndex,
    String? sourceWorkspaceId,
  }) {
    return DragData(
      tab: tab ?? this.tab,
      originalIndex: originalIndex ?? this.originalIndex,
      sourceWorkspaceId: sourceWorkspaceId ?? this.sourceWorkspaceId,
    );
  }
}
