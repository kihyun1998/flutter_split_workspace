import 'package:flutter/material.dart';

import '../models/drag_state.dart';
import '../enums/drop_zone_type.dart';

/// InheritedWidget that provides drag state to descendant widgets.
///
/// This widget makes the current drag state available throughout the widget tree,
/// allowing any descendant widget to access and respond to drag operations.
///
/// Use [DragConfig.of] to access the drag state from descendant widgets.
///
/// Example:
/// ```dart
/// final config = DragConfig.of(context);
/// if (config?.dragState.isDragging ?? false) {
///   // Show drag feedback
/// }
/// ```
class DragConfig extends InheritedWidget {
  /// The current drag state.
  final DragState dragState;

  /// Callback to update the drag state.
  final void Function(DragState newState) onDragStateChanged;

  const DragConfig({
    super.key,
    required this.dragState,
    required this.onDragStateChanged,
    required super.child,
  });

  /// Retrieves the nearest [DragConfig] ancestor from the widget tree.
  ///
  /// Returns null if no [DragConfig] ancestor is found.
  ///
  /// Example:
  /// ```dart
  /// final config = DragConfig.of(context);
  /// if (config != null && config.dragState.isDragging) {
  ///   // Handle drag state
  /// }
  /// ```
  static DragConfig? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DragConfig>();
  }

  @override
  bool updateShouldNotify(DragConfig oldWidget) {
    return dragState != oldWidget.dragState;
  }
}

/// Provider widget that manages drag state and provides it to descendants.
///
/// This is a convenience widget that combines state management with
/// the [DragConfig] InheritedWidget. Use this at the top of your
/// workspace widget tree to enable drag and drop functionality.
///
/// Example:
/// ```dart
/// DragConfigProvider(
///   child: SplitWorkspace(
///     workspace: myWorkspace,
///     ...
///   ),
/// )
/// ```
class DragConfigProvider extends StatefulWidget {
  /// The child widget tree that will have access to drag state.
  final Widget child;

  const DragConfigProvider({
    super.key,
    required this.child,
  });

  @override
  State<DragConfigProvider> createState() => _DragConfigProviderState();
}

class _DragConfigProviderState extends State<DragConfigProvider> {
  DragState _dragState = const DragState.idle();

  void _updateDragState(DragState newState) {
    if (mounted) {
      setState(() {
        _dragState = newState;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DragConfig(
      dragState: _dragState,
      onDragStateChanged: _updateDragState,
      child: widget.child,
    );
  }
}

/// Extension on BuildContext to easily access drag configuration.
///
/// Provides convenient helper methods for accessing drag state.
///
/// Example:
/// ```dart
/// if (context.isDragging) {
///   // Show drag feedback
/// }
///
/// context.updateDropZone(DropZoneType.splitLeft, 'group-1');
/// ```
extension DragConfigExtension on BuildContext {
  /// Gets the current drag configuration.
  DragConfig? get dragConfig => DragConfig.of(this);

  /// Gets the current drag state.
  DragState? get dragState => dragConfig?.dragState;

  /// Whether a drag operation is currently in progress.
  bool get isDragging => dragState?.isDragging ?? false;

  /// Updates the drag state.
  void updateDragState(DragState newState) {
    dragConfig?.onDragStateChanged(newState);
  }

  /// Starts a drag operation.
  void startDrag(DragState dragState) {
    updateDragState(dragState);
  }

  /// Ends the current drag operation (resets to idle state).
  void endDrag() {
    updateDragState(const DragState.idle());
  }

  /// Updates the current drop zone during a drag operation.
  void updateDropZone(DropZoneType? dropZone, String? targetGroupId) {
    final currentState = dragState;
    if (currentState != null && currentState.isDragging) {
      updateDragState(
        currentState.copyWith(
          currentDropZone: dropZone,
          targetGroupId: targetGroupId,
        ),
      );
    }
  }

  /// Clears the current drop zone (when leaving a drop target).
  void clearDropZone() {
    final currentState = dragState;
    if (currentState != null && currentState.isDragging) {
      updateDragState(
        currentState.copyWithNull(
          currentDropZone: true,
          targetGroupId: true,
        ),
      );
    }
  }
}