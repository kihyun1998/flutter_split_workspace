// lib/src/widgets/tab_workspace.dart (수정)
import 'package:flutter/material.dart';

import '../models/tab_data.dart';
import '../theme/split_workspace_theme.dart';
import 'tab_bar_widget.dart';

class TabWorkspace extends StatelessWidget {
  final List<TabData> tabs;
  final String? activeTabId;
  final Function(String tabId)? onTabTap;
  final Function(String tabId)? onTabClose;
  final VoidCallback? onAddTab;
  final Function(int oldIndex, int newIndex)? onTabReorder;
  final String? workspaceId;
  final SplitWorkspaceTheme? theme; // 🆕 테마 추가

  const TabWorkspace({
    super.key,
    required this.tabs,
    this.activeTabId,
    this.onTabTap,
    this.onTabClose,
    this.onAddTab,
    this.onTabReorder,
    this.workspaceId,
    this.theme, // 🆕 테마 파라미터 추가
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
    final workspaceTheme = theme ?? SplitWorkspaceTheme.defaultTheme;
    final effectiveWorkspaceId = workspaceId ?? 'default';

    return Container(
      decoration: BoxDecoration(
        color: workspaceTheme.backgroundColor,
        borderRadius: BorderRadius.circular(workspaceTheme.borderRadius),
        border: workspaceTheme.borderWidth > 0
            ? Border.all(
                color: workspaceTheme.borderColor,
                width: workspaceTheme.borderWidth,
              )
            : null,
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
            onTabReorder: onTabReorder,
            workspaceId: effectiveWorkspaceId,
            theme: workspaceTheme,
          ),

          // 콘텐츠 영역
          Expanded(
            child:
                activeTab?.content ??
                Container(
                  color: workspaceTheme.backgroundColor,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 48,
                          color: workspaceTheme.tab.inactiveTextColor
                              .withOpacity(0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No active tab',
                          style: TextStyle(
                            fontFamily: workspaceTheme.tab.fontFamily,
                            fontSize: workspaceTheme.tab.fontSize,
                            color: workspaceTheme.tab.inactiveTextColor
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
