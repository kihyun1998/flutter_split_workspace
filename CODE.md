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
        │   ├── drag_data.dart
        │   └── tab_data.dart
        ├── theme/
        │   ├── split_workspace_color_scheme_theme.dart
        │   ├── split_workspace_scrollbar_theme.dart
        │   ├── split_workspace_tab_theme.dart
        │   └── split_workspace_theme.dart
        └── widgets/
        │   ├── tab_bar_widget.dart
        │   ├── tab_item_widget.dart
        │   └── tab_workspace.dart
    └── flutter_split_workspace.dart
```

## example/lib/main.dart
```dart
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
  SplitWorkspaceTheme _currentTheme =
      SplitWorkspaceTheme.defaultTheme; // 🆕 현재 테마

  // 🆕 커스텀 테마 정의
  final SplitWorkspaceTheme _customTheme = const SplitWorkspaceTheme(
    tab: SplitWorkspaceTabTheme(
      height: 40.0,
      width: 180.0,
      borderRadius: 12.0,
      showDragHandle: false,
      activeBackgroundColor: Colors.deepPurple,
      inactiveBackgroundColor: Colors.grey,
      activeTextColor: Colors.white,
      inactiveTextColor: Colors.black54,
    ),
    scrollbar: SplitWorkspaceScrollbarTheme(
      thickness: 12.0,
      radius: 6.0,
      alwaysVisible: true,
      trackVisible: true,
    ),
    backgroundColor: Colors.purple,
    borderColor: Colors.deepPurple,
    borderWidth: 2.0,
    borderRadius: 8.0,
  );

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
            '• 탭을 길게 눌러서 드래그하세요\n• 다른 위치에 드롭하여 순서를 변경하세요\n• + 버튼으로 새 탭을 추가하세요\n• X 버튼으로 탭을 닫으세요\n• 🎨 테마 버튼으로 스타일을 변경하세요',
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
      // 드래그한 탭을 제거
      final TabData draggedTab = tabs.removeAt(oldIndex);

      // 새 위치에 삽입 (더 간단한 로직)
      tabs.insert(newIndex, draggedTab);
    });

    print('🔄 Tab reordered: $oldIndex → $newIndex');
    print('🔄 Current tab order: ${tabs.map((t) => t.title).toList()}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Split Workspace - Theme Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // 🆕 테마 변경 버튼들
          PopupMenuButton<SplitWorkspaceTheme>(
            icon: const Icon(Icons.palette),
            onSelected: (theme) {
              setState(() {
                _currentTheme = theme;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: SplitWorkspaceTheme.defaultTheme,
                child: Text('Default Theme'),
              ),
              const PopupMenuItem(
                value: SplitWorkspaceTheme.dark,
                child: Text('Dark Theme'),
              ),
              const PopupMenuItem(
                value: SplitWorkspaceTheme.light,
                child: Text('Light Theme'),
              ),
              const PopupMenuItem(
                value: SplitWorkspaceTheme.minimal,
                child: Text('Minimal Theme'),
              ),
              const PopupMenuItem(
                value: SplitWorkspaceTheme.compact,
                child: Text('Compact Theme'),
              ),
              PopupMenuItem(
                value: _customTheme,
                child: const Text('Custom Theme'),
              ),
            ],
          ),
        ],
      ),
      body: TabWorkspace(
        tabs: tabs,
        activeTabId: activeTabId,
        onTabTap: _onTabTap,
        onTabClose: _onTabClose,
        onAddTab: _onAddTab,
        onTabReorder: _onTabReorder,
        workspaceId: 'main_workspace',
        theme: _currentTheme, // 🆕 테마 적용
      ),
    );
  }
}

```
## lib/flutter_split_workspace.dart
```dart
library;

export 'src/models/drag_data.dart';
export 'src/models/tab_data.dart';
export 'src/theme/split_workspace_color_scheme_theme.dart';
export 'src/theme/split_workspace_scrollbar_theme.dart';
export 'src/theme/split_workspace_tab_theme.dart';
export 'src/theme/split_workspace_theme.dart';
export 'src/widgets/tab_bar_widget.dart';
export 'src/widgets/tab_item_widget.dart';
export 'src/widgets/tab_workspace.dart';

