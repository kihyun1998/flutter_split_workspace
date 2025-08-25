import 'package:flutter/material.dart';

import '../models/tab_data.dart';
import 'tab_item_widget.dart';

class TabBarWidget extends StatelessWidget {
  final List<TabData> tabs;
  final String? activeTabId;
  final Function(String tabId)? onTabTap;
  final Function(String tabId)? onTabClose;
  final VoidCallback? onAddTab;

  const TabBarWidget({
    super.key,
    required this.tabs,
    this.activeTabId,
    this.onTabTap,
    this.onTabClose,
    this.onAddTab,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor, width: 1)),
      ),
      child: Row(
        children: [
          // 탭들
          ...tabs.map(
            (tab) => TabItemWidget(
              tab: tab,
              isActive: tab.id == activeTabId,
              onTap: () => onTabTap?.call(tab.id),
              onClose: tab.closeable ? () => onTabClose?.call(tab.id) : null,
            ),
          ),

          // 새 탭 추가 버튼
          if (onAddTab != null)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: theme.dividerColor, width: 1),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onAddTab,
                  child: Icon(
                    Icons.add,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),

          // 남은 공간
          Expanded(child: Container(color: theme.colorScheme.surface)),
        ],
      ),
    );
  }
}
