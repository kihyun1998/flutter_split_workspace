import 'package:flutter/material.dart';
import 'split_direction.dart';

/// Enum representing the type of drop zone for drag and drop operations.
///
/// When a tab is dragged over a panel, five drop zones are displayed:
/// - Four zones for creating splits (left, right, top, bottom)
/// - One central zone for moving tabs to the group
///
/// Example:
/// ```
/// ┌───┬─────────┬───┐
/// │ L │    T    │ R │
/// ├───┼────┬────┼───┤
/// │ L │    │    │ R │
/// │ E │ M  │  M │ I │
/// │ F │ O  │  O │ G │
/// │ T │ V  │  V │ H │
/// │   │ E  │  E │ T │
/// ├───┼────┴────┼───┤
/// │ L │    B    │ R │
/// └───┴─────────┴───┘
///
/// L = splitLeft
/// R = splitRight
/// T = splitTop
/// B = splitBottom
/// MOVE = moveToGroup (center)
/// ```
enum DropZoneType {
  /// Left split zone - creates a new panel on the left
  ///
  /// Visual result:
  /// ```
  /// ┌────┬─────────┐
  /// │New │Existing │
  /// └────┴─────────┘
  /// ```
  splitLeft,

  /// Right split zone - creates a new panel on the right
  ///
  /// Visual result:
  /// ```
  /// ┌─────────┬────┐
  /// │Existing │New │
  /// └─────────┴────┘
  /// ```
  splitRight,

  /// Top split zone - creates a new panel on top
  ///
  /// Visual result:
  /// ```
  /// ┌─────────────┐
  /// │     New     │
  /// ├─────────────┤
  /// │  Existing   │
  /// └─────────────┘
  /// ```
  splitTop,

  /// Bottom split zone - creates a new panel on bottom
  ///
  /// Visual result:
  /// ```
  /// ┌─────────────┐
  /// │  Existing   │
  /// ├─────────────┤
  /// │     New     │
  /// └─────────────┘
  /// ```
  splitBottom,

  /// Center zone - moves tab to this group without creating split
  ///
  /// This is used for moving tabs between existing groups
  moveToGroup,
}

/// Extension on [DropZoneType] providing utility methods and properties.
extension DropZoneTypeExtension on DropZoneType {
  /// Returns the base color for this drop zone type.
  ///
  /// Split zones use blue, while move zone uses green.
  Color get baseColor {
    switch (this) {
      case DropZoneType.splitLeft:
      case DropZoneType.splitRight:
      case DropZoneType.splitTop:
      case DropZoneType.splitBottom:
        return Colors.blue; // Split zones
      case DropZoneType.moveToGroup:
        return Colors.green; // Move zone
    }
  }

  /// Returns the hover color (highlighted state).
  ///
  /// Uses 40% opacity of the base color.
  Color get hoverColor {
    return baseColor.withOpacity(0.4);
  }

  /// Returns the normal color (non-hover state).
  ///
  /// Uses 20% opacity of the base color.
  Color get normalColor {
    return baseColor.withOpacity(0.2);
  }

  /// Returns a human-readable description of this drop zone.
  String get description {
    switch (this) {
      case DropZoneType.splitLeft:
        return 'Split Left';
      case DropZoneType.splitRight:
        return 'Split Right';
      case DropZoneType.splitTop:
        return 'Split Top';
      case DropZoneType.splitBottom:
        return 'Split Bottom';
      case DropZoneType.moveToGroup:
        return 'Move to Group';
    }
  }

  /// Returns the split direction for this drop zone.
  ///
  /// Returns null for [moveToGroup] since it doesn't create a split.
  SplitDirection? get splitDirection {
    switch (this) {
      case DropZoneType.splitLeft:
      case DropZoneType.splitRight:
        return SplitDirection.vertical;
      case DropZoneType.splitTop:
      case DropZoneType.splitBottom:
        return SplitDirection.horizontal;
      case DropZoneType.moveToGroup:
        return null; // Not a split operation
    }
  }

  /// Returns whether the new group should be placed first.
  ///
  /// For splitLeft and splitTop, the new group is placed before the existing one.
  /// For splitRight and splitBottom, the new group is placed after.
  bool get isNewGroupFirst {
    switch (this) {
      case DropZoneType.splitLeft:
      case DropZoneType.splitTop:
        return true; // New group comes first
      case DropZoneType.splitRight:
      case DropZoneType.splitBottom:
        return false; // New group comes second
      case DropZoneType.moveToGroup:
        return false; // Not applicable
    }
  }

  /// Returns whether this drop zone type creates a split.
  bool get isSplitZone {
    return this != DropZoneType.moveToGroup;
  }
}