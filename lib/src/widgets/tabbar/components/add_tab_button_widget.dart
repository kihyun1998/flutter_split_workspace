import 'package:flutter/material.dart';

import '../../../theme/split_workspace_theme.dart';

/// An add tab button widget with theme-integrated styling
///
/// This widget creates a button that allows users to add new tabs, positioned at the
/// end of the tab bar with styling that matches the current theme.
class AddTabButtonWidget extends StatelessWidget {
  /// Theme configuration for styling
  final SplitWorkspaceTheme theme;

  /// Callback when the add button is tapped
  final VoidCallback? onAddTab;

  const AddTabButtonWidget({super.key, required this.theme, this.onAddTab});

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;
    final tabTheme = theme.tab;

    return Container(
      width: 36,
      height: tabTheme.height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border(
          left: BorderSide(color: colorScheme.dividerColor, width: 1),
        ),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(theme.borderRadius),
          bottomRight: Radius.circular(theme.borderRadius),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onAddTab,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(theme.borderRadius),
            bottomRight: Radius.circular(theme.borderRadius),
          ),
          child: Icon(Icons.add, size: 16, color: colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
