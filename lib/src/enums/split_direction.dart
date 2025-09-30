/// Enum representing the direction of a split panel.
///
/// Used by [SplitPanel] to determine whether child panels should be
/// arranged horizontally (side by side) or vertically (stacked).
///
/// Example:
/// ```dart
/// // Horizontal split (top and bottom)
/// SplitPanel.split(
///   direction: SplitDirection.horizontal,
///   children: [topPanel, bottomPanel],
/// )
///
/// // Vertical split (left and right)
/// SplitPanel.split(
///   direction: SplitDirection.vertical,
///   children: [leftPanel, rightPanel],
/// )
/// ```
enum SplitDirection {
  /// Horizontal split - panels stacked vertically (top and bottom)
  ///
  /// Visual representation:
  /// ```
  /// ┌─────────────┐
  /// │   Panel 1   │
  /// ├─────────────┤  ← Horizontal divider
  /// │   Panel 2   │
  /// └─────────────┘
  /// ```
  horizontal,

  /// Vertical split - panels arranged horizontally (left and right)
  ///
  /// Visual representation:
  /// ```
  /// ┌──────┬──────┐
  /// │      │      │
  /// │Panel1│Panel2│  ← Vertical divider
  /// │      │      │
  /// └──────┴──────┘
  /// ```
  vertical,
}