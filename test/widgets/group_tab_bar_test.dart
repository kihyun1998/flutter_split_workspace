import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_split_workspace/models/tab_model.dart';
import 'package:flutter_split_workspace/widgets/group_tab_bar.dart';
import 'package:flutter_split_workspace/widgets/tab_item.dart';

void main() {
  group('GroupTabBar', () {
    late List<TabModel> testTabs;

    setUp(() {
      testTabs = [
        const TabModel(id: '1', title: 'Tab 1'),
        const TabModel(id: '2', title: 'Tab 2'),
        const TabModel(id: '3', title: 'Tab 3'),
      ];
    });

    testWidgets('should render all tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupTabBar(tabs: testTabs),
          ),
        ),
      );

      expect(find.byType(TabItem), findsNWidgets(3));
      expect(find.text('Tab 1'), findsOneWidget);
      expect(find.text('Tab 2'), findsOneWidget);
      expect(find.text('Tab 3'), findsOneWidget);
    });

    testWidgets('should render empty state when no tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GroupTabBar(tabs: []),
          ),
        ),
      );

      expect(find.byType(TabItem), findsNothing);
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('should mark active tab correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupTabBar(
              tabs: testTabs,
              activeTabId: '2',
            ),
          ),
        ),
      );

      final tabItems = tester.widgetList<TabItem>(find.byType(TabItem)).toList();
      
      expect(tabItems[0].isActive, isFalse);
      expect(tabItems[1].isActive, isTrue);
      expect(tabItems[2].isActive, isFalse);
    });

    testWidgets('should call onTabTap when tab is tapped', (WidgetTester tester) async {
      String? tappedTabId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupTabBar(
              tabs: testTabs,
              onTabTap: (tabId) => tappedTabId = tabId,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tab 2'));
      expect(tappedTabId, '2');
    });

    testWidgets('should call onTabClose when tab is closed', (WidgetTester tester) async {
      String? closedTabId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupTabBar(
              tabs: testTabs,
              onTabClose: (tabId) => closedTabId = tabId,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close).first);
      expect(closedTabId, '1');
    });

    testWidgets('should be scrollable horizontally', (WidgetTester tester) async {
      final manyTabs = List.generate(
        20, 
        (index) => TabModel(id: '$index', title: 'Tab $index'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupTabBar(tabs: manyTabs),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      
      final scrollView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(scrollView.scrollDirection, Axis.horizontal);
    });

    testWidgets('should handle tabs with different canClose values', (WidgetTester tester) async {
      final mixedTabs = [
        const TabModel(id: '1', title: 'Closeable', canClose: true),
        const TabModel(id: '2', title: 'Not Closeable', canClose: false),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupTabBar(
              tabs: mixedTabs,
              onTabClose: (tabId) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should pass null callbacks when not provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupTabBar(tabs: testTabs),
          ),
        ),
      );

      final tabItems = tester.widgetList<TabItem>(find.byType(TabItem)).toList();
      
      expect(tabItems[0].onTap, isNull);
      expect(tabItems[0].onClose, isNull);
    });
  });
}