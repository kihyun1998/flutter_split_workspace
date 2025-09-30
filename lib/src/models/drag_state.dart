import '../enums/drop_zone_type.dart';
import 'drag_data.dart';

/// Global drag state model for tracking drag and drop operations.
///
/// This model represents the current state of drag and drop operations
/// across the workspace. It tracks which tab is being dragged, where
/// it might be dropped, and provides visual feedback during the drag.
///
/// Used by [DragConfig] InheritedWidget to provide drag state to
/// descendant widgets throughout the widget tree.
///
/// Example:
/// ```dart
/// final dragState = DragState(
///   isDragging: true,
///   draggedTab: DragData(
///     tab: TabData(id: '1', title: 'Tab 1'),
///     originalIndex: 0,
///     sourceWorkspaceId: 'workspace-1',
///     sourceGroupId: 'group-1',
///   ),
///   currentDropZone: DropZoneType.splitLeft,
///   targetGroupId: 'group-2',
/// );
/// ```
class DragState {
  /// Whether a drag operation is currently in progress.
  final bool isDragging;

  /// Data about the tab being dragged (null if not dragging).
  final DragData? draggedTab;

  /// The current drop zone where the drag is hovering (null if not hovering).
  ///
  /// This is used to show visual feedback (preview overlay) during drag.
  final DropZoneType? currentDropZone;

  /// The ID of the group where the drag is currently hovering (null if not hovering).
  ///
  /// This is used to determine which group will receive the tab when dropped.
  final String? targetGroupId;

  /// Creates a drag state with the specified properties.
  ///
  /// By default, creates an idle state (no drag in progress).
  const DragState({
    this.isDragging = false,
    this.draggedTab,
    this.currentDropZone,
    this.targetGroupId,
  });

  /// Creates an idle drag state (no drag in progress).
  ///
  /// This is the default state when no drag operation is happening.
  const DragState.idle()
      : isDragging = false,
        draggedTab = null,
        currentDropZone = null,
        targetGroupId = null;

  /// Creates a drag state for when a drag has started.
  ///
  /// Example:
  /// ```dart
  /// final dragState = DragState.dragging(
  ///   dragData: DragData(
  ///     tab: myTab,
  ///     originalIndex: 0,
  ///     sourceWorkspaceId: 'workspace-1',
  ///     sourceGroupId: 'group-1',
  ///   ),
  /// );
  /// ```
  const DragState.dragging({
    required DragData dragData,
  })  : isDragging = true,
        draggedTab = dragData,
        currentDropZone = null,
        targetGroupId = null;

  /// Creates a copy of this drag state with some properties replaced.
  ///
  /// This is useful for updating the drag state during a drag operation.
  ///
  /// Example:
  /// ```dart
  /// final updated = dragState.copyWith(
  ///   currentDropZone: DropZoneType.splitLeft,
  ///   targetGroupId: 'group-2',
  /// );
  /// ```
  DragState copyWith({
    bool? isDragging,
    DragData? draggedTab,
    DropZoneType? currentDropZone,
    String? targetGroupId,
  }) {
    return DragState(
      isDragging: isDragging ?? this.isDragging,
      draggedTab: draggedTab ?? this.draggedTab,
      currentDropZone: currentDropZone ?? this.currentDropZone,
      targetGroupId: targetGroupId ?? this.targetGroupId,
    );
  }

  /// Creates a copy with nullable fields explicitly set to null.
  ///
  /// Use this when you want to clear specific fields.
  ///
  /// Example:
  /// ```dart
  /// final cleared = dragState.copyWithNull(
  ///   currentDropZone: true, // Clear currentDropZone
  ///   targetGroupId: true,   // Clear targetGroupId
  /// );
  /// ```
  DragState copyWithNull({
    bool? isDragging,
    bool draggedTab = false,
    bool currentDropZone = false,
    bool targetGroupId = false,
  }) {
    return DragState(
      isDragging: isDragging ?? this.isDragging,
      draggedTab: draggedTab ? null : this.draggedTab,
      currentDropZone: currentDropZone ? null : this.currentDropZone,
      targetGroupId: targetGroupId ? null : this.targetGroupId,
    );
  }

  @override
  String toString() {
    return 'DragState(isDragging: $isDragging, draggedTab: ${draggedTab?.tab.id}, '
        'currentDropZone: $currentDropZone, targetGroupId: $targetGroupId)';
  }
}