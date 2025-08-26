// example/lib/main.dart (수정)
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
        closeable: false,
      ),
      TabData(
        id: 'tab_2',
        title: 'Draggable Tab 1',
        content: _buildTabContent('Draggable Tab 1', Colors.blue),
      ),
      TabData(
        id: 'tab_3',
        title: 'Draggable Tab 2',
        content: _buildTabContent('Draggable Tab 2', Colors.green),
      ),
      TabData(
        id: 'tab_4',
        title: 'Draggable Tab 3',
        content: _buildTabContent('Draggable Tab 3', Colors.orange),
      ),
    ];
    activeTabId = 'tab_1';
    _tabCounter = 4;
  }

  Widget _buildWelcomeContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.touch_app, size: 64, color: Colors.purple),
          const SizedBox(height: 16),
          const Text(
            'Flutter Split Workspace',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Drag & Drop Tab System',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          const Text(
            '• 탭을 길게 눌러서 드래그하세요\n• 다른 위치에 드롭하여 순서를 변경하세요\n• + 버튼으로 새 탭을 추가하세요\n• X 버튼으로 탭을 닫으세요',
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
            const SizedBox(height: 16),
            const Text(
              '👆 Try dragging the tabs above!',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
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
    final colors = [Colors.red, Colors.teal, Colors.pink, Colors.indigo];
    final color = colors[(_tabCounter - 1) % colors.length];

    final newTab = TabData(
      id: 'tab_$_tabCounter',
      title: 'New Tab $_tabCounter',
      content: _buildTabContent('New Tab $_tabCounter', color),
    );

    setState(() {
      tabs.add(newTab);
      activeTabId = newTab.id;
    });
  }

  // 🆕 탭 순서 변경 처리
  void _onTabReorder(int oldIndex, int newIndex) {
    setState(() {
      // 실제 인덱스가 변경되는 경우 처리
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }

      final TabData item = tabs.removeAt(oldIndex);
      tabs.insert(newIndex, item);
    });

    print('🔄 Tab reordered: $oldIndex → $newIndex');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Split Workspace - Drag & Drop Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: TabWorkspace(
        tabs: tabs,
        activeTabId: activeTabId,
        onTabTap: _onTabTap,
        onTabClose: _onTabClose,
        onAddTab: _onAddTab,
        onTabReorder: _onTabReorder, // 🆕 드래그 콜백 추가
        workspaceId: 'main_workspace', // 🆕 워크스페이스 ID 추가
      ),
    );
  }
}
