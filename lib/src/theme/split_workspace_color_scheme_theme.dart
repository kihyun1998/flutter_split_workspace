// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class SplitWorkspaceColorSchemeTheme {
  final Color primary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color background;
  final Color surface;
  final Color onSurface;
  final Color surfaceContainerHighest;
  final Color onSurfaceVariant;
  final Color outline;
  final Color dividerColor;

  const SplitWorkspaceColorSchemeTheme({
    this.primary = Colors.blueGrey,
    this.primaryContainer = Colors.blueGrey,
    this.onPrimaryContainer = Colors.white,
    this.background = Colors.white,
    this.surface = Colors.white,
    this.onSurface = Colors.black87,
    this.surfaceContainerHighest = Colors.black12,
    this.onSurfaceVariant = Colors.black54,
    this.outline = Colors.grey,
    this.dividerColor = Colors.black26,
  });

  SplitWorkspaceColorSchemeTheme copyWith({
    Color? primary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? background,
    Color? surface,
    Color? onSurface,
    Color? surfaceContainerHighest,
    Color? onSurfaceVariant,
    Color? outline,
    Color? dividerColor,
  }) {
    return SplitWorkspaceColorSchemeTheme(
      primary: primary ?? this.primary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      surfaceContainerHighest:
          surfaceContainerHighest ?? this.surfaceContainerHighest,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      outline: outline ?? this.outline,
      dividerColor: dividerColor ?? this.dividerColor,
    );
  }
}
