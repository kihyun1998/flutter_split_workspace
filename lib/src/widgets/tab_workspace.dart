// lib/src/widgets/tab_workspace.dart (수정)
import 'package:flutter/material.dart';

import '../models/tab_data.dart';
import 'tab_bar_widget.dart';

class TabWorkspace extends StatelessWidget {
  final List<TabData> tabs;
  final String? activeTabId;
  final Function(String tabId)? onTabTap;
  final Function(String tabId)? onTabClose;
  final VoidCallback? onAddTab;
  final Function(int oldIndex, int newIndex)? onTabReorder; // 순서 변경 콜백 추가
  final String? workspaceId; // 워크스페이스 ID 추가

  const TabWorkspace({
    super.key,
    required this.tabs,
    this.activeTabId,
    this.onTabTap,
    this.onTabClose,
    this.onAddTab,
    this.onTabReorder, // 추가
    this.workspaceId, // 추가
  });

  TabData? get activeTab {
    if (activeTabId == null) return null;
    try {
      return tabs.firstWhere((tab) => tab.id == activeTabId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveWorkspaceId = workspaceId ?? 'default'; // 기본값 제공

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      child: Column(
        children: [
          // 탭 바
          TabBarWidget(
            tabs: tabs,
            activeTabId: activeTabId,
            onTabTap: onTabTap,
            onTabClose: onTabClose,
            onAddTab: onAddTab,
            onTabReorder: onTabReorder, // 전달
            workspaceId: effectiveWorkspaceId, // 전달
          ),

          // 콘텐츠 영역
          Expanded(
            child:
                activeTab?.content ??
                Container(
                  color: theme.colorScheme.surface,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(
                            0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No active tab',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
