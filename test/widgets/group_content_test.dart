import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_split_workspace/models/tab_model.dart';
import 'package:flutter_split_workspace/widgets/group_content.dart';

void main() {
  group('GroupContent', () {
    late TabModel testTab;

    setUp(() {
      testTab = const TabModel(
        id: '1',
        title: 'Test Tab',
        tooltip: 'Test tooltip',
      );
    });

    testWidgets('should show empty state when activeTab is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GroupContent(activeTab: null),
          ),
        ),
      );

      expect(find.text('No tabs open'), findsOneWidget);
      expect(find.byIcon(Icons.tab), findsOneWidget);
    });

    testWidgets('should show custom empty state when provided', (WidgetTester tester) async {
      const customEmptyState = Text('Custom empty state');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GroupContent(
              activeTab: null,
              emptyState: customEmptyState,
            ),
          ),
        ),
      );

      expect(find.text('Custom empty state'), findsOneWidget);
      expect(find.text('No tabs open'), findsNothing);
    });

    testWidgets('should show default content when activeTab is provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupContent(activeTab: testTab),
          ),
        ),
      );

      expect(find.text('Test Tab'), findsOneWidget);
      expect(find.text('Test tooltip'), findsOneWidget);
      expect(find.text('Content for "Test Tab"'), findsOneWidget);
      expect(find.text('Use contentBuilder to provide custom content'), findsOneWidget);
    });

    testWidgets('should use custom contentBuilder when provided', (WidgetTester tester) async {
      Widget customContentBuilder(TabModel tab) {
        return Text('Custom content for ${tab.title}');
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupContent(
              activeTab: testTab,
              contentBuilder: customContentBuilder,
            ),
          ),
        ),
      );

      expect(find.text('Custom content for Test Tab'), findsOneWidget);
      expect(find.text('Content for "Test Tab"'), findsNothing);
    });

    testWidgets('should handle tab without tooltip', (WidgetTester tester) async {
      final tabWithoutTooltip = testTab.copyWith(clearTooltip: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupContent(activeTab: tabWithoutTooltip),
          ),
        ),
      );

      expect(find.text('Test Tab'), findsOneWidget);
      expect(find.text('Test tooltip'), findsNothing);
      expect(find.text('Content for "Test Tab"'), findsOneWidget);
    });

    testWidgets('should apply correct theme styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: GroupContent(activeTab: testTab),
          ),
        ),
      );

      final containers = find.byType(Container);
      expect(containers, findsWidgets);

      final columns = find.byType(Column);
      expect(columns, findsWidgets);
    });

    testWidgets('should show description icon in default content', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupContent(activeTab: testTab),
          ),
        ),
      );

      expect(find.byIcon(Icons.description_outlined), findsOneWidget);
    });

    testWidgets('should handle empty tab title gracefully', (WidgetTester tester) async {
      final emptyTitleTab = testTab.copyWith(title: '');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupContent(activeTab: emptyTitleTab),
          ),
        ),
      );

      expect(find.text(''), findsOneWidget);
      expect(find.text('Content for ""'), findsOneWidget);
    });

    testWidgets('should expand content area properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: GroupContent(activeTab: testTab),
            ),
          ),
        ),
      );

      final expanded = find.byType(Expanded);
      expect(expanded, findsOneWidget);
    });
  });
}