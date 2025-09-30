import 'dart:ui';

import '../enums/drop_zone_type.dart';

/// Utility class for calculating drop zones based on mouse position.
///
/// This class provides methods to determine which drop zone a drag
/// operation is hovering over based on the mouse position relative
/// to a target area.
///
/// The target area is divided into 5 zones:
/// - Left edge (20%): [DropZoneType.splitLeft]
/// - Right edge (20%): [DropZoneType.splitRight]
/// - Top edge (20%): [DropZoneType.splitTop]
/// - Bottom edge (20%): [DropZoneType.splitBottom]
/// - Center (remaining 40x40%): [DropZoneType.moveToGroup]
///
/// Visual representation:
/// ```
/// ┌─────┬──────────────┬─────┐
/// │     │     Top      │     │
/// │     │   (20%)      │     │
/// ├─────┼──────────────┼─────┤
/// │Left │              │Right│
/// │(20%)│   Center     │(20%)│
/// │     │   (move)     │     │
/// ├─────┼──────────────┼─────┤
/// │     │   Bottom     │     │
/// │     │   (20%)      │     │
/// └─────┴──────────────┴─────┘
/// ```
class DropZoneCalculator {
  /// Private constructor to prevent instantiation.
  DropZoneCalculator._();

  /// The ratio of the edge zones (default 0.2 = 20%)
  static const double edgeRatio = 0.2;

  /// Calculates which drop zone contains the given local position.
  ///
  /// Parameters:
  /// - [localPosition]: The position of the mouse relative to the target area
  /// - [targetSize]: The size of the target area
  ///
  /// Returns the [DropZoneType] that contains the position.
  ///
  /// Example:
  /// ```dart
  /// final dropZone = DropZoneCalculator.calculateDropZone(
  ///   Offset(50, 100),
  ///   Size(400, 300),
  /// );
  /// ```
  static DropZoneType calculateDropZone(
    Offset localPosition,
    Size targetSize,
  ) {
    final x = localPosition.dx;
    final y = localPosition.dy;
    final width = targetSize.width;
    final height = targetSize.height;

    // Calculate edge thresholds
    final leftThreshold = width * edgeRatio;
    final rightThreshold = width * (1 - edgeRatio);
    final topThreshold = height * edgeRatio;
    final bottomThreshold = height * (1 - edgeRatio);

    // Check left edge first (highest priority)
    if (x < leftThreshold) {
      return DropZoneType.splitLeft;
    }

    // Check right edge
    if (x > rightThreshold) {
      return DropZoneType.splitRight;
    }

    // Check top edge
    if (y < topThreshold) {
      return DropZoneType.splitTop;
    }

    // Check bottom edge
    if (y > bottomThreshold) {
      return DropZoneType.splitBottom;
    }

    // Default to center (move to group)
    return DropZoneType.moveToGroup;
  }

  /// Calculates the rectangle bounds for a specific drop zone.
  ///
  /// This is useful for rendering drop zone indicators or previews.
  ///
  /// Parameters:
  /// - [dropZone]: The drop zone type
  /// - [targetSize]: The size of the target area
  ///
  /// Returns a [Rect] representing the bounds of the drop zone.
  ///
  /// Example:
  /// ```dart
  /// final rect = DropZoneCalculator.getDropZoneRect(
  ///   DropZoneType.splitLeft,
  ///   Size(400, 300),
  /// );
  /// ```
  static Rect getDropZoneRect(DropZoneType dropZone, Size targetSize) {
    final width = targetSize.width;
    final height = targetSize.height;
    final leftEdge = width * edgeRatio;
    final rightEdge = width * (1 - edgeRatio);
    final topEdge = height * edgeRatio;
    final bottomEdge = height * (1 - edgeRatio);

    switch (dropZone) {
      case DropZoneType.splitLeft:
        return Rect.fromLTWH(0, 0, leftEdge, height);

      case DropZoneType.splitRight:
        return Rect.fromLTWH(rightEdge, 0, width - rightEdge, height);

      case DropZoneType.splitTop:
        return Rect.fromLTWH(0, 0, width, topEdge);

      case DropZoneType.splitBottom:
        return Rect.fromLTWH(0, bottomEdge, width, height - bottomEdge);

      case DropZoneType.moveToGroup:
        return Rect.fromLTWH(
          leftEdge,
          topEdge,
          rightEdge - leftEdge,
          bottomEdge - topEdge,
        );
    }
  }

  /// Gets the preview rect for a specific drop zone.
  ///
  /// This represents where the new group will be positioned after the drop.
  /// For split zones, this is half of the target area in the appropriate direction.
  /// For move zone, this is the entire target area.
  ///
  /// Parameters:
  /// - [dropZone]: The drop zone type
  /// - [targetSize]: The size of the target area
  ///
  /// Returns a [Rect] representing the preview area.
  ///
  /// Example:
  /// ```dart
  /// final previewRect = DropZoneCalculator.getPreviewRect(
  ///   DropZoneType.splitLeft,
  ///   Size(400, 300),
  /// );
  /// // Returns: Rect.fromLTWH(0, 0, 200, 300) - left half
  /// ```
  static Rect getPreviewRect(DropZoneType dropZone, Size targetSize) {
    final width = targetSize.width;
    final height = targetSize.height;

    switch (dropZone) {
      case DropZoneType.splitLeft:
        return Rect.fromLTWH(0, 0, width * 0.5, height);

      case DropZoneType.splitRight:
        return Rect.fromLTWH(width * 0.5, 0, width * 0.5, height);

      case DropZoneType.splitTop:
        return Rect.fromLTWH(0, 0, width, height * 0.5);

      case DropZoneType.splitBottom:
        return Rect.fromLTWH(0, height * 0.5, width, height * 0.5);

      case DropZoneType.moveToGroup:
        return Rect.fromLTWH(0, 0, width, height);
    }
  }

  /// Checks if the given position is within the bounds of the target.
  ///
  /// Returns true if the position is inside the target area.
  ///
  /// Example:
  /// ```dart
  /// final isInside = DropZoneCalculator.isPositionInBounds(
  ///   Offset(50, 100),
  ///   Size(400, 300),
  /// );
  /// ```
  static bool isPositionInBounds(Offset localPosition, Size targetSize) {
    return localPosition.dx >= 0 &&
        localPosition.dx <= targetSize.width &&
        localPosition.dy >= 0 &&
        localPosition.dy <= targetSize.height;
  }
}