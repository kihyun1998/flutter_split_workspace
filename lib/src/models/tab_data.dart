import 'package:flutter/material.dart';

/// Data model representing a single tab in the workspace.
///
/// Each tab contains metadata and content that can be displayed
/// in a [TabWorkspace]. Tabs can be reordered via drag and drop,
/// and optionally closed by the user.
///
/// Example usage:
/// ```dart
/// final tab = TabData(
///   id: 'unique_tab_1',
///   title: 'My Document',
///   content: Text('Tab content goes here'),
///   closeable: true,
/// );
/// ```
class TabData {
  /// Unique identifier for this tab.
  ///
  /// This ID is used to track the tab across reordering operations
  /// and to determine which tab is currently active.
  final String id;

  /// Display title shown in the tab bar.
  ///
  /// This text appears on the tab button and should be concise
  /// and descriptive of the tab's content.
  final String title;

  /// Widget content displayed when this tab is active.
  ///
  /// Can be null if the tab serves as a placeholder or
  /// if content is loaded dynamically elsewhere.
  final Widget? content;

  /// Whether this tab can be closed by the user.
  ///
  /// When `true`, a close button (×) will appear on the tab.
  /// When `false`, the tab cannot be closed and no close button is shown.
  /// Defaults to `true`.
  final bool closeable;

  /// Creates a new tab data instance.
  ///
  /// The [id] and [title] parameters are required.
  /// The [content] can be null for tabs without immediate content.
  /// The [closeable] parameter defaults to `true`.
  const TabData({
    required this.id,
    required this.title,
    this.content,
    this.closeable = true,
  });

  /// Creates a copy of this tab with some properties replaced.
  ///
  /// This method is useful for updating tab properties without
  /// creating a completely new instance, preserving other values.
  ///
  /// Example:
  /// ```dart
  /// final updatedTab = originalTab.copyWith(
  ///   title: 'New Title',
  ///   closeable: false,
  /// );
  /// ```
  TabData copyWith({
    String? id,
    String? title,
    Widget? content,
    bool? closeable,
  }) {
    return TabData(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      closeable: closeable ?? this.closeable,
    );
  }
}
