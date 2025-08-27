import 'package:flutter/material.dart';

import '../../../models/drag_data.dart';
import '../../../theme/split_workspace_theme.dart';

/// Drop zone indicator widget that shows where a dragged tab can be dropped
///
/// This widget is placed between tabs and becomes visible when a drag
/// operation is in progress, providing visual feedback for drop positions.
class DropZoneIndicator extends StatelessWidget {
  /// The index position this drop zone represents
  final int index;

  /// Whether this indicator should be visible
  final bool isActive;

  /// Theme configuration for styling
  final SplitWorkspaceTheme theme;

  /// Callback when a tab is dropped on this zone
  final Function(int sourceIndex, int targetIndex)? onTabReorder;

  /// Callback when drop operation completes
  final VoidCallback? onDropComplete;

  /// Current workspace ID
  final String workspaceId;

  const DropZoneIndicator({
    super.key,
    required this.index,
    required this.isActive,
    required this.theme,
    this.onTabReorder,
    this.onDropComplete,
    required this.workspaceId,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 2, // 고정 폭
      height: theme.tab.height,
      child: DragTarget<DragData>(
        onWillAcceptWithDetails: (details) => _canAcceptDrag(details.data),
        onAcceptWithDetails: (details) => _handleDrop(details.data),
        builder: (context, candidateData, rejectedData) {
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: isActive ? 1.0 : 0.0,
            child: Container(
              width: 2,
              height: theme.tab.height,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Checks if a dragged tab can be accepted by this drop zone
  bool _canAcceptDrag(DragData dragData) {
    return dragData.sourceWorkspaceId == workspaceId;
  }

  /// Handles drop on this zone
  void _handleDrop(DragData dragData) {
    if (_canAcceptDrag(dragData)) {
      onTabReorder?.call(dragData.originalIndex, index);
    }
    // 드롭 완료 후 콜백 호출
    onDropComplete?.call();
  }
}