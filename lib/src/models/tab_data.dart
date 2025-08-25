import 'package:flutter/material.dart';

class TabData {
  final String id;
  final String title;
  final Widget? content;
  final bool closeable;

  const TabData({
    required this.id,
    required this.title,
    this.content,
    this.closeable = true,
  });

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
