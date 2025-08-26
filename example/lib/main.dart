// example/lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_split_workspace/flutter_split_workspace.dart';

void main() {
  runApp(const MyApp());
}

/// Theme type identifier for the dropdown menu
enum ThemeType {
  defaultTheme('Default'),
  dark('Dark'),
  light('Light'),
  minimal('Minimal'),
  compact('Compact'),
  highContrast('High Contrast'),
  custom('Custom');

  const ThemeType(this.displayName);
  final String displayName;
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
  ThemeType _currentThemeType = ThemeType.defaultTheme;

  /// Custom theme definition
  final SplitWorkspaceTheme _customTheme = const SplitWorkspaceTheme(
    colorScheme: SplitWorkspaceColorSchemeTheme(
      primary: Color(0xFF8B5CF6), // Violet
      primaryContainer: Color(0xFFDDD6FE),
      onPrimaryContainer: Color(0xFF1E1B4B),
      background: Color(0xFFF8FAFF),
      surface: Colors.white,
      onSurface: Color(0xFF1E1B4B),
      surfaceContainerHighest: Color(0xFFF1F5F9),
      onSurfaceVariant: Color(0xFF64748B),
      outline: Color(0xFFE2E8F0),
      dividerColor: Color(0xFFE2E8F0),
    ),
    tab: SplitWorkspaceTabTheme(
      height: 40.0,
      borderRadius: 12.0,
      showDragHandle: true,
      textStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    ),
    scrollbar: SplitWorkspaceScrollbarTheme(
      thickness: 10.0,
      radius: 5.0,
      alwaysVisible: true,
      trackVisible: true,
    ),
    borderWidth: 2.0,
    borderRadius: 12.0,
  );

  /// Returns the current theme based on selected type
  SplitWorkspaceTheme get _currentTheme {
    switch (_currentThemeType) {
      case ThemeType.defaultTheme:
        return SplitWorkspaceTheme.defaultTheme;
      case ThemeType.dark:
        return SplitWorkspaceTheme.dark;
      case ThemeType.light:
        return SplitWorkspaceTheme.light;
      case ThemeType.minimal:
        return SplitWorkspaceTheme.minimal;
      case ThemeType.compact:
        return SplitWorkspaceTheme.compact;
      case ThemeType.highContrast:
        return SplitWorkspaceTheme.highContrast;
      case ThemeType.custom:
        return _customTheme;
    }
  }

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
        title: 'Blue Theme Demo',
        content: _buildTabContent('Blue Theme Demo', Colors.blue),
      ),
      TabData(
        id: 'tab_3',
        title: 'Green Features',
        content: _buildTabContent('Green Features', Colors.green),
      ),
      TabData(
        id: 'tab_4',
        title: 'Orange Playground',
        content: _buildTabContent('Orange Playground', Colors.orange),
      ),
    ];
    activeTabId = 'tab_1';
    _tabCounter = 4;
  }

  Widget _buildWelcomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.workspace_premium,
            size: 80,
            color: Color(0xFF8B5CF6),
          ),
          const SizedBox(height: 20),
          const Text(
            'Flutter Split Workspace',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1B4B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Advanced Drag & Drop Tab System',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          _buildFeatureList(),
          const SizedBox(height: 32),
          _buildStatsCard(),
        ],
      ),
    );
  }

  Widget _buildFeatureList() {
    final features = [
      '🎯 Long-press and drag tabs to reorder',
      '🎨 Multiple built-in themes + custom themes',
      '📱 Responsive design with scrollable tabs',
      '⚡ Smooth animations and hover effects',
      '🔧 Fully customizable appearance',
      '♿ Accessibility support (High Contrast theme)',
    ];

    return Column(
      children: features
          .map(
            (feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(
                    feature.split(' ')[0],
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature.substring(feature.indexOf(' ') + 1),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Text(
            'Workspace Statistics',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total Tabs', '${tabs.length}'),
              _buildStatItem('Active Tab', activeTabId ?? 'None'),
              _buildStatItem('Current Theme', _currentThemeType.displayName),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B5CF6),
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent(String title, Color color) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(Icons.description, size: 64, color: color),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Content for $title',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                '👆 Try dragging the tabs above!',
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
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
    final colors = [
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ];
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

  /// Fixed tab reorder function with proper index validation
  void _onTabReorder(int oldIndex, int newIndex) {
    // 🔧 Critical fix: Validate indices before processing
    print(
      '🔧 Tab reorder requested: $oldIndex → $newIndex (total: ${tabs.length})',
    );

    // Ensure oldIndex is valid
    if (oldIndex < 0 || oldIndex >= tabs.length) {
      print(
        '❌ Invalid oldIndex: $oldIndex (valid range: 0-${tabs.length - 1})',
      );
      return;
    }

    // 🔧 Key fix: Adjust newIndex for same-list reordering
    // When moving within the same list, after removing the item,
    // the insertion index needs adjustment if it's after the removed item
    int adjustedNewIndex = newIndex;

    // If newIndex is after the oldIndex, we need to subtract 1
    // because the item will be removed first, shifting indices down
    if (newIndex > oldIndex) {
      adjustedNewIndex = newIndex - 1;
    }

    // Clamp the adjusted index to valid range
    adjustedNewIndex = adjustedNewIndex.clamp(0, tabs.length - 1);

    print('🔧 Adjusted newIndex: $newIndex → $adjustedNewIndex');

    // Only proceed if there's an actual position change
    if (oldIndex == adjustedNewIndex) {
      print('🔧 No position change needed, skipping reorder');
      return;
    }

    setState(() {
      // Remove the dragged tab
      final TabData draggedTab = tabs.removeAt(oldIndex);
      // Insert at the adjusted position
      tabs.insert(adjustedNewIndex, draggedTab);
    });

    print('✅ Tab reordered successfully: ${tabs.map((t) => t.title).toList()}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Flutter Split Workspace Demo',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        actions: [
          // Theme selector dropdown
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: PopupMenuButton<ThemeType>(
              icon: const Icon(Icons.palette_outlined),
              tooltip: 'Select Theme',
              onSelected: (themeType) {
                setState(() {
                  _currentThemeType = themeType;
                });
              },
              itemBuilder: (context) => ThemeType.values.map((themeType) {
                return PopupMenuItem(
                  value: themeType,
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: _getThemePreviewColor(themeType),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(themeType.displayName),
                      if (_currentThemeType == themeType) ...[
                        const Spacer(),
                        const Icon(Icons.check, size: 16),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TabWorkspace(
          tabs: tabs,
          activeTabId: activeTabId,
          onTabTap: _onTabTap,
          onTabClose: _onTabClose,
          onAddTab: _onAddTab,
          onTabReorder: _onTabReorder,
          workspaceId: 'main_workspace',
          theme: _currentTheme,
        ),
      ),
    );
  }

  Color _getThemePreviewColor(ThemeType themeType) {
    switch (themeType) {
      case ThemeType.defaultTheme:
        return Colors.blueGrey;
      case ThemeType.dark:
        return const Color(0xFF121212);
      case ThemeType.light:
        return Colors.white;
      case ThemeType.minimal:
        return const Color(0xFF6366F1);
      case ThemeType.compact:
        return const Color(0xFF059669);
      case ThemeType.highContrast:
        return Colors.black;
      case ThemeType.custom:
        return const Color(0xFF8B5CF6);
    }
  }
}
