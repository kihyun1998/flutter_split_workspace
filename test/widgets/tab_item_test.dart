import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_split_workspace/models/tab_model.dart';
import 'package:flutter_split_workspace/widgets/tab_item.dart';

void main() {
  group('TabItem', () {
    late TabModel testTab;

    setUp(() {
      testTab = const TabModel(
        id: '1',
        title: 'Test Tab',
        tooltip: 'Test tooltip',
        canClose: true,
      );
    });

    testWidgets('should render tab title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TabItem(tab: testTab),
          ),
        ),
      );

      expect(find.text('Test Tab'), findsOneWidget);
    });

    testWidgets('should show close button when canClose is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TabItem(
              tab: testTab,
              onClose: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should not show close button when canClose is false', (WidgetTester tester) async {
      final nonCloseableTab = testTab.copyWith(canClose: false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TabItem(
              tab: nonCloseableTab,
              onClose: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('should not show close button when onClose is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TabItem(tab: testTab),
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('should call onTap when tab is tapped', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TabItem(
              tab: testTab,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TabItem));
      expect(tapped, isTrue);
    });

    testWidgets('should call onClose when close button is tapped', (WidgetTester tester) async {
      bool closed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TabItem(
              tab: testTab,
              onClose: () => closed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      expect(closed, isTrue);
    });

    testWidgets('should apply active styling when isActive is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TabItem(
              tab: testTab,
              isActive: true,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      final border = decoration.border as Border;
      
      expect(border.top.width, 2);
      expect(border.top.color, isNot(Colors.transparent));
    });

    testWidgets('should apply inactive styling when isActive is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TabItem(
              tab: testTab,
              isActive: false,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      final border = decoration.border as Border;
      
      expect(border.top.color, Colors.transparent);
    });

    testWidgets('should truncate long tab titles', (WidgetTester tester) async {
      final longTitleTab = testTab.copyWith(
        title: 'This is a very long tab title that should be truncated',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TabItem(tab: longTitleTab),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text(longTitleTab.title));
      expect(text.overflow, TextOverflow.ellipsis);
    });
  });
}