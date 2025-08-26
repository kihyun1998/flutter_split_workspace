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
// example/lib/main.dart (개선된 버전)
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

  void _onTabReorder(int oldIndex, int newIndex) {
    setState(() {
      final TabData draggedTab = tabs.removeAt(oldIndex);
      tabs.insert(newIndex, draggedTab);
    });

    print('🔄 Tab reordered: $oldIndex → $newIndex');
    print('🔄 Current order: ${tabs.map((t) => t.title).toList()}');
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
import 'tab_data.dart';

/// Data model containing information about a tab being dragged.
///
/// This model is used internally by the drag and drop system to track
/// which tab is being moved, where it came from, and where it should
/// be placed. It enables tabs to be reordered within a workspace or
/// potentially moved between different workspaces in the future.
///
/// This class is primarily used by [TabItemWidget] when creating
/// draggable tabs and by [TabBarWidget] when handling drop operations.
class DragData {
  /// The tab data being dragged.
  ///
  /// Contains all the information about the tab including its ID,
  /// title, content, and whether it can be closed.
  final TabData tab;

  /// Original index position of the tab before dragging started.
  ///
  /// This is used to restore the tab to its original position
  /// if the drag operation is cancelled or fails.
  final int originalIndex;

  /// Identifier of the workspace where the drag originated.
  ///
  /// Used to track which workspace the tab came from, enabling
  /// future support for moving tabs between different workspaces.
  /// Currently used for validation and debugging purposes.
  final String sourceWorkspaceId;

  /// Creates a new drag data instance.
  ///
  /// All parameters are required as they're essential for tracking
  /// the drag operation and enabling proper tab reordering.
  const DragData({
    required this.tab,
    required this.originalIndex,
    required this.sourceWorkspaceId,
  });

  /// Creates a copy of this drag data with some properties replaced.
  ///
  /// This method is useful during drag operations when some aspects
  /// of the drag data need to be updated while preserving others.
  ///
  /// Example:
  /// ```dart
  /// final updatedDragData = originalDragData.copyWith(
  ///   originalIndex: newIndex,
  /// );
  /// ```
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

/// Data model representing a single tab in the workspace.
///
/// Each tab contains metadata and content that can be displayed
/// in a [TabWorkspace]. Tabs can be reordered via drag and drop,
/// and optionally closed by the user.
///
/// Example usage:
/// ```dart
/// final tab = TabData(
///   id: 'unique_tab_1',
///   title: 'My Document',
///   content: Text('Tab content goes here'),
///   closeable: true,
/// );
/// ```
class TabData {
  /// Unique identifier for this tab.
  ///
  /// This ID is used to track the tab across reordering operations
  /// and to determine which tab is currently active.
  final String id;

  /// Display title shown in the tab bar.
  ///
  /// This text appears on the tab button and should be concise
  /// and descriptive of the tab's content.
  final String title;

  /// Widget content displayed when this tab is active.
  ///
  /// Can be null if the tab serves as a placeholder or
  /// if content is loaded dynamically elsewhere.
  final Widget? content;

  /// Whether this tab can be closed by the user.
  ///
  /// When `true`, a close button (×) will appear on the tab.
  /// When `false`, the tab cannot be closed and no close button is shown.
  /// Defaults to `true`.
  final bool closeable;

  /// Creates a new tab data instance.
  ///
  /// The [id] and [title] parameters are required.
  /// The [content] can be null for tabs without immediate content.
  /// The [closeable] parameter defaults to `true`.
  const TabData({
    required this.id,
    required this.title,
    this.content,
    this.closeable = true,
  });

  /// Creates a copy of this tab with some properties replaced.
  ///
  /// This method is useful for updating tab properties without
  /// creating a completely new instance, preserving other values.
  ///
  /// Example:
  /// ```dart
  /// final updatedTab = originalTab.copyWith(
  ///   title: 'New Title',
  ///   closeable: false,
  /// );
  /// ```
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
import 'package:flutter/material.dart';

/// Centralized color scheme for consistent theming across the workspace.
///
/// This color scheme follows Material Design 3 principles and provides
/// a cohesive color system for all workspace components. It acts as the
/// foundation for theming tabs, backgrounds, borders, and text elements.
///
/// The color scheme integrates with [SplitWorkspaceTheme] to provide
/// automatic color resolution when component-specific colors are not defined.
///
/// Example usage:
/// ```dart
/// const colorScheme = SplitWorkspaceColorSchemeTheme(
///   primary: Colors.blue,
///   background: Colors.white,
///   surface: Color(0xFFF5F5F5),
/// );
/// ```
class SplitWorkspaceColorSchemeTheme {
  /// Primary color used for active elements and highlights.
  ///
  /// Applied to active tab indicators, buttons, and focus states.
  /// Should provide good contrast against [primaryContainer].
  final Color primary;

  /// Container color for primary elements.
  ///
  /// Used for active tab backgrounds, button backgrounds,
  /// and other primary element containers.
  final Color primaryContainer;

  /// Text/icon color used on [primaryContainer] backgrounds.
  ///
  /// Must provide sufficient contrast against [primaryContainer]
  /// for accessibility compliance.
  final Color onPrimaryContainer;

  /// Main background color of the workspace.
  ///
  /// Used as the default background for the entire workspace
  /// when no specific background color is provided.
  final Color background;

  /// Surface color for content areas.
  ///
  /// Applied to tab content areas, panels, and other surface elements.
  /// Should be lighter than [background] in light themes.
  final Color surface;

  /// Primary text/icon color used on [surface] backgrounds.
  ///
  /// Used for tab titles, content text, and icons that appear
  /// on surface elements.
  final Color onSurface;

  /// Color for elevated surface elements.
  ///
  /// Used for inactive tab backgrounds, hover states, and
  /// subtle elevated elements. Should be between [surface] and [background].
  final Color surfaceContainerHighest;

  /// Secondary text/icon color for less prominent elements.
  ///
  /// Applied to placeholder text, secondary labels, and disabled elements.
  /// Should have lower contrast than [onSurface] for hierarchy.
  final Color onSurfaceVariant;

  /// Border and outline color.
  ///
  /// Used for tab borders, workspace borders, focus rings,
  /// and other structural elements that need definition.
  final Color outline;

  /// Color for dividers and separators.
  ///
  /// Applied to visual separators between tabs, content sections,
  /// and other UI divisions. Usually lighter than [outline].
  final Color dividerColor;

  /// Creates a color scheme with default Material Design colors.
  ///
  /// All colors have sensible defaults that work well together,
  /// but can be customized for specific brand or design requirements.
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

  /// Creates a copy of this color scheme with some colors replaced.
  ///
  /// This method allows for easy customization of specific colors
  /// while maintaining the coherence of the overall color scheme.
  ///
  /// Example:
  /// ```dart
  /// final customColorScheme = baseColorScheme.copyWith(
  ///   primary: Colors.purple,
  ///   primaryContainer: Colors.purple.shade100,
  /// );
  /// ```
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
import 'package:flutter/material.dart';

/// Theme configuration for scrollbars in the workspace tab system.
///
/// Controls the appearance and behavior of scrollbars that appear when
/// the tab bar content exceeds the available horizontal space and
/// horizontal scrolling is needed.
///
/// When colors are not specified, they fallback to the workspace's
/// [SplitWorkspaceColorSchemeTheme] for consistent theming.
///
/// Example usage:
/// ```dart
/// const scrollbarTheme = SplitWorkspaceScrollbarTheme(
///   thickness: 6.0,
///   alwaysVisible: true,
///   trackVisible: true,
/// );
/// ```
class SplitWorkspaceScrollbarTheme {
  /// Whether to show the scrollbar at all.
  ///
  /// When false, no scrollbar will be displayed even if content
  /// is scrollable. Set to true to enable scrollbar functionality.
  final bool visible;

  /// Whether the scrollbar is always visible or appears only during scrolling.
  ///
  /// When true, the scrollbar thumb is permanently visible.
  /// When false, it appears only when scrolling is active and fades out
  /// after a period of inactivity for a cleaner appearance.
  final bool alwaysVisible;

  /// Whether to show the scrollbar track (background).
  ///
  /// When true, displays a background track that shows the full scrollable
  /// area. When false, only the thumb (draggable indicator) is visible
  /// for a more minimal appearance.
  final bool trackVisible;

  /// Thickness of the scrollbar in pixels.
  ///
  /// Determines how wide the scrollbar appears. Larger values make it
  /// easier to target with the cursor but take up more screen space.
  final double thickness;

  /// Border radius for rounded scrollbar corners in pixels.
  ///
  /// Applied to both the thumb and track elements when visible.
  /// Set to 0.0 for square corners or a positive value for rounded edges.
  final double radius;

  /// Color of the scrollbar thumb (the draggable part).
  ///
  /// When null, uses [SplitWorkspaceColorSchemeTheme.onSurfaceVariant]
  /// with reduced opacity for automatic color scheme integration.
  final Color? thumbColor;

  /// Color of the scrollbar track (background area).
  ///
  /// When null, uses [SplitWorkspaceColorSchemeTheme.surfaceContainerHighest]
  /// for automatic color scheme integration.
  final Color? trackColor;

  /// Color of the scrollbar when hovered with the mouse.
  ///
  /// When null, uses a lighter variant of [thumbColor] or the
  /// color scheme's hover color for interactive feedback.
  final Color? hoverColor;

  /// Creates a scrollbar theme with configurable appearance options.
  ///
  /// All parameters have defaults optimized for a clean, modern
  /// scrollbar appearance that works well in most contexts.
  const SplitWorkspaceScrollbarTheme({
    this.visible = true,
    this.alwaysVisible = false,
    this.trackVisible = false,
    this.thickness = 8.0,
    this.radius = 4.0,
    this.thumbColor,
    this.trackColor,
    this.hoverColor,
  });

  /// Creates a copy of this scrollbar theme with some properties replaced.
  ///
  /// This method allows for easy customization of specific scrollbar
  /// properties while preserving the rest of the theme configuration.
  ///
  /// Example:
  /// ```dart
  /// final customScrollbarTheme = SplitWorkspaceScrollbarTheme.defaultTheme.copyWith(
  ///   thickness: 12.0,
  ///   alwaysVisible: true,
  ///   trackVisible: true,
  /// );
  /// ```
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

  /// Default scrollbar theme with balanced visibility and sizing.
  ///
  /// Provides a clean appearance that shows during scrolling but fades
  /// when not in use, with medium thickness suitable for most interfaces.
  static const SplitWorkspaceScrollbarTheme defaultTheme =
      SplitWorkspaceScrollbarTheme();

  /// Hidden scrollbar theme that completely disables scrollbar display.
  ///
  /// Useful when you want scrolling functionality without visual indicators,
  /// creating a completely clean interface.
  static const SplitWorkspaceScrollbarTheme hidden =
      SplitWorkspaceScrollbarTheme(
        visible: false,
        alwaysVisible: false,
        trackVisible: false,
      );

  /// Minimal scrollbar theme optimized for subtle, unobtrusive scrolling.
  ///
  /// Features a thin scrollbar that appears only when needed,
  /// perfect for interfaces where screen space is at a premium.
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
import 'package:flutter/material.dart';

/// Theme configuration for individual tabs within the workspace.
///
/// This theme controls the visual appearance and dimensions of tabs,
/// including colors, sizes, text styles, and interactive elements.
/// When colors are not specified, they fallback to the workspace's
/// [SplitWorkspaceColorSchemeTheme] for consistent theming.
///
/// Example usage:
/// ```dart
/// const tabTheme = SplitWorkspaceTabTheme(
///   height: 40.0,
///   borderRadius: 8.0,
///   showDragHandle: true,
///   textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
/// );
/// ```
class SplitWorkspaceTabTheme {
  /// Height of the tab bar in pixels.
  ///
  /// This determines the overall vertical space occupied by the tab bar.
  /// Defaults to 36.0 pixels, providing comfortable touch targets
  /// while maintaining a compact appearance.
  final double height;

  /// Preferred width of each tab in pixels.
  ///
  /// Individual tabs will attempt to use this width, but may be
  /// constrained by [minWidth] and [maxWidth] limits, or adjusted
  /// to fit the available horizontal space.
  final double width;

  /// Minimum width constraint for tabs in pixels.
  ///
  /// Prevents tabs from becoming too narrow to be usable.
  /// When null, no minimum constraint is applied.
  final double? minWidth;

  /// Maximum width constraint for tabs in pixels.
  ///
  /// Prevents tabs from becoming excessively wide with long titles.
  /// When null, no maximum constraint is applied.
  final double? maxWidth;

  /// Border radius for rounded tab corners in pixels.
  ///
  /// Applied to the top corners of tabs. Set to 0.0 for square tabs
  /// or a positive value for rounded corners. Defaults to 0.0.
  final double borderRadius;

  /// Background color for active (selected) tabs.
  ///
  /// When null, uses [SplitWorkspaceColorSchemeTheme.surface] for
  /// automatic color scheme integration.
  final Color? activeBackgroundColor;

  /// Background color for inactive (unselected) tabs.
  ///
  /// When null, uses [SplitWorkspaceColorSchemeTheme.surfaceContainerHighest]
  /// for automatic color scheme integration.
  final Color? inactiveBackgroundColor;

  /// Text color for active tab titles.
  ///
  /// When null, uses [SplitWorkspaceColorSchemeTheme.onSurface]
  /// for automatic color scheme integration.
  final Color? activeTextColor;

  /// Text color for inactive tab titles.
  ///
  /// When null, uses [SplitWorkspaceColorSchemeTheme.onSurfaceVariant]
  /// for automatic color scheme integration with reduced emphasis.
  final Color? inactiveTextColor;

  /// Border color for tab outlines.
  ///
  /// When null, uses [SplitWorkspaceColorSchemeTheme.outline]
  /// for automatic color scheme integration.
  final Color? borderColor;

  /// Text style for active tab titles.
  ///
  /// Defines font size, weight, and other text properties for
  /// the currently selected tab. When null, uses a default style
  /// that works well with the tab dimensions.
  final TextStyle? textStyle;

  /// Text style for inactive tab titles.
  ///
  /// Defines font size, weight, and other text properties for
  /// unselected tabs. When null, uses [textStyle] as the base
  /// with appropriate color adjustments.
  final TextStyle? inactiveTextStyle;

  /// Whether to show drag handle icons on tabs.
  ///
  /// When true, displays a grip icon (⋮⋮) that indicates tabs can be
  /// dragged for reordering. Set to false for a cleaner appearance
  /// if drag functionality is not needed or obvious from context.
  final bool showDragHandle;

  /// Size of the drag handle icon in pixels.
  ///
  /// Controls the visual size of the drag indicator icon.
  /// Should be proportional to the tab height for good visual balance.
  final double dragHandleSize;

  /// Size of the close button icon in pixels.
  ///
  /// Controls the size of the × button that appears on closeable tabs.
  /// Should be large enough for easy clicking but not overwhelming
  /// relative to the tab content.
  final double closeButtonSize;

  /// Creates a tab theme with default values.
  ///
  /// All parameters are optional and have sensible defaults suitable
  /// for most use cases. Customize specific properties as needed for
  /// your design requirements.
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

  /// Creates a copy of this tab theme with some properties replaced.
  ///
  /// This method allows for easy customization of specific tab properties
  /// while preserving the rest of the theme configuration.
  ///
  /// Example:
  /// ```dart
  /// final customTabTheme = SplitWorkspaceTabTheme.defaultTheme.copyWith(
  ///   height: 40.0,
  ///   borderRadius: 12.0,
  ///   showDragHandle: false,
  /// );
  /// ```
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

  /// Standard tab theme with default dimensions and styling.
  ///
  /// Provides a balanced appearance suitable for most applications
  /// with comfortable touch targets and readable text.
  static const SplitWorkspaceTabTheme defaultTheme = SplitWorkspaceTabTheme();

  /// Compact tab theme optimized for space-constrained layouts.
  ///
  /// Uses smaller dimensions to fit more tabs in limited horizontal
  /// space while maintaining usability.
  static const SplitWorkspaceTabTheme compact = SplitWorkspaceTabTheme(
    height: 28.0,
    width: 120.0,
    dragHandleSize: 10.0,
    closeButtonSize: 14.0,
  );

  /// Rounded tab theme with curved corners for a softer appearance.
  ///
  /// Applies border radius to create rounded tab corners while
  /// maintaining all other default styling properties.
  static const SplitWorkspaceTabTheme rounded = SplitWorkspaceTabTheme(
    borderRadius: 8.0,
  );
}

```
## lib/src/theme/split_workspace_theme.dart
```dart
// lib/src/theme/split_workspace_theme.dart (수정)
import 'package:flutter/material.dart';

import 'split_workspace_color_scheme_theme.dart';
import 'split_workspace_scrollbar_theme.dart';
import 'split_workspace_tab_theme.dart';

/// Main theme configuration for the Split Workspace package
///
/// This theme system provides a cohesive way to style the entire workspace
/// by using a centralized color scheme and individual component themes.
class SplitWorkspaceTheme {
  /// Theme configuration for tabs
  final SplitWorkspaceTabTheme tab;

  /// Theme configuration for scrollbars
  final SplitWorkspaceScrollbarTheme scrollbar;

  /// Centralized color scheme for consistent theming
  final SplitWorkspaceColorSchemeTheme colorScheme;

  /// Background color for the workspace
  /// If null, uses colorScheme.background
  final Color? backgroundColor;

  /// Border color for the workspace
  /// If null, uses colorScheme.outline
  final Color? borderColor;

  /// Border width for the workspace
  final double borderWidth;

  /// Border radius for the workspace
  final double borderRadius;

  const SplitWorkspaceTheme({
    this.tab = const SplitWorkspaceTabTheme(),
    this.scrollbar = const SplitWorkspaceScrollbarTheme(),
    this.colorScheme = const SplitWorkspaceColorSchemeTheme(),
    this.backgroundColor,
    this.borderColor,
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

  /// Effective background color (fallback to colorScheme if null)
  Color get effectiveBackgroundColor =>
      backgroundColor ?? colorScheme.background;

  /// Effective border color (fallback to colorScheme if null)
  Color get effectiveBorderColor => borderColor ?? colorScheme.outline;

  /// Default theme using Flutter's Material Design
  static const SplitWorkspaceTheme defaultTheme = SplitWorkspaceTheme(
    colorScheme: SplitWorkspaceColorSchemeTheme(),
    tab: SplitWorkspaceTabTheme(),
    scrollbar: SplitWorkspaceScrollbarTheme(),
  );

  /// Dark theme preset with coordinated color scheme
  static const SplitWorkspaceTheme dark = SplitWorkspaceTheme(
    colorScheme: SplitWorkspaceColorSchemeTheme(
      primary: Color(0xFFBB86FC),
      primaryContainer: Color(0xFF3700B3),
      onPrimaryContainer: Colors.white,
      background: Color(0xFF121212),
      surface: Color(0xFF1E1E1E),
      onSurface: Color(0xFFE1E1E1),
      surfaceContainerHighest: Color(0xFF2D2D2D),
      onSurfaceVariant: Color(0xFFB3B3B3),
      outline: Color(0xFF404040),
      dividerColor: Color(0xFF404040),
    ),
    tab: SplitWorkspaceTabTheme(
      // Colors will be derived from colorScheme in widgets
      textStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
    ),
    scrollbar: SplitWorkspaceScrollbarTheme(
      thickness: 6.0,
      // Colors will be derived from colorScheme in widgets
    ),
  );

  /// Light theme preset with coordinated color scheme
  static const SplitWorkspaceTheme light = SplitWorkspaceTheme(
    colorScheme: SplitWorkspaceColorSchemeTheme(
      primary: Color(0xFF6200EE),
      primaryContainer: Color(0xFFBB86FC),
      onPrimaryContainer: Color(0xFF000000),
      background: Color(0xFFFFFBFE),
      surface: Colors.white,
      onSurface: Color(0xFF1C1B1F),
      surfaceContainerHighest: Color(0xFFF5F5F5),
      onSurfaceVariant: Color(0xFF757575),
      outline: Color(0xFFE0E0E0),
      dividerColor: Color(0xFFE0E0E0),
    ),
    tab: SplitWorkspaceTabTheme(
      textStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
    ),
    scrollbar: SplitWorkspaceScrollbarTheme(thickness: 8.0),
  );

  /// Minimal theme (clean and simple) with subtle colors
  static const SplitWorkspaceTheme minimal = SplitWorkspaceTheme(
    colorScheme: SplitWorkspaceColorSchemeTheme(
      primary: Color(0xFF6366F1),
      primaryContainer: Color(0xFFEEF2FF),
      onPrimaryContainer: Color(0xFF1E1B4B),
      background: Color(0xFFFAFAFA),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF111827),
      surfaceContainerHighest: Color(0xFFF9FAFB),
      onSurfaceVariant: Color(0xFF6B7280),
      outline: Color(0xFFE5E7EB),
      dividerColor: Color(0xFFE5E7EB),
    ),
    tab: SplitWorkspaceTabTheme(
      borderRadius: 4.0,
      showDragHandle: false,
      textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    ),
    scrollbar: SplitWorkspaceScrollbarTheme.minimal,
    borderWidth: 0.0,
  );

  /// Compact theme (smaller dimensions) with efficient use of space
  static const SplitWorkspaceTheme compact = SplitWorkspaceTheme(
    colorScheme: SplitWorkspaceColorSchemeTheme(
      primary: Color(0xFF059669),
      primaryContainer: Color(0xFFD1FAE5),
      onPrimaryContainer: Color(0xFF064E3B),
      background: Color(0xFFF8FAFC),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF0F172A),
      surfaceContainerHighest: Color(0xFFF1F5F9),
      onSurfaceVariant: Color(0xFF64748B),
      outline: Color(0xFFCBD5E1),
      dividerColor: Color(0xFFE2E8F0),
    ),
    tab: SplitWorkspaceTabTheme.compact,
    scrollbar: SplitWorkspaceScrollbarTheme(thickness: 6.0, radius: 3.0),
  );

  /// High contrast theme for accessibility
  static const SplitWorkspaceTheme highContrast = SplitWorkspaceTheme(
    colorScheme: SplitWorkspaceColorSchemeTheme(
      primary: Color(0xFF000000),
      primaryContainer: Color(0xFF000000),
      onPrimaryContainer: Color(0xFFFFFFFF),
      background: Color(0xFFFFFFFF),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF000000),
      surfaceContainerHighest: Color(0xFFF0F0F0),
      onSurfaceVariant: Color(0xFF333333),
      outline: Color(0xFF000000),
      dividerColor: Color(0xFF000000),
    ),
    tab: SplitWorkspaceTabTheme(
      borderRadius: 0,
      textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    ),
    scrollbar: SplitWorkspaceScrollbarTheme(
      thickness: 10.0,
      alwaysVisible: true,
      trackVisible: true,
    ),
    borderWidth: 2.0,
  );
}

```
## lib/src/widgets/tab_bar_widget.dart
```dart
// lib/src/widgets/tab_bar_widget.dart (스크롤바 색상 수정)
import 'package:flutter/material.dart';

import '../models/drag_data.dart';
import '../models/tab_data.dart';
import '../theme/split_workspace_tab_theme.dart';
import '../theme/split_workspace_theme.dart';
import 'tab_item_widget.dart';

/// Tab bar widget that displays multiple tabs with drag and drop support
///
/// This widget handles:
/// - Horizontal scrolling of tabs
/// - Drag and drop reordering
/// - Drop zone indicators
/// - Add new tab functionality
/// - Theme integration with colorScheme
class TabBarWidget extends StatefulWidget {
  /// List of tabs to display
  final List<TabData> tabs;

  /// Currently active tab ID
  final String? activeTabId;

  /// Callback when a tab is tapped
  final Function(String tabId)? onTabTap;

  /// Callback when a tab's close button is tapped
  final Function(String tabId)? onTabClose;

  /// Callback when the add tab button is tapped
  final VoidCallback? onAddTab;

  /// Callback when tabs are reordered via drag and drop
  final Function(int oldIndex, int newIndex)? onTabReorder;

  /// Workspace identifier for drag and drop operations
  final String workspaceId;

  /// Theme configuration for styling
  final SplitWorkspaceTheme? theme;

  const TabBarWidget({
    super.key,
    required this.tabs,
    this.activeTabId,
    this.onTabTap,
    this.onTabClose,
    this.onAddTab,
    this.onTabReorder,
    required this.workspaceId,
    this.theme,
  });

  @override
  State<TabBarWidget> createState() => _TabBarWidgetState();
}

class _TabBarWidgetState extends State<TabBarWidget> {
  /// Index where a dragged tab would be inserted
  int? _dragOverIndex;

  /// Whether a drag operation is currently in progress
  bool _isDragging = false;

  /// Controller for horizontal scrolling of tabs
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workspaceTheme = widget.theme ?? SplitWorkspaceTheme.defaultTheme;
    final colorScheme = workspaceTheme.colorScheme;
    final tabTheme = workspaceTheme.tab;
    final scrollbarTheme = workspaceTheme.scrollbar;

    return Container(
      height: tabTheme.height,
      decoration: BoxDecoration(
        color: workspaceTheme.effectiveBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: workspaceTheme.effectiveBorderColor,
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
              // Main tab bar layout
              Row(
                children: [
                  // Scrollable tab area
                  Expanded(
                    child: scrollbarTheme.visible
                        ? _buildThemedScrollbar(workspaceTheme)
                        : _buildScrollableTabRow(workspaceTheme),
                  ),

                  // Add tab button (always visible)
                  if (widget.onAddTab != null)
                    _buildAddTabButton(workspaceTheme),
                ],
              ),

              // Drag indicator
              if (_isDragging && _dragOverIndex != null)
                _buildDragIndicator(workspaceTheme),
            ],
          );
        },
      ),
    );
  }

  /// Builds a scrollbar with proper theme integration and color scheme fallbacks.
  ///
  /// Creates a themed scrollbar that uses colors from the workspace's color scheme
  /// when specific scrollbar colors aren't provided, ensuring visual consistency.
  Widget _buildThemedScrollbar(SplitWorkspaceTheme workspaceTheme) {
    final colorScheme = workspaceTheme.colorScheme;
    final scrollbarTheme = workspaceTheme.scrollbar;

    // Create ScrollbarThemeData with proper color configuration
    final scrollbarThemeData = ScrollbarThemeData(
      thickness: WidgetStateProperty.all(scrollbarTheme.thickness),
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) {
          return scrollbarTheme.hoverColor ??
              scrollbarTheme.thumbColor?.withOpacity(0.8) ??
              colorScheme.outline.withOpacity(0.8);
        }
        return scrollbarTheme.thumbColor ?? colorScheme.outline;
      }),
      trackColor: WidgetStateProperty.all(
        scrollbarTheme.trackColor ?? colorScheme.surfaceContainerHighest,
      ),
      radius: Radius.circular(scrollbarTheme.radius),
      trackVisibility: WidgetStateProperty.all(scrollbarTheme.trackVisible),
      thumbVisibility: WidgetStateProperty.all(scrollbarTheme.alwaysVisible),
    );

    return ScrollbarTheme(
      data: scrollbarThemeData,
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: scrollbarTheme.alwaysVisible,
        trackVisibility: scrollbarTheme.trackVisible,
        child: _buildScrollableTabRow(workspaceTheme),
      ),
    );
  }

  /// Builds the scrollable row of tab items.
  ///
  /// Creates a horizontally scrollable container with all tab items
  /// arranged in a row, handling overflow when there are more tabs
  /// than can fit in the available width.
  Widget _buildScrollableTabRow(SplitWorkspaceTheme workspaceTheme) {
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
            theme: widget.theme,
          );
        }).toList(),
      ),
    );
  }

  /// Builds the add new tab button with theme-integrated colors.
  ///
  /// Creates a button that allows users to add new tabs, positioned at the
  /// end of the tab bar with styling that matches the current theme.
  Widget _buildAddTabButton(SplitWorkspaceTheme workspaceTheme) {
    final colorScheme = workspaceTheme.colorScheme;
    final tabTheme = workspaceTheme.tab;

    return Container(
      width: 36,
      height: tabTheme.height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border(
          left: BorderSide(color: colorScheme.dividerColor, width: 1),
        ),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(workspaceTheme.borderRadius),
          bottomRight: Radius.circular(workspaceTheme.borderRadius),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onAddTab,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(workspaceTheme.borderRadius),
            bottomRight: Radius.circular(workspaceTheme.borderRadius),
          ),
          child: Icon(Icons.add, size: 16, color: colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }

  /// Builds the visual indicator shown during drag operations.
  ///
  /// Displays a colored line that indicates where a dragged tab would be
  /// inserted if dropped at the current position. Uses the theme's primary
  /// color for visibility and consistency.
  Widget _buildDragIndicator(SplitWorkspaceTheme theme) {
    if (_dragOverIndex == null) return const SizedBox.shrink();

    final colorScheme = theme.colorScheme;
    final tabWidth = _calculateTabWidth();
    final indicatorX = _dragOverIndex! * tabWidth;

    return Positioned(
      left: indicatorX,
      top: 0,
      child: Container(
        width: 3,
        height: theme.tab.height,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(1.5),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.3),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }

  /// Updates the drag over index based on the current mouse position.
  ///
  /// Calculates which tab position the mouse is currently over during
  /// a drag operation, updating the visual indicator accordingly.
  void _updateDragOverIndex(Offset offset) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    int newIndex = 0;
    double accumulatedWidth = 0;

    // Calculate the closest index based on actual tab positions
    for (int i = 0; i < widget.tabs.length; i++) {
      final tabWidth = _calculateTabWidth();
      final tabCenter = accumulatedWidth + (tabWidth / 2);

      if (offset.dx < tabCenter) {
        newIndex = i;
        break;
      }

      accumulatedWidth += tabWidth;
      newIndex = i + 1; // After last tab
    }

    // Clamp to valid range
    newIndex = newIndex.clamp(0, widget.tabs.length);

    if (newIndex != _dragOverIndex) {
      setState(() {
        _dragOverIndex = newIndex;
      });
    }
  }

  /// Calculates the optimal width for individual tabs.
  ///
  /// Determines tab width based on available space, tab count, and
  /// theme constraints (minimum and maximum width limits).
  double _calculateTabWidth() {
    final tabTheme = widget.theme?.tab ?? const SplitWorkspaceTabTheme();
    final availableWidth = MediaQuery.of(context).size.width - 36 - 50;
    final tabCount = widget.tabs.length;

    if (tabCount == 0) return 120.0;

    final calculatedWidth = availableWidth / tabCount;
    return calculatedWidth.clamp(
      tabTheme.minWidth ?? 120.0,
      tabTheme.maxWidth ?? 200.0,
    );
  }

  /// Handles the completion of drag and drop operations.
  ///
  /// Processes the dropped tab data to determine if reordering should occur,
  /// and triggers the appropriate callback with the old and new indices.
  void _handleDrop(DragData dragData) {
    // Handle reordering within the same workspace
    if (dragData.sourceWorkspaceId == widget.workspaceId &&
        _dragOverIndex != null) {
      final oldIndex = dragData.originalIndex;
      final newIndex = _dragOverIndex!;

      // Only trigger callback if position actually changed
      if (oldIndex != newIndex) {
        widget.onTabReorder?.call(oldIndex, newIndex);
      }
    }

    // TODO: Handle cross-workspace drops in future versions
  }
}

