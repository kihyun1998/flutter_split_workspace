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
  SplitPanel workspace = SplitPanel.singleGroup(
    id: 'root',
    tabs: [],
    activeTabId: null,
  );
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
      width: 200,
      borderRadius: 12.0,
      showDragHandle: true,
      textStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    ),
    scrollbar: SplitWorkspaceScrollbarTheme(
      thickness: 3.0,
      radius: 5.0,
      alwaysVisible: false,
      trackVisible: false,
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
    final initialTabs = [
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

    workspace = SplitPanel.singleGroup(
      id: 'root',
      tabs: initialTabs,
      activeTabId: 'tab_1',
    );
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
              _buildStatItem('Total Tabs', '${workspace.tabCount}'),
              _buildStatItem('Active Tab', workspace.activeTabId ?? 'None'),
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
      workspace = TabService.activateTab(workspace, tabId);
    });
  }

  void _onTabClose(String tabId) {
    setState(() {
      final result = TabService.removeTabWithEmptyCheck(workspace, tabId);
      workspace = result.newState;

      // If root became empty, reset to initial state
      if (result.rootBecameEmpty) {
        workspace = SplitPanel.singleGroup(
          id: 'root',
          tabs: [],
          activeTabId: null,
        );
      }
    });
  }

  void _onTabReorder(String groupId, int oldIndex, int newIndex) {
    setState(() {
      // Find the group
      final group = WorkspaceHelpers.findGroupById(workspace, groupId);
      if (group == null ||
          group.tabs == null ||
          oldIndex >= group.tabs!.length) {
        return;
      }

      // Get the tab at oldIndex in this group
      final tabId = group.tabs![oldIndex].id;

      // Reorder using service
      workspace = TabService.reorderTab(workspace, tabId, newIndex);
    });
  }

  void _onTabMoveToGroup(String tabId, String targetGroupId, int insertIndex) {
    setState(() {
      final result = SplitService.moveTabToGroupWithEmptyCheck(
        workspace,
        tabId: tabId,
        targetGroupId: targetGroupId,
        insertIndex: insertIndex,
      );

      workspace = result.newState;

      // Clean up empty group if needed
      if (result.emptyGroupId != null) {
        workspace = SplitService.removeEmptyGroup(
          workspace,
          result.emptyGroupId!,
        );
      }
    });
  }

  void _onSplitRequest(String sourceTabId, String targetGroupId, DropZoneType dropZone) {
    setState(() {
      final result = SplitService.createSplitWithResult(
        workspace,
        sourceTabId: sourceTabId,
        dropZone: dropZone,
        targetGroupId: targetGroupId,
      );

      workspace = result.newState;

      // Clean up empty group if needed
      if (result.needsEmptyGroupCleanup && result.emptyGroupId != null) {
        workspace = SplitService.removeEmptyGroup(
          workspace,
          result.emptyGroupId!,
        );
      }
    });
  }

  void _onAddTabToGroup(String groupId) {
    setState(() {
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

      workspace = TabService.addTabToGroup(
        workspace,
        groupId,
        title: 'New Tab $_tabCounter',
        content: _buildTabContent('New Tab $_tabCounter', color),
        makeActive: true,
      );
    });
  }

  void _testSplitLeft() {
    setState(() {
      // Split the first tab to the left
      if (workspace.tabs != null && workspace.tabs!.isNotEmpty) {
        final result = SplitService.createSplitWithResult(
          workspace,
          sourceTabId: workspace.tabs!.first.id,
          dropZone: DropZoneType.splitLeft,
        );

        workspace = result.newState;

        // Clean up if needed
        if (result.needsEmptyGroupCleanup && result.emptyGroupId != null) {
          workspace = SplitService.removeEmptyGroup(
            workspace,
            result.emptyGroupId!,
          );
        }
      }
    });
  }

  void _testSplitTop() {
    setState(() {
      // Split the first tab to the top
      if (workspace.tabs != null && workspace.tabs!.isNotEmpty) {
        final result = SplitService.createSplitWithResult(
          workspace,
          sourceTabId: workspace.tabs!.first.id,
          dropZone: DropZoneType.splitTop,
        );

        workspace = result.newState;

        // Clean up if needed
        if (result.needsEmptyGroupCleanup && result.emptyGroupId != null) {
          workspace = SplitService.removeEmptyGroup(
            workspace,
            result.emptyGroupId!,
          );
        }
      }
    });
  }

  void _resetWorkspace() {
    setState(() {
      _initializeTabs();
    });
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
      body: Column(
        children: [
          // Test buttons
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[200],
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _testSplitLeft,
                  icon: const Icon(Icons.view_sidebar, size: 16),
                  label: const Text('Split Left'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _testSplitTop,
                  icon: const Icon(Icons.horizontal_split, size: 16),
                  label: const Text('Split Top'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _resetWorkspace,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Groups: ${WorkspaceHelpers.countGroups(workspace)} | Tabs: ${WorkspaceHelpers.countTabs(workspace)}',
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ],
            ),
          ),

          // Workspace
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SplitWorkspace(
                workspace: workspace,
                onTabTap: _onTabTap,
                onTabClose: _onTabClose,
                onAddTab: (groupId) => _onAddTabToGroup(groupId),
                onTabReorder: _onTabReorder,
                onTabMoveToGroup: _onTabMoveToGroup,
                onSplitRequest: _onSplitRequest,
                workspaceId: 'main_workspace',
                theme: _currentTheme,
              ),
            ),
          ),
        ],
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
