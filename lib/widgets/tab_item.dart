import 'package:flutter/material.dart';
import '../models/tab_model.dart';

class TabItem extends StatelessWidget {
  final TabModel tab;
  final bool isActive;
  final VoidCallback? onTap;
  final VoidCallback? onClose;

  const TabItem({
    super.key,
    required this.tab,
    this.isActive = false,
    this.onTap,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 120,
          maxWidth: 200,
        ),
        height: 32,
        decoration: BoxDecoration(
          color: isActive 
              ? theme.colorScheme.surface
              : theme.colorScheme.surfaceContainer,
          border: Border(
            top: BorderSide(
              color: isActive 
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
            right: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 4),
                child: Text(
                  tab.title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isActive 
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (tab.canClose && onClose != null)
              SizedBox(
                width: 24,
                height: 24,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 14,
                  onPressed: onClose,
                  icon: Icon(
                    Icons.close,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  tooltip: 'Close tab',
                ),
              ),
          ],
        ),
      ),
    );
  }
}