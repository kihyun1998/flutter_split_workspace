import 'tab_model.dart';

enum SplitDirection {
  horizontal,
  vertical
}

enum DropZoneType {
  splitLeft,
  splitRight,
  splitTop,
  splitBottom,
  moveToGroup,
}

class SplitPanel {
  final String id;
  final SplitDirection? direction;
  final List<SplitPanel>? children;
  final List<TabModel>? tabs;
  final String? activeTabId;
  final double ratio;

  const SplitPanel({
    required this.id,
    this.direction,
    this.children,
    this.tabs,
    this.activeTabId,
    this.ratio = 0.5,
  });

  SplitPanel.singleGroup({
    required this.id,
    required List<TabModel> tabs,
    this.activeTabId,
  }) : direction = null,
       children = null,
       tabs = tabs,
       ratio = 0.5;

  SplitPanel.split({
    required this.id,
    required this.direction,
    required this.children,
  }) : tabs = null,
       activeTabId = null,
       ratio = 0.5;

  bool get isLeaf => children == null;
  bool get isSplit => children != null;

  TabModel? get activeTab {
    if (tabs == null || activeTabId == null) return null;
    try {
      return tabs!.firstWhere((tab) => tab.id == activeTabId);
    } catch (e) {
      return null;
    }
  }

  SplitPanel copyWith({
    String? id,
    SplitDirection? direction,
    List<SplitPanel>? children,
    List<TabModel>? tabs,
    String? activeTabId,
    double? ratio,
  }) {
    return SplitPanel(
      id: id ?? this.id,
      direction: direction ?? this.direction,
      children: children ?? this.children,
      tabs: tabs ?? this.tabs,
      activeTabId: activeTabId ?? this.activeTabId,
      ratio: ratio ?? this.ratio,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is SplitPanel &&
      other.id == id &&
      other.direction == direction &&
      other.activeTabId == activeTabId &&
      other.ratio == ratio;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      direction.hashCode ^
      activeTabId.hashCode ^
      ratio.hashCode;
  }

  @override
  String toString() {
    if (isLeaf) {
      return 'SplitPanel.singleGroup(id: $id, tabs: ${tabs?.length ?? 0}, activeTabId: $activeTabId)';
    } else {
      return 'SplitPanel.split(id: $id, direction: $direction, children: ${children?.length ?? 0})';
    }
  }
}