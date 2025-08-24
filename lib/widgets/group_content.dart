import 'package:flutter/material.dart';
import '../models/tab_model.dart';

class GroupContent extends StatelessWidget {
  final TabModel? activeTab;
  final Widget Function(TabModel)? contentBuilder;
  final Widget? emptyState;

  const GroupContent({
    super.key,
    this.activeTab,
    this.contentBuilder,
    this.emptyState,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (activeTab == null) {
      return emptyState ?? _buildDefaultEmptyState(theme);
    }

    if (contentBuilder != null) {
      return contentBuilder!(activeTab!);
    }

    return _buildDefaultContent(theme);
  }

  Widget _buildDefaultEmptyState(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tab,
              size: 48,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No tabs open',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultContent(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            activeTab!.title,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          if (activeTab!.tooltip != null)
            Text(
              activeTab!.tooltip!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 48,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Content for "${activeTab!.title}"',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use contentBuilder to provide custom content',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}