import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_split_workspace/flutter_split_workspace.dart';

void main() {
  test('exports models correctly', () {
    const tab = TabModel(id: 'test', title: 'Test Tab');
    expect(tab.id, 'test');
    
    final panel = SplitPanel.singleGroup(
      id: 'panel1',
      tabs: [tab],
    );
    expect(panel.isLeaf, true);
  });
}
