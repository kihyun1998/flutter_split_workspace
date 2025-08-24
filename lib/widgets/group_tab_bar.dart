import 'package:flutter/material.dart';
import '../models/tab_model.dart';
import 'tab_item.dart';

class GroupTabBar extends StatelessWidget {
  final List<TabModel> tabs;
  final String? activeTabId;
  final Function(String)? onTabTap;
  final Function(String)? onTabClose;

  const GroupTabBar({
    super.key,
    required this.tabs,
    this.activeTabId,
    this.onTabTap,
    this.onTabClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: tabs.isEmpty 
          ? const SizedBox.shrink()
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: tabs.map((tab) {
                  final isActive = tab.id == activeTabId;
                  return TabItem(
                    tab: tab,
                    isActive: isActive,
                    onTap: onTabTap != null ? () => onTabTap!(tab.id) : null,
                    onClose: (tab.canClose && onTabClose != null) 
                        ? () => onTabClose!(tab.id) 
                        : null,
                  );
                }).toList(),
              ),
            ),
    );
  }
}