```
## lib/src/models/drag_data.dart
```dart
// lib/src/models/drag_data.dart
import 'tab_data.dart';

/// 드래그 중인 탭의 정보를 담는 모델
class DragData {
  final TabData tab;
  final int originalIndex; // 원래 위치
  final String sourceWorkspaceId; // 어느 워크스페이스에서 왔는지

  const DragData({
    required this.tab,
    required this.originalIndex,
    required this.sourceWorkspaceId,
  });

  DragData copyWith({
    TabData? tab,
    int? originalIndex,
    String? sourceWorkspaceId,
  }) {
    return DragData(
      tab: tab ?? this.tab,
      originalIndex: originalIndex ?? this.originalIndex,
      sourceWorkspaceId: sourceWorkspaceId ?? this.sourceWorkspaceId,
    );
  }
}

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
## lib/src/theme/split_workspace_color_scheme_theme.dart
```dart
// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class SplitWorkspaceColorSchemeTheme {
  final Color primary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color background;
  final Color surface;
  final Color onSurface;
  final Color surfaceContainerHighest;
  final Color onSurfaceVariant;
  final Color outline;
  final Color dividerColor;

  const SplitWorkspaceColorSchemeTheme({
    this.primary = Colors.blueGrey,
    this.primaryContainer = Colors.blueGrey,
    this.onPrimaryContainer = Colors.white,
    this.background = Colors.white,
    this.surface = Colors.white,
    this.onSurface = Colors.black87,
    this.surfaceContainerHighest = Colors.black12,
    this.onSurfaceVariant = Colors.black54,
    this.outline = Colors.grey,
    this.dividerColor = Colors.black26,
  });

  SplitWorkspaceColorSchemeTheme copyWith({
    Color? primary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? background,
    Color? surface,
    Color? onSurface,
    Color? surfaceContainerHighest,
    Color? onSurfaceVariant,
    Color? outline,
    Color? dividerColor,
  }) {
    return SplitWorkspaceColorSchemeTheme(
      primary: primary ?? this.primary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      surfaceContainerHighest:
          surfaceContainerHighest ?? this.surfaceContainerHighest,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      outline: outline ?? this.outline,
      dividerColor: dividerColor ?? this.dividerColor,
    );
  }
}

```
## lib/src/theme/split_workspace_scrollbar_theme.dart
```dart
// lib/src/theme/scrollbar_theme.dart
import 'package:flutter/material.dart';

/// Configuration for scrollbar appearance and behavior
class SplitWorkspaceScrollbarTheme {
  /// Whether to show scrollbar
  final bool visible;

  /// Whether scrollbar is always visible (true) or only when scrolling (false)
  final bool alwaysVisible;

  /// Whether to show the scrollbar track
  final bool trackVisible;

  /// Thickness of the scrollbar in pixels
  final double thickness;

  /// Radius of the scrollbar corners
  final double radius;

  /// Color of the scrollbar thumb
  final Color? thumbColor;

  /// Color of the scrollbar track
  final Color? trackColor;

  /// Color of the scrollbar when hovered
  final Color? hoverColor;

  const SplitWorkspaceScrollbarTheme({
    this.visible = true,
    this.alwaysVisible = true,
    this.trackVisible = true,
    this.thickness = 8.0,
    this.radius = 4.0,
    this.thumbColor,
    this.trackColor,
    this.hoverColor,
  });

  /// Creates a copy of this theme with the given fields replaced
  SplitWorkspaceScrollbarTheme copyWith({
    bool? visible,
    bool? alwaysVisible,
    bool? trackVisible,
    double? thickness,
    double? radius,
    Color? thumbColor,
    Color? trackColor,
    Color? hoverColor,
  }) {
    return SplitWorkspaceScrollbarTheme(
      visible: visible ?? this.visible,
      alwaysVisible: alwaysVisible ?? this.alwaysVisible,
      trackVisible: trackVisible ?? this.trackVisible,
      thickness: thickness ?? this.thickness,
      radius: radius ?? this.radius,
      thumbColor: thumbColor ?? this.thumbColor,
      trackColor: trackColor ?? this.trackColor,
      hoverColor: hoverColor ?? this.hoverColor,
    );
  }

  /// Default scrollbar theme
  static const SplitWorkspaceScrollbarTheme defaultTheme =
      SplitWorkspaceScrollbarTheme();

  /// Hidden scrollbar theme (invisible scrollbar)
  static const SplitWorkspaceScrollbarTheme hidden =
      SplitWorkspaceScrollbarTheme(
        visible: false,
        alwaysVisible: false,
        trackVisible: false,
      );

  /// Minimal scrollbar theme (thin and subtle)
  static const SplitWorkspaceScrollbarTheme minimal =
      SplitWorkspaceScrollbarTheme(
        visible: true,
        alwaysVisible: false,
        trackVisible: false,
        thickness: 4.0,
        radius: 2.0,
      );
}

```
## lib/src/theme/split_workspace_tab_theme.dart
```dart
// ignore_for_file: public_member_api_docs, sort_constructors_first
// lib/src/theme/tab_theme.dart
import 'package:flutter/material.dart';

/// Configuration for tab appearance and dimensions
class SplitWorkspaceTabTheme {
  /// Height of the tab bar in pixels
  final double height;

  /// Width of each tab in pixels
  final double width;

  /// Minimum width constraint for tabs
  final double? minWidth;

  /// Maximum width constraint for tabs
  final double? maxWidth;

  /// Border radius for tab corners
  final double borderRadius;

  /// Background color for active tabs
  final Color? activeBackgroundColor;

  /// Background color for inactive tabs
  final Color? inactiveBackgroundColor;

  /// Text color for active tabs
  final Color? activeTextColor;

  /// Text color for inactive tabs
  final Color? inactiveTextColor;

  /// Border color for tabs
  final Color? borderColor;

  /// Text style for tab titles
  final TextStyle? textStyle;

  final TextStyle? inactiveTextStyle;

  /// Whether to show drag handle icons
  final bool showDragHandle;

  /// Size of the drag handle icon
  final double dragHandleSize;

  /// Size of the close button icon
  final double closeButtonSize;

  const SplitWorkspaceTabTheme({
    this.height = 36.0,
    this.width = 160.0,
    this.minWidth,
    this.maxWidth,
    this.borderRadius = 0.0,
    this.activeBackgroundColor,
    this.inactiveBackgroundColor,
    this.activeTextColor,
    this.inactiveTextColor,
    this.borderColor,
    this.textStyle,
    this.inactiveTextStyle,
    this.showDragHandle = true,
    this.dragHandleSize = 12.0,
    this.closeButtonSize = 16.0,
  });

  /// Creates a copy of this theme with the given fields replaced
  SplitWorkspaceTabTheme copyWith({
    double? height,
    double? width,
    double? minWidth,
    double? maxWidth,
    double? borderRadius,
    Color? activeBackgroundColor,
    Color? inactiveBackgroundColor,
    Color? activeTextColor,
    Color? inactiveTextColor,
    Color? borderColor,
    TextStyle? textStyle,
    TextStyle? inactiveTextStyle,
    bool? showDragHandle,
    double? dragHandleSize,
    double? closeButtonSize,
  }) {
    return SplitWorkspaceTabTheme(
      height: height ?? this.height,
      width: width ?? this.width,
      minWidth: minWidth ?? this.minWidth,
      maxWidth: maxWidth ?? this.maxWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      activeBackgroundColor:
          activeBackgroundColor ?? this.activeBackgroundColor,
      inactiveBackgroundColor:
          inactiveBackgroundColor ?? this.inactiveBackgroundColor,
      activeTextColor: activeTextColor ?? this.activeTextColor,
      inactiveTextColor: inactiveTextColor ?? this.inactiveTextColor,
      borderColor: borderColor ?? this.borderColor,
      textStyle: textStyle ?? this.textStyle,
      inactiveTextStyle: inactiveTextStyle ?? this.inactiveTextStyle,
      showDragHandle: showDragHandle ?? this.showDragHandle,
      dragHandleSize: dragHandleSize ?? this.dragHandleSize,
      closeButtonSize: closeButtonSize ?? this.closeButtonSize,
    );
  }

  /// Default tab theme
  static const SplitWorkspaceTabTheme defaultTheme = SplitWorkspaceTabTheme();

  /// Compact tab theme (smaller dimensions)
  static const SplitWorkspaceTabTheme compact = SplitWorkspaceTabTheme(
    height: 28.0,
    width: 120.0,
    dragHandleSize: 10.0,
    closeButtonSize: 14.0,
  );

  /// Rounded tab theme (with border radius)
  static const SplitWorkspaceTabTheme rounded = SplitWorkspaceTabTheme(
    borderRadius: 8.0,
  );
}

```
## lib/src/theme/split_workspace_theme.dart
```dart
// ignore_for_file: public_member_api_docs, sort_constructors_first
// lib/src/theme/split_workspace_theme.dart
import 'package:flutter/material.dart';

import 'split_workspace_color_scheme_theme.dart';
import 'split_workspace_scrollbar_theme.dart';
import 'split_workspace_tab_theme.dart';

/// Main theme configuration for the Split Workspace package
class SplitWorkspaceTheme {
  /// Theme configuration for tabs
  final SplitWorkspaceTabTheme tab;

  /// Theme configuration for scrollbars
  final SplitWorkspaceScrollbarTheme scrollbar;

  final SplitWorkspaceColorSchemeTheme colorScheme;

  /// Background color for the workspace
  final Color? backgroundColor;

  /// Border color for the workspace
  final Color borderColor;

  /// Border width for the workspace
  final double borderWidth;

  /// Border radius for the workspace
  final double borderRadius;

  const SplitWorkspaceTheme({
    this.tab = const SplitWorkspaceTabTheme(),
    this.scrollbar = const SplitWorkspaceScrollbarTheme(),
    this.colorScheme = const SplitWorkspaceColorSchemeTheme(),
    this.backgroundColor,
    this.borderColor = Colors.black,
    this.borderWidth = 1.0,
    this.borderRadius = 0.0,
  });

  /// Creates a copy of this theme with the given fields replaced
  SplitWorkspaceTheme copyWith({
    SplitWorkspaceTabTheme? tab,
    SplitWorkspaceScrollbarTheme? scrollbar,
    SplitWorkspaceColorSchemeTheme? colorScheme,
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    double? borderRadius,
  }) {
    return SplitWorkspaceTheme(
      tab: tab ?? this.tab,
      scrollbar: scrollbar ?? this.scrollbar,
      colorScheme: colorScheme ?? this.colorScheme,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  /// Default theme using Flutter's Material Design
  static const SplitWorkspaceTheme defaultTheme = SplitWorkspaceTheme();

  /// Dark theme preset
  static const SplitWorkspaceTheme dark = SplitWorkspaceTheme(
    tab: SplitWorkspaceTabTheme(
      activeBackgroundColor: Color(0xFF2D2D2D),
      inactiveBackgroundColor: Color(0xFF1E1E1E),
      activeTextColor: Colors.white,
      inactiveTextColor: Color(0xFFB3B3B3),
      borderColor: Color(0xFF404040),
    ),
    scrollbar: SplitWorkspaceScrollbarTheme(
      thickness: 6.0,
      thumbColor: Color(0xFF606060),
      trackColor: Color(0xFF2D2D2D),
    ),
    backgroundColor: Color(0xFF1E1E1E),
    borderColor: Color(0xFF404040),
  );

  /// Light theme preset
  static const SplitWorkspaceTheme light = SplitWorkspaceTheme(
    tab: SplitWorkspaceTabTheme(
      activeBackgroundColor: Colors.white,
      inactiveBackgroundColor: Color(0xFFF5F5F5),
      activeTextColor: Color(0xFF212121),
      inactiveTextColor: Color(0xFF757575),
      borderColor: Color(0xFFE0E0E0),
    ),
    scrollbar: SplitWorkspaceScrollbarTheme(
      thickness: 8.0,
      thumbColor: Color(0xFFBDBDBD),
      trackColor: Color(0xFFF5F5F5),
    ),
    backgroundColor: Colors.white,
    borderColor: Color(0xFFE0E0E0),
  );

  /// Minimal theme (clean and simple)
  static const SplitWorkspaceTheme minimal = SplitWorkspaceTheme(
    tab: SplitWorkspaceTabTheme(borderRadius: 4.0, showDragHandle: false),
    scrollbar: SplitWorkspaceScrollbarTheme.minimal,
    borderWidth: 0.0,
  );

  /// Compact theme (smaller dimensions)
  static const SplitWorkspaceTheme compact = SplitWorkspaceTheme(
    tab: SplitWorkspaceTabTheme.compact,
    scrollbar: SplitWorkspaceScrollbarTheme(thickness: 6.0, radius: 3.0),
  );
}

```
## lib/src/widgets/tab_bar_widget.dart
```dart
// lib/src/widgets/tab_bar_widget.dart (수정)
import 'package:flutter/material.dart';

import '../models/drag_data.dart';
import '../models/tab_data.dart';
import '../theme/split_workspace_tab_theme.dart';
import '../theme/split_workspace_theme.dart';
import 'tab_item_widget.dart';

class TabBarWidget extends StatefulWidget {
  final List<TabData> tabs;
  final String? activeTabId;
  final Function(String tabId)? onTabTap;
  final Function(String tabId)? onTabClose;
  final VoidCallback? onAddTab;
  final Function(int oldIndex, int newIndex)? onTabReorder;
  final String workspaceId;
  final SplitWorkspaceTheme? theme; // 🆕 테마 추가

  const TabBarWidget({
    super.key,
    required this.tabs,
    this.activeTabId,
    this.onTabTap,
    this.onTabClose,
    this.onAddTab,
    this.onTabReorder,
    required this.workspaceId,
    this.theme, // 🆕 테마 파라미터 추가
  });

  @override
  State<TabBarWidget> createState() => _TabBarWidgetState();
}

class _TabBarWidgetState extends State<TabBarWidget> {
  int? _dragOverIndex; // 드래그 오버 중인 인덱스
  bool _isDragging = false; // 드래그 중인지 여부
  final ScrollController _scrollController = ScrollController(); // 스크롤 컨트롤러 추가

  @override
  void dispose() {
    _scrollController.dispose(); // 메모리 누수 방지
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workspaceTheme = widget.theme ?? SplitWorkspaceTheme.defaultTheme;
    final tabTheme = workspaceTheme.tab;
    final scrollbarTheme = workspaceTheme.scrollbar;

    return Container(
      height: tabTheme.height,
      decoration: BoxDecoration(
        color: workspaceTheme.backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: workspaceTheme.borderColor,
            width: workspaceTheme.borderWidth,
          ),
        ),
      ),
      child: DragTarget<DragData>(
        onWillAcceptWithDetails: (details) {
          setState(() {
            _isDragging = true;
          });
          return true;
        },
        onLeave: (data) {
          setState(() {
            _isDragging = false;
            _dragOverIndex = null;
          });
        },
        onMove: (details) {
          _updateDragOverIndex(details.offset);
        },
        onAcceptWithDetails: (details) {
          _handleDrop(details.data);
          setState(() {
            _isDragging = false;
            _dragOverIndex = null;
          });
        },
        builder: (context, candidateData, rejectedData) {
          return Stack(
            children: [
              // 🆕 스크롤 가능한 탭바 레이아웃
              Row(
                children: [
                  // 스크롤 가능한 탭 영역
                  Expanded(
                    child: scrollbarTheme.visible
                        ? Scrollbar(
                            controller: _scrollController,
                            thumbVisibility: scrollbarTheme.alwaysVisible,
                            trackVisibility: scrollbarTheme.trackVisible,
                            thickness: scrollbarTheme.thickness,
                            radius: Radius.circular(scrollbarTheme.radius),
                            child: _buildScrollableTabRow(tabTheme),
                          )
                        : _buildScrollableTabRow(tabTheme),
                  ),

                  // 새 탭 추가 버튼 (항상 보임)
                  if (widget.onAddTab != null)
                    _buildAddTabButton(workspaceTheme),
                ],
              ),

              // 드래그 인디케이터
              if (_isDragging && _dragOverIndex != null)
                _buildDragIndicator(workspaceTheme),
            ],
          );
        },
      ),
    );
  }

  /// 스크롤 가능한 탭 Row 위젯
  Widget _buildScrollableTabRow(SplitWorkspaceTabTheme tabTheme) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: widget.tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;

          return TabItemWidget(
            tab: tab,
            isActive: tab.id == widget.activeTabId,
            onTap: () => widget.onTabTap?.call(tab.id),
            onClose: tab.closeable
                ? () => widget.onTabClose?.call(tab.id)
                : null,
            tabIndex: index,
            workspaceId: widget.workspaceId,
            theme: widget.theme, // 🆕 테마 전달
          );
        }).toList(),
      ),
    );
  }

  /// 새 탭 추가 버튼
  Widget _buildAddTabButton(SplitWorkspaceTheme workspaceTheme) {
    final tabTheme = workspaceTheme.tab;

    return Container(
      width: 36,
      height: tabTheme.height,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: workspaceTheme.borderColor,
            width: workspaceTheme.borderWidth,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onAddTab,
          child: Icon(Icons.add, size: 16, color: tabTheme.inactiveTextColor),
        ),
      ),
    );
  }

  /// 드래그 인디케이터 (세로선)
  Widget _buildDragIndicator(SplitWorkspaceTheme theme) {
    if (_dragOverIndex == null) return const SizedBox.shrink();

    // 실제 탭 너비 기반으로 인디케이터 위치 계산
    final tabWidth = _calculateTabWidth();
    final indicatorX = _dragOverIndex! * tabWidth;

    return Positioned(
      left: indicatorX,
      top: 0,
      child: Container(
        width: 3,
        height: 36,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(1.5),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }

  /// 드래그 오버 인덱스 업데이트
  void _updateDragOverIndex(Offset offset) {
    // 실제 렌더링된 위젯의 위치를 기반으로 계산
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    int newIndex = 0;
    double accumulatedWidth = 0;

    // 각 탭의 실제 위치를 계산하여 가장 가까운 인덱스 찾기
    for (int i = 0; i < widget.tabs.length; i++) {
      // 탭의 최소/최대 너비를 고려한 실제 너비 추정
      final tabWidth = _calculateTabWidth();
      final tabCenter = accumulatedWidth + (tabWidth / 2);

      if (offset.dx < tabCenter) {
        newIndex = i;
        break;
      }

      accumulatedWidth += tabWidth;
      newIndex = i + 1; // 마지막 탭 뒤쪽
    }

    // 범위 제한
    newIndex = newIndex.clamp(0, widget.tabs.length);

    if (newIndex != _dragOverIndex) {
      setState(() {
        _dragOverIndex = newIndex;
      });
    }
  }

  /// 탭 너비 계산 (constraints에 기반)
  double _calculateTabWidth() {
    // TabItemWidget의 constraints와 동일하게 계산
    final availableWidth = MediaQuery.of(context).size.width - 36 - 50; // 여유분
    final tabCount = widget.tabs.length;

    if (tabCount == 0) return 120.0;

    final calculatedWidth = availableWidth / tabCount;
    return calculatedWidth.clamp(120.0, 200.0); // TabItemWidget과 동일한 제약
  }

  /// 드롭 처리
  void _handleDrop(DragData dragData) {
    // 같은 워크스페이스 내에서의 순서 변경만 처리
    if (dragData.sourceWorkspaceId == widget.workspaceId &&
        _dragOverIndex != null) {
      final oldIndex = dragData.originalIndex;
      final newIndex = _dragOverIndex!;

      // 실제로 위치가 변경된 경우에만 콜백 호출
      if (oldIndex != newIndex) {
        widget.onTabReorder?.call(oldIndex, newIndex);
      }
    }

    // TODO: 다른 워크스페이스에서 온 탭 처리는 4단계에서 구현
  }
}

```
## lib/src/widgets/tab_item_widget.dart
```dart
// lib/src/widgets/tab_item_widget.dart (수정)
import 'package:flutter/material.dart';

import '../models/drag_data.dart';
import '../models/tab_data.dart';
import '../theme/split_workspace_theme.dart'; // SplitWorkspaceTheme 임포트

class TabItemWidget extends StatelessWidget {
  final TabData tab;
  final bool isActive;
  final VoidCallback? onTap;
  final VoidCallback? onClose;
  final int tabIndex;
  final String workspaceId;
  final SplitWorkspaceTheme? theme; // 🆕 테마 추가

  const TabItemWidget({
    super.key,
    required this.tab,
    required this.isActive,
    this.onTap,
    this.onClose,
    required this.tabIndex,
    required this.workspaceId,
    this.theme, // 🆕 테마 파라미터 추가
  });

  @override
  Widget build(BuildContext context) {
    // 널 안전성을 위해 기본 테마를 사용
    final workspaceTheme = theme ?? SplitWorkspaceTheme.defaultTheme;

    return LongPressDraggable<DragData>(
      // 드래그 데이터
      data: DragData(
        tab: tab,
        originalIndex: tabIndex,
        sourceWorkspaceId: workspaceId,
      ),

      // 드래그 시작 지연 (실수 방지)
      delay: const Duration(milliseconds: 200),

      // 드래그 중 표시될 위젯 (피드백)
      feedback: _buildDragFeedback(context, workspaceTheme),

      // 드래그 시작할 때 원본 위치에 표시될 위젯
      childWhenDragging: _buildDragPlaceholder(context, workspaceTheme),

      // 기본 상태의 탭
      child: _buildNormalTab(context, workspaceTheme),
    );
  }

  /// 일반 상태의 탭 위젯
  Widget _buildNormalTab(BuildContext context, SplitWorkspaceTheme theme) {
    return Container(
      height: 36,
      constraints: const BoxConstraints(minWidth: 120, maxWidth: 200),
      decoration: BoxDecoration(
        // 테마 색상 사용
        color: isActive
            ? theme.colorScheme.surface
            : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: Border(
          right: BorderSide(color: theme.colorScheme.dividerColor, width: 1),
        ), // 테마 색상 사용
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.only(left: 12, right: tab.closeable ? 4 : 12),
            child: Row(
              children: [
                // 드래그 핸들 아이콘
                Icon(
                  Icons.drag_indicator,
                  size: 12,
                  // 테마 색상 사용
                  color: isActive
                      ? theme.colorScheme.onSurface.withOpacity(0.7)
                      : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
                const SizedBox(width: 6),

                // 탭 제목
                Expanded(
                  child: Text(
                    tab.title,
                    // 테마 텍스트 스타일 사용
                    style: theme.tab.textStyle?.copyWith(
                      color: isActive
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // 닫기 버튼
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
                          // 테마 색상 사용
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

  /// 드래그 중 표시될 피드백 위젯
  Widget _buildDragFeedback(BuildContext context, SplitWorkspaceTheme theme) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 36,
        width: 160, // 고정 너비
        decoration: BoxDecoration(
          // 테마 색상 사용
          color: theme.colorScheme.primaryContainer.withOpacity(0.9),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            // 테마 색상 사용
            color: theme.colorScheme.primary.withOpacity(0.7),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(
                Icons.tab,
                size: 16,
                // 테마 색상 사용
                color: theme.colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tab.title,
                  // 테마 텍스트 스타일 사용
                  style: theme.tab.textStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 드래그 시작 시 원본 위치에 표시될 플레이스홀더
  Widget _buildDragPlaceholder(
    BuildContext context,
    SplitWorkspaceTheme theme,
  ) {
    return Container(
      height: 36,
      constraints: const BoxConstraints(minWidth: 120, maxWidth: 200),
      decoration: BoxDecoration(
        // 테마 색상 사용
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: Border(
          right: BorderSide(color: theme.colorScheme.dividerColor, width: 1),
        ), // 테마 색상 사용
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Container(
          width: 80,
          height: 2,
          decoration: BoxDecoration(
            // 테마 색상 사용
            color: theme.colorScheme.outline.withOpacity(0.5),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }
}

```
## lib/src/widgets/tab_workspace.dart
```dart
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
                          color: workspaceTheme.tab.inactiveTextColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No active tab',
                          style: workspaceTheme.tab.textStyle,
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
