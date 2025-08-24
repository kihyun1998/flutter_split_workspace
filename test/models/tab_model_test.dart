import 'package:flutter_split_workspace/models/tab_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TabModel', () {
    test('should create a tab with required properties', () {
      const tab = TabModel(id: 'tab1', title: 'Test Tab');

      expect(tab.id, 'tab1');
      expect(tab.title, 'Test Tab');
      expect(tab.tooltip, null);
      expect(tab.canClose, true);
      expect(tab.data, null);
    });

    test('should create a tab with all properties', () {
      final tab = TabModel(
        id: 'tab1',
        title: 'Test Tab',
        tooltip: 'This is a test tab',
        canClose: false,
        data: {'key': 'value'},
      );

      expect(tab.id, 'tab1');
      expect(tab.title, 'Test Tab');
      expect(tab.tooltip, 'This is a test tab');
      expect(tab.canClose, false);
      expect(tab.data, {'key': 'value'});
    });

    test('should create a copy with modified properties', () {
      const original = TabModel(id: 'tab1', title: 'Original Title');

      final copied = original.copyWith(title: 'New Title', canClose: false);

      expect(copied.id, 'tab1');
      expect(copied.title, 'New Title');
      expect(copied.canClose, false);
      expect(copied.tooltip, null);
    });

    test('should clear tooltip with clearTooltip flag', () {
      const original = TabModel(
        id: 'tab1', 
        title: 'Test Tab',
        tooltip: 'Original tooltip',
      );

      final copied = original.copyWith(clearTooltip: true);

      expect(copied.id, 'tab1');
      expect(copied.title, 'Test Tab');
      expect(copied.tooltip, null);
    });

    test('should maintain equality for tabs with same core properties', () {
      const tab1 = TabModel(
        id: 'tab1',
        title: 'Test Tab',
        tooltip: 'tooltip',
        canClose: true,
      );

      const tab2 = TabModel(
        id: 'tab1',
        title: 'Test Tab',
        tooltip: 'tooltip',
        canClose: true,
      );

      expect(tab1, equals(tab2));
      expect(tab1.hashCode, equals(tab2.hashCode));
    });

    test('should not be equal for tabs with different properties', () {
      const tab1 = TabModel(id: 'tab1', title: 'Test Tab');

      const tab2 = TabModel(id: 'tab2', title: 'Test Tab');

      expect(tab1, isNot(equals(tab2)));
    });

    test('should have meaningful string representation', () {
      const tab = TabModel(
        id: 'tab1',
        title: 'Test Tab',
        tooltip: 'tooltip',
        canClose: false,
      );

      final string = tab.toString();
      expect(string, contains('tab1'));
      expect(string, contains('Test Tab'));
      expect(string, contains('tooltip'));
      expect(string, contains('false'));
    });
  });
}
