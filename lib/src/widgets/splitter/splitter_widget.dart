import 'package:flutter/material.dart';

import '../../enums/split_direction.dart';
import '../../theme/split_workspace_theme.dart';

/// A visual splitter between two split panels.
///
/// This widget displays a divider line between split panels and shows
/// the current split ratio. In future phases, it will support dragging
/// to adjust the ratio.
///
/// The splitter orientation (horizontal/vertical) is determined by the
/// [direction] parameter:
/// - [SplitDirection.horizontal]: Horizontal splitter (stacked vertically)
/// - [SplitDirection.vertical]: Vertical splitter (side by side)
class SplitterWidget extends StatefulWidget {
  /// The split direction (determines splitter orientation)
  final SplitDirection direction;

  /// Current split ratio (0.0 to 1.0)
  final double ratio;

  /// Theme configuration for styling
  final SplitWorkspaceTheme? theme;

  /// Callback when ratio changes (Phase 7)
  final Function(double newRatio)? onRatioChanged;

  const SplitterWidget({
    super.key,
    required this.direction,
    required this.ratio,
    this.theme,
    this.onRatioChanged,
  });

  @override
  State<SplitterWidget> createState() => _SplitterWidgetState();
}

class _SplitterWidgetState extends State<SplitterWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final workspaceTheme = widget.theme ?? SplitWorkspaceTheme.defaultTheme;
    final colorScheme = workspaceTheme.colorScheme;

    final isHorizontal = widget.direction == SplitDirection.horizontal;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: isHorizontal
          ? SystemMouseCursors.resizeRow
          : SystemMouseCursors.resizeColumn,
      child: Container(
        width: isHorizontal ? double.infinity : 8,
        height: isHorizontal ? 8 : double.infinity,
        decoration: BoxDecoration(
          color: _isHovered
              ? colorScheme.primary.withOpacity(0.1)
              : colorScheme.dividerColor,
          border: Border.all(
            color: _isHovered
                ? colorScheme.primary.withOpacity(0.3)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Center(
          child: _buildRatioIndicator(colorScheme, isHorizontal),
        ),
      ),
    );
  }

  /// Builds the ratio indicator (shows split percentage)
  Widget _buildRatioIndicator(
    dynamic colorScheme,
    bool isHorizontal,
  ) {
    if (!_isHovered) return const SizedBox.shrink();

    final percentage = (widget.ratio * 100).toInt();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        '$percentage%',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimaryContainer,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}