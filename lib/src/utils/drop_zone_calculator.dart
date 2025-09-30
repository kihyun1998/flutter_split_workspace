import 'dart:ui';

import '../enums/drop_zone_type.dart';

/// Utility class for calculating drop zones based on mouse position.
///
/// This class provides methods to determine which drop zone a drag
/// operation is hovering over based on the mouse position relative
/// to a target area.
///
/// The target area is divided into 5 zones:
/// - Left edge (33%): [DropZoneType.splitLeft]
/// - Right edge (33%): [DropZoneType.splitRight]
/// - Top edge (33% of center 34% width): [DropZoneType.splitTop]
/// - Bottom edge (33% of center 34% width): [DropZoneType.splitBottom]
/// - Center (34x34%): [DropZoneType.moveToGroup]
///
/// Visual representation:
/// ```
/// ┌─────┬───────┬─────┐
/// │  L  │   T   │  R  │
/// │  E  │ (33%) │  I  │
/// │  F  ├───────┤  G  │
/// │  T  │       │  H  │
/// │     │CENTER │  T  │
/// │(33%)│(MOVE) │(33%)│
/// │     ├───────┤     │
/// │     │   B   │     │
/// │     │ (33%) │     │
/// └─────┴───────┴─────┘
/// ```
class DropZoneCalculator {
  /// Private constructor to prevent instantiation.
  DropZoneCalculator._();

  /// The ratio of the edge zones (default 0.33 = 33%)
  static const double edgeRatio = 0.33;

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

    // Calculate edge thresholds (33% for left/right, center is 34%)
    final leftThreshold = width * 0.33;
    final rightThreshold = width * 0.67;
    final topThreshold = height * 0.33;
    final bottomThreshold = height * 0.67;

    // Check left edge first (highest priority) - full height
    if (x < leftThreshold) {
      return DropZoneType.splitLeft;
    }

    // Check right edge - full height
    if (x > rightThreshold) {
      return DropZoneType.splitRight;
    }

    // In center width area (33~67%), check top/bottom zones
    // Top zone: center width, top 33% height
    if (y < topThreshold) {
      return DropZoneType.splitTop;
    }

    // Bottom zone: center width, bottom 33% height
    if (y > bottomThreshold) {
      return DropZoneType.splitBottom;
    }

    // Default to center (move to group) - 34x34% area
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

    switch (dropZone) {
      case DropZoneType.splitLeft:
        // Left 33% - full height
        return Rect.fromLTWH(0, 0, width * 0.33, height);

      case DropZoneType.splitRight:
        // Right 33% - full height
        return Rect.fromLTWH(width * 0.67, 0, width * 0.33, height);

      case DropZoneType.splitTop:
        // Center 34% width, top 33% height
        return Rect.fromLTWH(width * 0.33, 0, width * 0.34, height * 0.33);

      case DropZoneType.splitBottom:
        // Center 34% width, bottom 33% height
        return Rect.fromLTWH(
          width * 0.33,
          height * 0.67,
          width * 0.34,
          height * 0.33,
        );

      case DropZoneType.moveToGroup:
        // Center 34% width, center 34% height
        return Rect.fromLTWH(
          width * 0.33,
          height * 0.33,
          width * 0.34,
          height * 0.34,
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