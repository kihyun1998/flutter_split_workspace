import 'package:flutter/material.dart';

import '../enums/drop_zone_type.dart';
import '../models/drag_data.dart';
import '../utils/drop_zone_calculator.dart';
import 'drag_config.dart';

/// A widget that wraps content and makes it a drop target for tabs.
///
/// This widget handles detecting which drop zone (left/right/top/bottom/center)
/// the mouse is hovering over during a drag operation, and triggers
/// appropriate actions when a tab is dropped.
///
/// The content area is divided into 5 drop zones:
/// - Left edge (20%): Creates a split with new group on left
/// - Right edge (20%): Creates a split with new group on right
/// - Top edge (20%): Creates a split with new group on top
/// - Bottom edge (20%): Creates a split with new group on bottom
/// - Center (40x40%): Moves tab to this group
///
/// Example:
/// ```dart
/// DropTargetContent(
///   groupId: 'group-1',
///   onDrop: (dragData, dropZone) {
///     if (dropZone == DropZoneType.moveToGroup) {
///       // Move tab to this group
///     } else {
///       // Create split
///     }
///   },
///   child: TabContent(...),
/// )
/// ```
class DropTargetContent extends StatefulWidget {
  /// The ID of the group that this content belongs to.
  final String groupId;

  /// Callback when a tab is dropped on this content.
  ///
  /// Parameters:
  /// - [dragData]: Information about the dragged tab
  /// - [dropZone]: Which zone the tab was dropped in
  final void Function(DragData dragData, DropZoneType dropZone)? onDrop;

  /// The content to display and make droppable.
  final Widget child;

  const DropTargetContent({
    super.key,
    required this.groupId,
    this.onDrop,
    required this.child,
  });

  @override
  State<DropTargetContent> createState() => _DropTargetContentState();
}

class _DropTargetContentState extends State<DropTargetContent> {
  DropZoneType? _currentDropZone;

  @override
  Widget build(BuildContext context) {
    return DragTarget<DragData>(
      onWillAcceptWithDetails: (details) {
        // Accept any tab from the same workspace
        return true;
      },
      onMove: (details) {
        _handleDragMove(context, details);
      },
      onLeave: (data) {
        _handleDragLeave(context);
      },
      onAcceptWithDetails: (details) {
        _handleDrop(context, details.data);
      },
      builder: (context, candidateData, rejectedData) {
        return widget.child;
      },
    );
  }

  /// Handles drag movement over the content area.
  ///
  /// Calculates which drop zone the mouse is hovering over and
  /// updates the drag state via DragConfig.
  void _handleDragMove(BuildContext context, DragTargetDetails<DragData> details) {
    // Get the render box to calculate local position
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // Convert global position to local position
    final localPosition = renderBox.globalToLocal(details.offset);
    final size = renderBox.size;
    final dropZone = DropZoneCalculator.calculateDropZone(
      localPosition,
      size,
    );

    // Update drag state if zone changed
    if (dropZone != _currentDropZone) {
      setState(() {
        _currentDropZone = dropZone;
      });
      context.updateDropZone(dropZone, widget.groupId);
    }
  }

  /// Handles drag leaving the content area.
  ///
  /// Clears the current drop zone in the drag state.
  void _handleDragLeave(BuildContext context) {
    setState(() {
      _currentDropZone = null;
    });
    context.clearDropZone();
  }

  /// Handles tab drop on the content area.
  ///
  /// Triggers the onDrop callback with the drag data and drop zone.
  void _handleDrop(BuildContext context, DragData dragData) {
    if (_currentDropZone != null) {
      widget.onDrop?.call(dragData, _currentDropZone!);
    }

    // Clear drag state
    setState(() {
      _currentDropZone = null;
    });
    context.endDrag();
  }
}

/// A widget that displays visual feedback for drop zones during drag.
///
/// This widget should be placed as an overlay on top of the content
/// to show which zone will be activated when the tab is dropped.
///
/// Example:
/// ```dart
/// Stack(
///   children: [
///     DropTargetContent(...),
///     if (context.isDragging)
///       DropZoneIndicator(
///         dropZone: context.dragState?.currentDropZone,
///         size: MediaQuery.of(context).size,
///       ),
///   ],
/// )
/// ```
class DropZoneIndicator extends StatelessWidget {
  /// The current drop zone to highlight (null if none).
  final DropZoneType? dropZone;

  /// The size of the content area.
  final Size size;

  /// Color for the drop zone indicator.
  final Color? indicatorColor;

  /// Opacity of the indicator.
  final double opacity;

  const DropZoneIndicator({
    super.key,
    this.dropZone,
    required this.size,
    this.indicatorColor,
    this.opacity = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    if (dropZone == null) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final color = indicatorColor ?? colorScheme.primary;

    // Get the rect for the drop zone
    final rect = DropZoneCalculator.getPreviewRect(dropZone!, size);

    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(opacity),
          border: Border.all(
            color: color.withOpacity(0.8),
            width: 2,
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getDropZoneLabel(dropZone!),
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Gets a human-readable label for the drop zone.
  String _getDropZoneLabel(DropZoneType dropZone) {
    switch (dropZone) {
      case DropZoneType.splitLeft:
        return 'Split Left';
      case DropZoneType.splitRight:
        return 'Split Right';
      case DropZoneType.splitTop:
        return 'Split Top';
      case DropZoneType.splitBottom:
        return 'Split Bottom';
      case DropZoneType.moveToGroup:
        return 'Move Here';
    }
  }
}