import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_split_workspace/models/tab_model.dart';
import 'package:flutter_split_workspace/services/tab_service.dart';

void main() {
  group('TabService', () {
    late List<TabModel> testTabs;

    setUp(() {
      testTabs = [
        const TabModel(id: '1', title: 'Tab 1'),
        const TabModel(id: '2', title: 'Tab 2'),
        const TabModel(id: '3', title: 'Tab 3'),
      ];
    });

    group('addTab', () {
      test('should add tab to end when no index specified', () {
        final newTab = const TabModel(id: '4', title: 'Tab 4');
        final result = TabService.addTab(testTabs, newTab);

        expect(result.length, 4);
        expect(result.last.id, '4');
        expect(result.last.title, 'Tab 4');
      });

      test('should add tab at specified index', () {
        final newTab = const TabModel(id: '4', title: 'Tab 4');
        final result = TabService.addTab(testTabs, newTab, index: 1);

        expect(result.length, 4);
        expect(result[1].id, '4');
        expect(result[1].title, 'Tab 4');
        expect(result[2].id, '2');
      });

      test('should add tab to end when index is out of bounds', () {
        final newTab = const TabModel(id: '4', title: 'Tab 4');
        final result = TabService.addTab(testTabs, newTab, index: 10);

        expect(result.length, 4);
        expect(result.last.id, '4');
      });

      test('should not modify original tabs list', () {
        final newTab = const TabModel(id: '4', title: 'Tab 4');
        TabService.addTab(testTabs, newTab);

        expect(testTabs.length, 3);
      });
    });

    group('removeTab', () {
      test('should remove tab with specified id', () {
        final result = TabService.removeTab(testTabs, '2');

        expect(result.length, 2);
        expect(result.map((tab) => tab.id), ['1', '3']);
      });

      test('should return same list when tab id not found', () {
        final result = TabService.removeTab(testTabs, 'nonexistent');

        expect(result.length, 3);
        expect(result.map((tab) => tab.id), ['1', '2', '3']);
      });

      test('should not modify original tabs list', () {
        TabService.removeTab(testTabs, '2');

        expect(testTabs.length, 3);
      });
    });

    group('activateTab', () {
      test('should return tab id when tab exists', () {
        final result = TabService.activateTab(testTabs, '2');

        expect(result, '2');
      });

      test('should return null when tab does not exist', () {
        final result = TabService.activateTab(testTabs, 'nonexistent');

        expect(result, isNull);
      });
    });

    group('moveTab', () {
      test('should move tab to new index', () {
        final result = TabService.moveTab(testTabs, '1', 2);

        expect(result.length, 3);
        expect(result.map((tab) => tab.id), ['2', '3', '1']);
      });

      test('should move tab from end to beginning', () {
        final result = TabService.moveTab(testTabs, '3', 0);

        expect(result.length, 3);
        expect(result.map((tab) => tab.id), ['3', '1', '2']);
      });

      test('should handle moving tab to same position', () {
        final result = TabService.moveTab(testTabs, '2', 1);

        expect(result.length, 3);
        expect(result.map((tab) => tab.id), ['1', '2', '3']);
      });

      test('should return same list when tab id not found', () {
        final result = TabService.moveTab(testTabs, 'nonexistent', 1);

        expect(result.length, 3);
        expect(result.map((tab) => tab.id), ['1', '2', '3']);
      });

      test('should return same list when index is out of bounds', () {
        final result = TabService.moveTab(testTabs, '1', 10);

        expect(result.length, 3);
        expect(result.map((tab) => tab.id), ['1', '2', '3']);
      });
    });

    group('getNextActiveTab', () {
      test('should return current active tab when it is not being removed', () {
        final result = TabService.getNextActiveTab(testTabs, '2', '1');

        expect(result, '1');
      });

      test('should return next tab when removing active tab', () {
        final result = TabService.getNextActiveTab(testTabs, '1', '1');

        expect(result, '2');
      });

      test('should return previous tab when removing last active tab', () {
        final result = TabService.getNextActiveTab(testTabs, '3', '3');

        expect(result, '2');
      });

      test('should return null when removing last tab', () {
        final singleTab = [const TabModel(id: '1', title: 'Tab 1')];
        final result = TabService.getNextActiveTab(singleTab, '1', '1');

        expect(result, isNull);
      });

      test('should return first tab when removed tab id not found', () {
        final result = TabService.getNextActiveTab(testTabs, 'nonexistent', 'nonexistent');

        expect(result, '1');
      });
    });

    group('findTab', () {
      test('should return tab when found', () {
        final result = TabService.findTab(testTabs, '2');

        expect(result, isNotNull);
        expect(result!.id, '2');
        expect(result.title, 'Tab 2');
      });

      test('should return null when tab not found', () {
        final result = TabService.findTab(testTabs, 'nonexistent');

        expect(result, isNull);
      });
    });

    group('hasTab', () {
      test('should return true when tab exists', () {
        final result = TabService.hasTab(testTabs, '2');

        expect(result, isTrue);
      });

      test('should return false when tab does not exist', () {
        final result = TabService.hasTab(testTabs, 'nonexistent');

        expect(result, isFalse);
      });
    });
  });
}