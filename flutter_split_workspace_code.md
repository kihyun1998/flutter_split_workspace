# flutter_split_workspace
## Project Structure

```
flutter_split_workspace/
├── example/
    └── lib/
    │   └── main.dart
└── lib/
    ├── src/
        ├── models/
        │   └── tab_data.dart
        └── widgets/
        │   ├── tab_bar_widget.dart
        │   ├── tab_item_widget.dart
        │   └── tab_workspace.dart
    └── flutter_split_workspace.dart
```

## example/lib/main.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_split_workspace/flutter_split_workspace.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Split Workspace Example',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const ExampleScreen(),
    );
  }
}

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  List<TabData> tabs = [];
  String? activeTabId;
  int _tabCounter = 0;

  @override
  void initState() {
    super.initState();
    _initializeTabs();
  }

  void _initializeTabs() {
    tabs = [
      TabData(
        id: 'tab_1',
        title: 'Welcome',
        content: _buildWelcomeContent(),
        closeable: false, // 첫 번째 탭은 닫을 수 없도록
      ),
      TabData(
        id: 'tab_2',
        title: 'Tab 2',
        content: _buildTabContent('Tab 2', Colors.blue),
      ),
      TabData(
        id: 'tab_3',
        title: 'Tab 3',
        content: _buildTabContent('Tab 3', Colors.green),
      ),
    ];
    activeTabId = 'tab_1';
    _tabCounter = 3;
  }

  Widget _buildWelcomeContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.tab, size: 64, color: Colors.purple),
          const SizedBox(height: 16),
          const Text(
            'Flutter Split Workspace',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Basic Tab System Example',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          const Text(
            '• Click tabs to switch\n• Close tabs with X button\n• Add new tabs with + button',
            style: TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Text(
            'Active Tab: ${activeTabId ?? 'None'}',
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total Tabs: ${tabs.length}',
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(String title, Color color) {
    return Container(
      color: color.withOpacity(0.1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description, size: 48, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Content for $title',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _onTabTap(String tabId) {
    setState(() {
      activeTabId = tabId;
    });
  }

  void _onTabClose(String tabId) {
    setState(() {
      tabs.removeWhere((tab) => tab.id == tabId);

      // 닫힌 탭이 활성 탭이었다면 다른 탭으로 변경
      if (activeTabId == tabId) {
        if (tabs.isNotEmpty) {
          activeTabId = tabs.last.id;
        } else {
          activeTabId = null;
        }
      }
    });
  }

  void _onAddTab() {
    _tabCounter++;
    final colors = [Colors.orange, Colors.red, Colors.teal, Colors.pink];
    final color = colors[(_tabCounter - 1) % colors.length];

    final newTab = TabData(
      id: 'tab_$_tabCounter',
      title: 'New Tab $_tabCounter',
      content: _buildTabContent('New Tab $_tabCounter', color),
    );

    setState(() {
      tabs.add(newTab);
      activeTabId = newTab.id; // 새 탭을 활성화
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Split Workspace Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: TabWorkspace(
        tabs: tabs,
        activeTabId: activeTabId,
        onTabTap: _onTabTap,
        onTabClose: _onTabClose,
        onAddTab: _onAddTab,
      ),
    );
  }
}

```
## lib/flutter_split_workspace.dart
```dart
library;

export 'src/models/tab_data.dart';
export 'src/widgets/tab_bar_widget.dart';
export 'src/widgets/tab_item_widget.dart';
export 'src/widgets/tab_workspace.dart';

```
## lib/src/models/tab_data.dart
```dart
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

```
## lib/src/widgets/tab_bar_widget.dart
```dart
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

```
## lib/src/widgets/tab_item_widget.dart
```dart
import 'package:flutter/material.dart';

import '../models/tab_data.dart';

class TabItemWidget extends StatelessWidget {
  final TabData tab;
  final bool isActive;
  final VoidCallback? onTap;
  final VoidCallback? onClose;

  const TabItemWidget({
    super.key,
    required this.tab,
    required this.isActive,
    this.onTap,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 36,
      constraints: const BoxConstraints(minWidth: 120, maxWidth: 200),
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.surface
            : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: Border(right: BorderSide(color: theme.dividerColor, width: 1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.only(
              left: 12,
              right: tab.closeable ? 4 : 12, // 오른쪽 패딩 조정
            ),
            child: Row(
              children: [
                // 탭 제목
                Expanded(
                  child: Text(
                    tab.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isActive
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // 닫기 버튼 (Positioned 제거하고 Row 내에서 처리)
                if (tab.closeable)
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onClose,
                        borderRadius: BorderRadius.circular(4),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: isActive
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

```
## lib/src/widgets/tab_workspace.dart
```dart
import 'package:flutter/material.dart';

import '../models/tab_data.dart';
import 'tab_bar_widget.dart';

class TabWorkspace extends StatelessWidget {
  final List<TabData> tabs;
  final String? activeTabId;
  final Function(String tabId)? onTabTap;
  final Function(String tabId)? onTabClose;
  final VoidCallback? onAddTab;

  const TabWorkspace({
    super.key,
    required this.tabs,
    this.activeTabId,
    this.onTabTap,
    this.onTabClose,
    this.onAddTab,
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

```
