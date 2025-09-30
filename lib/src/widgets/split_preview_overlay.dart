import 'package:flutter/material.dart';

import '../enums/drop_zone_type.dart';
import '../theme/split_workspace_theme.dart';
import '../utils/drop_zone_calculator.dart';

/// A widget that displays a visual preview overlay during drag operations.
///
/// This overlay shows where the dragged tab will be placed when dropped,
/// with different visual styles for different drop zones:
/// - Split zones (left/right/top/bottom): Shows new group area and existing group area
/// - Move zone (center): Shows the entire area highlighted
///
/// Example:
/// ```dart
/// SplitPreviewOverlay(
///   dropZone: DropZoneType.splitLeft,
///   size: MediaQuery.of(context).size,
///   theme: myTheme,
/// )
/// ```
class SplitPreviewOverlay extends StatelessWidget {
  /// The current drop zone to preview (null if no preview).
  final DropZoneType? dropZone;

  /// The size of the content area.
  final Size size;

  /// Theme configuration for styling.
  final SplitWorkspaceTheme? theme;

  const SplitPreviewOverlay({
    super.key,
    required this.dropZone,
    required this.size,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (dropZone == null || size.width == 0 || size.height == 0) {
      return const SizedBox.shrink();
    }

    final workspaceTheme = theme ?? SplitWorkspaceTheme.defaultTheme;
    final colorScheme = workspaceTheme.colorScheme;

    // Different colors for move vs split
    final isMoveZone = dropZone == DropZoneType.moveToGroup;
    final previewColor = isMoveZone
        ? colorScheme.primary.withOpacity(0.2)
        : colorScheme.primaryContainer.withOpacity(0.3);
    final borderColor = isMoveZone
        ? colorScheme.primary.withOpacity(0.6)
        : colorScheme.primary.withOpacity(0.8);

    // Get preview rect for the drop zone
    final previewRect = DropZoneCalculator.getPreviewRect(dropZone!, size);

    return Stack(
      children: [
        // Dimmed overlay on the entire area
        Container(
          width: size.width,
          height: size.height,
          color: Colors.black.withOpacity(0.1),
        ),

        // Highlighted preview area
        Positioned(
          left: previewRect.left,
          top: previewRect.top,
          width: previewRect.width,
          height: previewRect.height,
          child: Container(
            decoration: BoxDecoration(
              color: previewColor,
              border: Border.all(
                color: borderColor,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: _buildPreviewLabel(dropZone!, colorScheme, isMoveZone),
            ),
          ),
        ),

        // Split line indicator (for split zones only)
        if (!isMoveZone) _buildSplitLineIndicator(dropZone!, size, colorScheme),
      ],
    );
  }

  /// Builds the label text shown in the preview area.
  Widget _buildPreviewLabel(
    DropZoneType dropZone,
    dynamic colorScheme,
    bool isMoveZone,
  ) {
    final label = _getDropZoneLabel(dropZone);
    final icon = _getDropZoneIcon(dropZone);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isMoveZone
            ? colorScheme.primary
            : colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: isMoveZone
                ? colorScheme.onPrimary
                : colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isMoveZone
                  ? colorScheme.onPrimary
                  : colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the split line indicator for split zones.
  Widget _buildSplitLineIndicator(
    DropZoneType dropZone,
    Size size,
    dynamic colorScheme,
  ) {
    switch (dropZone) {
      case DropZoneType.splitLeft:
        return Positioned(
          left: size.width * 0.5,
          top: 0,
          bottom: 0,
          child: Container(
            width: 4,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.5),
                  blurRadius: 8,
                ),
              ],
            ), 
          ),
        );

      case DropZoneType.splitRight:
        return Positioned(
          left: size.width * 0.5 - 4,
          top: 0,
          bottom: 0,
          child: Container(
            width: 4,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        );

      case DropZoneType.splitTop:
        return Positioned(
          left: 0,
          right: 0,
          top: size.height * 0.5,
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        );

      case DropZoneType.splitBottom:
        return Positioned(
          left: 0,
          right: 0,
          top: size.height * 0.5 - 4,
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        );

      case DropZoneType.moveToGroup:
        return const SizedBox.shrink();
    }
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

  /// Gets an appropriate icon for the drop zone.
  IconData _getDropZoneIcon(DropZoneType dropZone) {
    switch (dropZone) {
      case DropZoneType.splitLeft:
        return Icons.arrow_back;
      case DropZoneType.splitRight:
        return Icons.arrow_forward;
      case DropZoneType.splitTop:
        return Icons.arrow_upward;
      case DropZoneType.splitBottom:
        return Icons.arrow_downward;
      case DropZoneType.moveToGroup:
        return Icons.add_circle_outline;
    }
  }
}