```
## lib/src/widgets/tab_item_widget.dart
```dart
// lib/src/widgets/tab_item_widget.dart (수정)
import 'package:flutter/material.dart';

import '../models/drag_data.dart';
import '../models/tab_data.dart';
import '../theme/split_workspace_theme.dart';

/// Individual tab item widget with drag and drop functionality
///
/// This widget represents a single tab in the tab bar and handles:
/// - Tab appearance (active/inactive states)
/// - Drag and drop interactions
/// - Close functionality
/// - Theme integration with colorScheme
class TabItemWidget extends StatelessWidget {
  /// The tab data to display
  final TabData tab;

  /// Whether this tab is currently active
  final bool isActive;

  /// Callback when the tab is tapped
  final VoidCallback? onTap;

  /// Callback when the close button is tapped
  final VoidCallback? onClose;

  /// Index of this tab in the tab list
  final int tabIndex;

  /// Workspace ID for drag and drop operations
  final String workspaceId;

  /// Theme configuration for styling
  final SplitWorkspaceTheme? theme;

  const TabItemWidget({
    super.key,
    required this.tab,
    required this.isActive,
    this.onTap,
    this.onClose,
    required this.tabIndex,
    required this.workspaceId,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final workspaceTheme = theme ?? SplitWorkspaceTheme.defaultTheme;

    return LongPressDraggable<DragData>(
      // Drag data payload
      data: DragData(
        tab: tab,
        originalIndex: tabIndex,
        sourceWorkspaceId: workspaceId,
      ),

      // Prevent accidental drags
      delay: const Duration(milliseconds: 200),

      // Widget shown while dragging
      feedback: _buildDragFeedback(context, workspaceTheme),

      // Widget shown at original position during drag
      childWhenDragging: _buildDragPlaceholder(context, workspaceTheme),

      // Normal tab appearance
      child: _buildNormalTab(context, workspaceTheme),
    );
  }

  /// Builds the normal tab appearance with theme-integrated colors.
  ///
  /// Creates the standard tab button with appropriate colors based on
  /// the active/inactive state, using the color scheme for consistency
  /// when specific tab colors aren't provided.
  Widget _buildNormalTab(BuildContext context, SplitWorkspaceTheme theme) {
    final colorScheme = theme.colorScheme;
    final tabTheme = theme.tab;

    // Determine colors based on active state and colorScheme
    final backgroundColor = isActive
        ? (tabTheme.activeBackgroundColor ?? colorScheme.surface)
        : (tabTheme.inactiveBackgroundColor ??
              colorScheme.surfaceContainerHighest);

    final textColor = isActive
        ? (tabTheme.activeTextColor ?? colorScheme.onSurface)
        : (tabTheme.inactiveTextColor ?? colorScheme.onSurfaceVariant);

    final borderColor = tabTheme.borderColor ?? colorScheme.dividerColor;

    return Container(
      height: tabTheme.height,
      constraints: BoxConstraints(
        minWidth: tabTheme.minWidth ?? 120,
        maxWidth: tabTheme.maxWidth ?? 200,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(tabTheme.borderRadius),
        border: Border(right: BorderSide(color: borderColor, width: 1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(tabTheme.borderRadius),
          child: Padding(
            padding: EdgeInsets.only(left: 12, right: tab.closeable ? 4 : 12),
            child: Row(
              children: [
                // Drag handle icon (if enabled)
                if (tabTheme.showDragHandle) ...[
                  Icon(
                    Icons.drag_indicator,
                    size: tabTheme.dragHandleSize,
                    color: textColor.withOpacity(0.7),
                  ),
                  const SizedBox(width: 6),
                ],

                // Tab title
                Expanded(
                  child: Text(
                    tab.title,
                    style: (tabTheme.textStyle ?? const TextStyle(fontSize: 13))
                        .copyWith(color: textColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Close button
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
                          size: tabTheme.closeButtonSize,
                          color: textColor,
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

  /// Builds the visual feedback widget shown while dragging.
  ///
  /// Creates a floating representation of the tab being dragged,
  /// with elevated appearance and primary colors to indicate
  /// the drag state clearly to the user.
  Widget _buildDragFeedback(BuildContext context, SplitWorkspaceTheme theme) {
    final colorScheme = theme.colorScheme;
    final tabTheme = theme.tab;

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(tabTheme.borderRadius),
      child: Container(
        height: tabTheme.height,
        width: 160, // Fixed width for feedback
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withOpacity(0.9),
          borderRadius: BorderRadius.circular(tabTheme.borderRadius),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.7),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(Icons.tab, size: 16, color: colorScheme.onPrimaryContainer),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tab.title,
                  style: (tabTheme.textStyle ?? const TextStyle(fontSize: 13))
                      .copyWith(color: colorScheme.onPrimaryContainer),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the placeholder widget shown at the original tab position during drag.
  ///
  /// Creates a subtle, semi-transparent representation that indicates
  /// where the tab originally was, maintaining layout stability during
  /// the drag operation.
  Widget _buildDragPlaceholder(
    BuildContext context,
    SplitWorkspaceTheme theme,
  ) {
    final colorScheme = theme.colorScheme;
    final tabTheme = theme.tab;

    return Container(
      height: tabTheme.height,
      constraints: BoxConstraints(
        minWidth: tabTheme.minWidth ?? 120,
        maxWidth: tabTheme.maxWidth ?? 200,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: Border(
          right: BorderSide(color: colorScheme.dividerColor, width: 1),
        ),
        borderRadius: BorderRadius.circular(tabTheme.borderRadius),
      ),
      child: Center(
        child: Container(
          width: 80,
          height: 2,
          decoration: BoxDecoration(
            color: colorScheme.outline.withOpacity(0.5),
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
import 'package:flutter_split_workspace/src/theme/split_workspace_color_scheme_theme.dart';

import '../models/tab_data.dart';
import '../theme/split_workspace_theme.dart';
import 'tab_bar_widget.dart';

/// Main workspace widget that combines tab bar and content area
///
/// This widget provides a complete tab management interface including:
/// - Tab bar with drag and drop functionality
/// - Content area displaying the active tab's content
/// - Consistent theming with colorScheme integration
/// - Fallback UI when no tabs are active
class TabWorkspace extends StatelessWidget {
  /// List of tabs to display
  final List<TabData> tabs;

  /// Currently active tab ID
  final String? activeTabId;

  /// Callback when a tab is selected
  final Function(String tabId)? onTabTap;

  /// Callback when a tab is closed
  final Function(String tabId)? onTabClose;

  /// Callback when add tab button is pressed
  final VoidCallback? onAddTab;

  /// Callback when tabs are reordered
  final Function(int oldIndex, int newIndex)? onTabReorder;

  /// Unique workspace identifier
  final String? workspaceId;

  /// Theme configuration for styling the entire workspace.
  ///
  /// When null, uses [SplitWorkspaceTheme.defaultTheme]. The theme
  /// controls colors, dimensions, and behavior for all workspace components.
  final SplitWorkspaceTheme? theme;

  /// Creates a tab workspace with the specified configuration.
  ///
  /// The [tabs] parameter is required and contains the list of tabs to display.
  /// All other parameters are optional and provide callbacks for user interactions
  /// and customization options.
  ///
  /// Example:
  /// ```dart
  /// TabWorkspace(
  ///   tabs: myTabs,
  ///   activeTabId: 'tab_1',
  ///   onTabTap: (tabId) => setState(() => activeTab = tabId),
  ///   onTabReorder: (oldIndex, newIndex) => reorderTabs(oldIndex, newIndex),
  ///   theme: SplitWorkspaceTheme.dark,
  /// )
  /// ```
  const TabWorkspace({
    super.key,
    required this.tabs,
    this.activeTabId,
    this.onTabTap,
    this.onTabClose,
    this.onAddTab,
    this.onTabReorder,
    this.workspaceId,
    this.theme,
  });

  /// Returns the currently active tab data, if any.
  ///
  /// Searches for a tab with an ID matching [activeTabId] and returns it.
  /// Returns null if no active tab ID is set or if no matching tab is found.
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
    final colorScheme = workspaceTheme.colorScheme;
    final effectiveWorkspaceId = workspaceId ?? 'default';

    return Container(
      decoration: BoxDecoration(
        color: workspaceTheme.effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(workspaceTheme.borderRadius),
        border: workspaceTheme.borderWidth > 0
            ? Border.all(
                color: workspaceTheme.effectiveBorderColor,
                width: workspaceTheme.borderWidth,
              )
            : null,
      ),
      child: Column(
        children: [
          // Tab bar
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

          // Content area
          Expanded(child: _buildContentArea(workspaceTheme, colorScheme)),
        ],
      ),
    );
  }

  /// Builds the main content area using colorScheme
  Widget _buildContentArea(
    SplitWorkspaceTheme workspaceTheme,
    SplitWorkspaceColorSchemeTheme colorScheme,
  ) {
    // Show active tab content if available
    if (activeTab?.content != null) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: workspaceTheme.borderRadius > 0
              ? BorderRadius.only(
                  bottomLeft: Radius.circular(workspaceTheme.borderRadius),
                  bottomRight: Radius.circular(workspaceTheme.borderRadius),
                )
              : null,
        ),
        child: activeTab!.content!,
      );
    }

    // Show fallback UI when no active tab
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: workspaceTheme.borderRadius > 0
            ? BorderRadius.only(
                bottomLeft: Radius.circular(workspaceTheme.borderRadius),
                bottomRight: Radius.circular(workspaceTheme.borderRadius),
              )
            : null,
      ),
      child: _buildEmptyState(workspaceTheme, colorScheme),
    );
  }

  /// Builds the empty state UI using colorScheme
  Widget _buildEmptyState(
    SplitWorkspaceTheme workspaceTheme,
    SplitWorkspaceColorSchemeTheme colorScheme,
  ) {
    final tabTheme = workspaceTheme.tab;
    final hasAddTabButton = onAddTab != null;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Empty state icon
          Icon(
            tabs.isEmpty ? Icons.tab : Icons.description_outlined,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),

          const SizedBox(height: 16),

          // Primary message
          Text(
            tabs.isEmpty ? 'No tabs available' : 'No active tab',
            style: (tabTheme.textStyle ?? const TextStyle(fontSize: 16))
                .copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
          ),

          const SizedBox(height: 8),

          // Secondary message
          Text(
            tabs.isEmpty
                ? hasAddTabButton
                      ? 'Click the + button to add your first tab'
                      : 'Add tabs to get started'
                : 'Select a tab to view its content',
            style: (tabTheme.textStyle ?? const TextStyle(fontSize: 14))
                .copyWith(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),

          // Optional action button for empty workspace
          if (tabs.isEmpty && hasAddTabButton) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAddTab,
              icon: Icon(
                Icons.add,
                size: 18,
                color: colorScheme.onPrimaryContainer,
              ),
              label: Text(
                'Add First Tab',
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],

          // Debug info (only in debug mode)
          if (tabs.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'Debug Info',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total tabs: ${tabs.length}',
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Active tab ID: ${activeTabId ?? 'none'}',
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

```
