import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_split_workspace/models/split_panel_model.dart';
import 'package:flutter_split_workspace/models/tab_model.dart';

void main() {
  group('SplitDirection', () {
    test('should have horizontal and vertical values', () {
      expect(SplitDirection.values, contains(SplitDirection.horizontal));
      expect(SplitDirection.values, contains(SplitDirection.vertical));
    });
  });

  group('DropZoneType', () {
    test('should have all required drop zone types', () {
      expect(DropZoneType.values, contains(DropZoneType.splitLeft));
      expect(DropZoneType.values, contains(DropZoneType.splitRight));
      expect(DropZoneType.values, contains(DropZoneType.splitTop));
      expect(DropZoneType.values, contains(DropZoneType.splitBottom));
      expect(DropZoneType.values, contains(DropZoneType.moveToGroup));
    });
  });

  group('SplitPanel', () {
    group('singleGroup constructor', () {
      test('should create a single group panel', () {
        const tab1 = TabModel(id: 'tab1', title: 'Tab 1');
        const tab2 = TabModel(id: 'tab2', title: 'Tab 2');
        
        final panel = SplitPanel.singleGroup(
          id: 'panel1',
          tabs: [tab1, tab2],
          activeTabId: 'tab1',
        );

        expect(panel.id, 'panel1');
        expect(panel.isLeaf, true);
        expect(panel.isSplit, false);
        expect(panel.tabs?.length, 2);
        expect(panel.activeTabId, 'tab1');
        expect(panel.direction, null);
        expect(panel.children, null);
        expect(panel.ratio, 0.5);
      });

      test('should return correct active tab', () {
        const tab1 = TabModel(id: 'tab1', title: 'Tab 1');
        const tab2 = TabModel(id: 'tab2', title: 'Tab 2');
        
        final panel = SplitPanel.singleGroup(
          id: 'panel1',
          tabs: [tab1, tab2],
          activeTabId: 'tab1',
        );

        expect(panel.activeTab, equals(tab1));
      });

      test('should return null for invalid active tab id', () {
        const tab1 = TabModel(id: 'tab1', title: 'Tab 1');
        
        final panel = SplitPanel.singleGroup(
          id: 'panel1',
          tabs: [tab1],
          activeTabId: 'invalid',
        );

        expect(panel.activeTab, null);
      });

      test('should return null when no active tab id is set', () {
        const tab1 = TabModel(id: 'tab1', title: 'Tab 1');
        
        final panel = SplitPanel.singleGroup(
          id: 'panel1',
          tabs: [tab1],
        );

        expect(panel.activeTab, null);
      });
    });

    group('split constructor', () {
      test('should create a split panel', () {
        final child1 = SplitPanel.singleGroup(
          id: 'child1',
          tabs: [const TabModel(id: 'tab1', title: 'Tab 1')],
        );
        
        final child2 = SplitPanel.singleGroup(
          id: 'child2',
          tabs: [const TabModel(id: 'tab2', title: 'Tab 2')],
        );

        final panel = SplitPanel.split(
          id: 'split1',
          direction: SplitDirection.horizontal,
          children: [child1, child2],
        );

        expect(panel.id, 'split1');
        expect(panel.isLeaf, false);
        expect(panel.isSplit, true);
        expect(panel.direction, SplitDirection.horizontal);
        expect(panel.children?.length, 2);
        expect(panel.tabs, null);
        expect(panel.activeTabId, null);
        expect(panel.activeTab, null);
      });
    });

    group('copyWith', () {
      test('should copy single group with modifications', () {
        const tab1 = TabModel(id: 'tab1', title: 'Tab 1');
        
        final original = SplitPanel.singleGroup(
          id: 'panel1',
          tabs: [tab1],
          activeTabId: 'tab1',
        );

        final copied = original.copyWith(
          activeTabId: 'tab2',
          ratio: 0.7,
        );

        expect(copied.id, 'panel1');
        expect(copied.tabs, [tab1]);
        expect(copied.activeTabId, 'tab2');
        expect(copied.ratio, 0.7);
      });
    });

    group('equality', () {
      test('should be equal for panels with same core properties', () {
        final panel1 = SplitPanel.singleGroup(
          id: 'panel1',
          tabs: [const TabModel(id: 'tab1', title: 'Tab 1')],
          activeTabId: 'tab1',
        );

        final panel2 = SplitPanel.singleGroup(
          id: 'panel1',
          tabs: [const TabModel(id: 'tab1', title: 'Tab 1')],
          activeTabId: 'tab1',
        );

        expect(panel1, equals(panel2));
        expect(panel1.hashCode, equals(panel2.hashCode));
      });

      test('should not be equal for panels with different ids', () {
        final panel1 = SplitPanel.singleGroup(
          id: 'panel1',
          tabs: [const TabModel(id: 'tab1', title: 'Tab 1')],
        );

        final panel2 = SplitPanel.singleGroup(
          id: 'panel2',
          tabs: [const TabModel(id: 'tab1', title: 'Tab 1')],
        );

        expect(panel1, isNot(equals(panel2)));
      });
    });

    group('toString', () {
      test('should have meaningful string representation for single group', () {
        final panel = SplitPanel.singleGroup(
          id: 'panel1',
          tabs: [const TabModel(id: 'tab1', title: 'Tab 1')],
          activeTabId: 'tab1',
        );

        final string = panel.toString();
        expect(string, contains('singleGroup'));
        expect(string, contains('panel1'));
        expect(string, contains('1'));
        expect(string, contains('tab1'));
      });

      test('should have meaningful string representation for split panel', () {
        final child1 = SplitPanel.singleGroup(
          id: 'child1',
          tabs: [const TabModel(id: 'tab1', title: 'Tab 1')],
        );

        final panel = SplitPanel.split(
          id: 'split1',
          direction: SplitDirection.horizontal,
          children: [child1],
        );

        final string = panel.toString();
        expect(string, contains('split'));
        expect(string, contains('split1'));
        expect(string, contains('horizontal'));
        expect(string, contains('1'));
      });
    });
  });
}