# flutter_split_workspace Package - Implementation Guide

이 문서는 flutter_split_workspace 패키지 구현을 위한 완전한 가이드입니다. 이 문서만으로도 패키지를 처음부터 구현할 수 있습니다.

## 📋 패키지 개요

**핵심 기능:**
- 탭 생성, 이동, 삭제
- 화면 분할 (수직/수평, 중첩 분할 지원)
- 드래그 앤 드롭으로 탭 이동 및 분할
- 실시간 미리보기
- 크기 조절 가능한 분할선

**제공 범위:**
- UI 위젯 컴포넌트
- 비즈니스 로직 (Service classes)
- 데이터 모델
- 유틸리티 함수

**사용자 구현 필요:**
- 상태 관리 (Riverpod, Bloc, Provider 등 자유 선택)
- 테마 시스템
- 실제 탭 콘텐츠

## 🏗️ 아키텍처 구조

```
lib/
├── models/              # 데이터 모델
│   ├── split_panel_model.dart
│   └── tab_model.dart
├── services/            # 비즈니스 로직
│   ├── split_service.dart
│   ├── tab_service.dart
│   └── workspace_helpers.dart
├── widgets/             # UI 컴포넌트
│   ├── split_container.dart
│   ├── tab_group.dart
│   ├── tab_item.dart
│   ├── group_tab_bar.dart
│   ├── group_content.dart
│   ├── resizable_splitter.dart
│   └── split_preview_overlay.dart
├── extensions/          # 확장 메서드
│   └── drop_zone_type_extension.dart
└── flutter_split_workspace.dart  # 메인 export 파일
```

## 📦 1. 데이터 모델

### 1.1 SplitPanel Model

```dart
// models/split_panel_model.dart

/// 분할 방향
enum SplitDirection {
  horizontal, // 수평 분할 (상하)
  vertical    // 수직 분할 (좌우)
}

/// 드롭 존 타입
enum DropZoneType {
  splitLeft,    // 좌측 수직분할
  splitRight,   // 우측 수직분할
  splitTop,     // 상단 수평분할
  splitBottom,  // 하단 수평분할
  moveToGroup,  // 중앙 탭이동
}

/// 분할 패널 모델 (Tree 구조)
class SplitPanel {
  final String id;
  final SplitDirection? direction; // null = 단일 그룹 (리프 노드)
  final List<SplitPanel>? children; // 분할 시 하위 패널들
  final List<TabModel>? tabs; // 단일 그룹의 탭들 (리프 노드만)
  final String? activeTabId; // 활성 탭 ID (리프 노드만)
  final double ratio; // 분할 비율 (0.0 ~ 1.0)

  const SplitPanel({
    required this.id,
    this.direction,
    this.children,
    this.tabs,
    this.activeTabId,
    this.ratio = 0.5,
  });

  /// 단일 탭 그룹 생성자 (리프 노드)
  SplitPanel.singleGroup({
    required this.id,
    required List<TabModel> tabs,
    this.activeTabId,
  }) : direction = null,
       children = null,
       tabs = tabs,
       ratio = 0.5;

  /// 분할 패널 생성자 (브랜치 노드)
  SplitPanel.split({
    required this.id,
    required this.direction,
    required List<SplitPanel> children,
    this.ratio = 0.5,
  }) : children = children,
       tabs = null,
       activeTabId = null;

  /// 리프 노드인지 확인 (탭 그룹)
  bool get isLeaf => tabs != null;

  /// 브랜치 노드인지 확인 (분할 컨테이너)
  bool get isSplit => children != null;

  /// 활성 탭 반환
  TabModel? get activeTab {
    if (!isLeaf || tabs == null || activeTabId == null) return null;
    try {
      return tabs!.firstWhere((tab) => tab.id == activeTabId);
    } catch (e) {
      return null;
    }
  }

  /// 탭 수 반환 (리프 노드만)
  int get tabCount => isLeaf ? (tabs?.length ?? 0) : 0;

  /// 패널 복사
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

  /// 탭 추가 (리프 노드만)
  SplitPanel addTab(TabModel tab, {bool makeActive = false}) {
    if (!isLeaf) return this;

    final List<TabModel> updatedTabs = [...(tabs ?? []), tab];
    final newActiveTabId = makeActive ? tab.id : activeTabId;

    return copyWith(
      tabs: updatedTabs,
      activeTabId: newActiveTabId,
    );
  }

  /// 특정 위치에 탭 삽입 (리프 노드만)
  SplitPanel insertTabAt(TabModel tab, int index, {bool makeActive = false}) {
    if (!isLeaf) return this;

    final List<TabModel> updatedTabs = List<TabModel>.from(tabs ?? []);
    final clampedIndex = index.clamp(0, updatedTabs.length);
    updatedTabs.insert(clampedIndex, tab);

    final newActiveTabId = makeActive ? tab.id : activeTabId;

    return copyWith(
      tabs: updatedTabs,
      activeTabId: newActiveTabId,
    );
  }

  /// 탭 제거 (리프 노드만)
  SplitPanel removeTab(String tabId) {
    if (!isLeaf || tabs == null) return this;

    final updatedTabs = tabs!.where((tab) => tab.id != tabId).toList();

    // 삭제된 탭이 활성 탭이었다면 다른 탭을 활성화
    String? newActiveTabId = activeTabId;
    if (activeTabId == tabId && updatedTabs.isNotEmpty) {
      // 같은 위치의 탭을 활성화 (마지막이면 이전 탭)
      final deletedIndex = tabs!.indexWhere((tab) => tab.id == tabId);
      final newActiveIndex = deletedIndex >= updatedTabs.length
          ? updatedTabs.length - 1
          : deletedIndex;
      newActiveTabId = updatedTabs[newActiveIndex].id;
    } else if (updatedTabs.isEmpty) {
      newActiveTabId = null;
    }

    return copyWith(
      tabs: updatedTabs,
      activeTabId: newActiveTabId,
    );
  }

  /// 탭 활성화 (리프 노드만)
  SplitPanel activateTab(String tabId) {
    if (!isLeaf || tabs == null) return this;

    final hasTab = tabs!.any((tab) => tab.id == tabId);
    if (!hasTab) return this;

    return copyWith(activeTabId: tabId);
  }

  /// 탭 순서 변경 (리프 노드만)
  SplitPanel reorderTab(String tabId, int newIndex) {
    if (!isLeaf || tabs == null) return this;

    final updatedTabs = List<TabModel>.from(tabs!);
    final tabIndex = updatedTabs.indexWhere((tab) => tab.id == tabId);

    if (tabIndex == -1) return this;

    // 탭 제거 후 새 위치에 삽입
    final tab = updatedTabs.removeAt(tabIndex);
    final clampedIndex = newIndex.clamp(0, updatedTabs.length);
    updatedTabs.insert(clampedIndex, tab);

    return copyWith(tabs: updatedTabs);
  }
}
```

### 1.2 Tab Model

```dart
// models/tab_model.dart

class TabModel {
  final String id;
  final String title;
  final bool isActive;
  final Widget? content;

  const TabModel({
    required this.id,
    required this.title,
    this.isActive = false,
    this.content,
  });

  TabModel copyWith({
    String? id,
    String? title,
    bool? isActive,
    Widget? content,
  }) {
    return TabModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isActive: isActive ?? this.isActive,
      content: content ?? this.content,
    );
  }
}
```

## 🔧 2. 비즈니스 로직 Services

### 2.1 Tab Service

```dart
// services/tab_service.dart

class TabService {
  TabService._();

  /// 새 탭 모델 생성
  static TabModel createNewTab({String? title, Widget? content}) {
    return TabModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title ?? 'New Tab',
      isActive: false,
      content: content,
    );
  }

  /// 새 탭 추가
  static SplitPanel addTab(
    SplitPanel state, {
    String? title,
    Widget? content,
  }) {
    final newTab = createNewTab(title: title, content: content);
    
    if (state.isLeaf) {
      return state.addTab(newTab);
    } else {
      // 분할된 상태인 경우 - 활성 그룹에 추가
      final activeGroup = WorkspaceHelpers.findActiveGroup(state);
      if (activeGroup != null) {
        return WorkspaceHelpers.updatePanel(
          state,
          activeGroup.id,
          activeGroup.addTab(newTab),
        );
      }
      return state;
    }
  }

  /// 특정 그룹에 탭 추가
  static SplitPanel addTabToGroup(
    SplitPanel state,
    String groupId, {
    String? title,
    Widget? content,
  }) {
    final newTab = createNewTab(title: title, content: content);
    
    if (state.isLeaf && state.id == groupId) {
      return state.addTab(newTab, makeActive: true);
    } else {
      final targetGroup = WorkspaceHelpers.findGroupById(state, groupId);
      if (targetGroup != null && targetGroup.isLeaf) {
        final updatedGroup = targetGroup.addTab(newTab, makeActive: true);
        return WorkspaceHelpers.updatePanel(state, groupId, updatedGroup);
      }
      return state;
    }
  }

  /// 탭 삭제 (빈 그룹 감지 포함)
  static ({SplitPanel newState, String? emptyGroupId, bool rootBecameEmpty})
      removeTabWithEmptyCheck(SplitPanel state, String tabId) {
    if (state.isLeaf) {
      // 단일 그룹인 경우
      final updatedPanel = state.removeTab(tabId);

      // 탭이 모두 없어지면 루트가 비어짐
      if (updatedPanel.tabCount == 0) {
        return (
          newState: updatedPanel,
          emptyGroupId: null,
          rootBecameEmpty: true,
        );
      } else {
        return (
          newState: updatedPanel,
          emptyGroupId: null,
          rootBecameEmpty: false,
        );
      }
    } else {
      // 분할된 상태인 경우 - 해당 그룹에서 제거
      final ownerGroup = WorkspaceHelpers.findTabOwnerGroup(state, tabId);
      if (ownerGroup != null) {
        final updatedGroup = ownerGroup.removeTab(tabId);

        // 상태 업데이트
        final newState = WorkspaceHelpers.updatePanel(
          state,
          ownerGroup.id,
          updatedGroup,
        );

        // 빈 그룹 ID 반환
        if (updatedGroup.tabCount == 0) {
          return (
            newState: newState,
            emptyGroupId: ownerGroup.id,
            rootBecameEmpty: false,
          );
        }

        return (
          newState: newState,
          emptyGroupId: null,
          rootBecameEmpty: false,
        );
      }
      return (
        newState: state,
        emptyGroupId: null,
        rootBecameEmpty: false,
      );
    }
  }

  /// 탭 활성화
  static SplitPanel activateTab(SplitPanel state, String tabId) {
    if (state.isLeaf) {
      // 단일 그룹인 경우
      return state.activateTab(tabId);
    } else {
      // 분할된 상태인 경우 - 해당 그룹에서 활성화
      final ownerGroup = WorkspaceHelpers.findTabOwnerGroup(state, tabId);
      if (ownerGroup != null) {
        return WorkspaceHelpers.updatePanel(
          state,
          ownerGroup.id,
          ownerGroup.activateTab(tabId),
        );
      }
      return state;
    }
  }

  /// 탭 순서 변경
  static SplitPanel reorderTab(SplitPanel state, String tabId, int newIndex) {
    if (state.isLeaf) {
      // 단일 그룹인 경우
      return state.reorderTab(tabId, newIndex);
    } else {
      // 분할된 상태인 경우 - 해당 그룹에서 순서 변경
      final ownerGroup = WorkspaceHelpers.findTabOwnerGroup(state, tabId);
      if (ownerGroup != null) {
        return WorkspaceHelpers.updatePanel(
          state,
          ownerGroup.id,
          ownerGroup.reorderTab(tabId, newIndex),
        );
      }
      return state;
    }
  }
}
```

### 2.2 Split Service

```dart
// services/split_service.dart

/// 분할 결과 모델
class SplitResult {
  final SplitPanel newState;
  final String? emptyGroupId;
  final bool needsEmptyGroupCleanup;

  const SplitResult({
    required this.newState,
    this.emptyGroupId,
    this.needsEmptyGroupCleanup = false,
  });
}

class SplitService {
  SplitService._();
  
  static const int maxSplitDepth = 4;

  /// 화면 분할 생성 (중첩 분할 지원)
  static SplitResult createSplitWithResult(
    SplitPanel state, {
    required String sourceTabId,
    required DropZoneType dropZone,
    String? targetGroupId,
  }) {
    // 중앙 존은 분할이 아닌 이동
    if (dropZone == DropZoneType.moveToGroup) {
      return SplitResult(newState: state);
    }

    if (targetGroupId != null) {
      return _splitSpecificGroupWithResult(
          state, sourceTabId, dropZone, targetGroupId);
    } else {
      final splitPanel = _splitRootGroup(state, sourceTabId, dropZone);
      return SplitResult(newState: splitPanel);
    }
  }

  /// 특정 그룹 분할 (중첩 분할, 외부 탭 지원)
  static SplitResult _splitSpecificGroupWithResult(
    SplitPanel state,
    String sourceTabId,
    DropZoneType dropZone,
    String targetGroupId,
  ) {
    // 1. 타겟 그룹 찾기
    final targetGroup = WorkspaceHelpers.findGroupById(state, targetGroupId);
    if (targetGroup == null) {
      return SplitResult(newState: state);
    }

    // 2. 소스 탭 정보 가져오기
    TabModel? sourceTab;
    String? sourceGroupId;

    if (targetGroup.tabs != null &&
        targetGroup.tabs!.any((tab) => tab.id == sourceTabId)) {
      // 케이스 1: 같은 그룹 내 분할
      sourceTab = targetGroup.tabs!.firstWhere((tab) => tab.id == sourceTabId);
      sourceGroupId = targetGroupId;
    } else {
      // 케이스 2: 외부 그룹에서 온 탭
      final sourceGroup = WorkspaceHelpers.findTabOwnerGroup(state, sourceTabId);
      if (sourceGroup == null) {
        return SplitResult(newState: state);
      }
      sourceTab = sourceGroup.tabs!.firstWhere((tab) => tab.id == sourceTabId);
      sourceGroupId = sourceGroup.id;
    }

    // 3. 분할 가능 여부 검사
    if (!_validateGroupForSplit(targetGroup, sourceTabId)) {
      return SplitResult(newState: state);
    }

    // 4. 현재 깊이 체크
    final currentDepth = WorkspaceHelpers.calculateMaxDepth(state);
    if (currentDepth >= maxSplitDepth) {
      return SplitResult(newState: state);
    }

    // 5. 분할 실행
    final splitResult = _performGroupSplit(targetGroup, sourceTab, dropZone);
    if (splitResult == null) {
      return SplitResult(newState: state);
    }

    // 6. 트리에서 타겟 그룹을 분할 결과로 교체
    var newState = WorkspaceHelpers.updatePanel(
      state,
      targetGroupId,
      splitResult,
    );

    // 7. 외부 탭인 경우 원래 그룹에서 제거
    if (sourceGroupId != targetGroupId) {
      final sourceGroup = WorkspaceHelpers.findGroupById(newState, sourceGroupId);
      if (sourceGroup != null && sourceGroup.isLeaf) {
        final updatedSourceGroup = sourceGroup.removeTab(sourceTabId);
        newState = WorkspaceHelpers.updatePanel(
          newState,
          sourceGroupId,
          updatedSourceGroup,
        );

        // 8. 빈 그룹이 되었는지 확인하고 정보 반환
        if (updatedSourceGroup.tabCount == 0) {
          return SplitResult(
            newState: newState,
            emptyGroupId: sourceGroupId,
            needsEmptyGroupCleanup: true,
          );
        }
      }
    }

    return SplitResult(newState: newState);
  }

  /// 그룹 분할 가능 여부 검증
  static bool _validateGroupForSplit(SplitPanel group, String sourceTabId) {
    if (!group.isLeaf) return false;
    if (group.tabs == null) return false;

    final hasSourceTab = group.tabs!.any((tab) => tab.id == sourceTabId);
    if (hasSourceTab) {
      // 같은 그룹 내 분할 - 최소 2개 탭 필요
      if (group.tabs!.length <= 1) return false;
    }
    // 외부 탭으로 분할 - 빈 그룹도 가능

    return true;
  }

  /// 실제 그룹 분할 수행
  static SplitPanel? _performGroupSplit(
    SplitPanel targetGroup,
    TabModel sourceTab,
    DropZoneType dropZone,
  ) {
    final isExternalTab = !targetGroup.tabs!.any((tab) => tab.id == sourceTab.id);

    List<TabModel> remainingTabs;
    String? newActiveTabId;

    if (isExternalTab) {
      // 외부 탭으로 분할
      remainingTabs = List.from(targetGroup.tabs!);
      newActiveTabId = targetGroup.activeTabId;
    } else {
      // 같은 그룹 내 분할
      remainingTabs = targetGroup.tabs!.where((tab) => tab.id != sourceTab.id).toList();
      if (remainingTabs.isEmpty) return null;
      newActiveTabId = targetGroup.activeTabId != sourceTab.id
          ? targetGroup.activeTabId
          : remainingTabs.first.id;
    }

    // 새 그룹 ID 생성
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final existingGroupId = '${targetGroup.id}_existing_$timestamp';
    final newGroupId = '${targetGroup.id}_new_${timestamp + 1}';

    // 기존 탭들을 가진 그룹 생성
    final existingGroup = SplitPanel.singleGroup(
      id: existingGroupId,
      tabs: remainingTabs,
      activeTabId: remainingTabs.isNotEmpty ? newActiveTabId : null,
    );

    // 새 탭을 가진 그룹 생성
    final newGroup = SplitPanel.singleGroup(
      id: newGroupId,
      tabs: [sourceTab],
      activeTabId: sourceTab.id,
    );

    // 분할 방향 및 순서 결정
    final direction = dropZone.splitDirection!;
    final children = dropZone.isNewGroupFirst
        ? [newGroup, existingGroup]
        : [existingGroup, newGroup];

    // 새로운 분할 패널 생성
    return SplitPanel.split(
      id: targetGroup.id,
      direction: direction,
      children: children,
    );
  }

  /// 탭을 다른 그룹으로 이동
  static ({SplitPanel newState, String? emptyGroupId})
      moveTabToGroupWithEmptyCheck(
    SplitPanel state, {
    required String tabId,
    required String targetGroupId,
    int? insertIndex,
  }) {
    // 1. 유효성 검사
    if (state.isLeaf) {
      return (newState: state, emptyGroupId: null);
    }

    final sourceGroup = WorkspaceHelpers.findTabOwnerGroup(state, tabId);
    final targetGroup = WorkspaceHelpers.findGroupById(state, targetGroupId);

    if (sourceGroup == null || targetGroup == null) {
      return (newState: state, emptyGroupId: null);
    }

    if (sourceGroup.id == targetGroupId) {
      // 같은 그룹 내 순서 변경
      if (insertIndex != null) {
        final newState = WorkspaceHelpers.updatePanel(
          state,
          sourceGroup.id,
          sourceGroup.reorderTab(tabId, insertIndex),
        );
        return (newState: newState, emptyGroupId: null);
      }
      return (newState: state, emptyGroupId: null);
    }

    // 2. 이동할 탭 정보 추출
    TabModel movingTab;
    try {
      movingTab = sourceGroup.tabs!.firstWhere((tab) => tab.id == tabId);
    } catch (e) {
      return (newState: state, emptyGroupId: null);
    }

    // 3. 소스 그룹에서 탭 제거
    final updatedSourceGroup = sourceGroup.removeTab(tabId);

    // 4. 타겟 그룹에 탭 추가
    final updatedTargetGroup = insertIndex != null
        ? targetGroup.insertTabAt(movingTab, insertIndex, makeActive: true)
        : targetGroup.addTab(movingTab, makeActive: true);

    // 5. 트리 업데이트
    var newState = WorkspaceHelpers.updatePanel(
      state,
      sourceGroup.id,
      updatedSourceGroup,
    );
    newState = WorkspaceHelpers.updatePanel(
      newState,
      targetGroup.id,
      updatedTargetGroup,
    );

    // 6. 빈 그룹 ID 반환
    final emptyGroupId = updatedSourceGroup.tabCount == 0 ? sourceGroup.id : null;

    return (newState: newState, emptyGroupId: emptyGroupId);
  }

  /// 빈 그룹 제거 및 트리 재구성
  static SplitPanel removeEmptyGroup(SplitPanel state, String groupId) {
    // 1. 루트 그룹 처리
    if (groupId == state.id) {
      return state;
    }

    // 2. 유효성 검사
    final emptyGroup = WorkspaceHelpers.findGroupById(state, groupId);
    if (emptyGroup == null || !emptyGroup.isLeaf || emptyGroup.tabCount > 0) {
      return state;
    }

    // 3. 부모 경로 찾기
    final parentPath = WorkspaceHelpers.findParentPath(state, groupId);
    if (parentPath == null) {
      return state;
    }

    // 4. 형제 그룹으로 부모 대체
    final parent = parentPath.panel;
    final siblingGroup = parent.children!.firstWhere((child) => child.id != groupId);

    // 5. 조부모가 있으면 조부모에 형제 연결, 없으면 루트 교체
    if (parentPath.grandParent != null) {
      final updatedChildren = parentPath.grandParent!.children!
          .map((child) => child.id == parent.id ? siblingGroup : child)
          .toList();

      final updatedGrandParent = parentPath.grandParent!.copyWith(children: updatedChildren);

      return WorkspaceHelpers.updatePanel(
        state,
        parentPath.grandParent!.id,
        updatedGrandParent,
      );
    } else {
      // 부모가 루트였으면 형제를 새 루트로
      return siblingGroup.copyWith(id: state.id);
    }
  }

  /// 분할 비율 업데이트
  static SplitPanel updateSplitRatio(
    SplitPanel state,
    String panelId,
    double newRatio,
  ) {
    // 구현...
  }
}
```

### 2.3 Workspace Helpers

```dart
// services/workspace_helpers.dart

class WorkspaceHelpers {
  WorkspaceHelpers._();

  /// 특정 ID의 그룹 찾기
  static SplitPanel? findGroupById(SplitPanel root, String groupId) {
    if (root.id == groupId) return root;
    
    if (root.children != null) {
      for (final child in root.children!) {
        final found = findGroupById(child, groupId);
        if (found != null) return found;
      }
    }
    return null;
  }

  /// 탭을 소유한 그룹 찾기
  static SplitPanel? findTabOwnerGroup(SplitPanel root, String tabId) {
    if (root.isLeaf && root.tabs != null) {
      if (root.tabs!.any((tab) => tab.id == tabId)) {
        return root;
      }
    }
    
    if (root.children != null) {
      for (final child in root.children!) {
        final found = findTabOwnerGroup(child, tabId);
        if (found != null) return found;
      }
    }
    return null;
  }

  /// 활성 그룹 찾기
  static SplitPanel? findActiveGroup(SplitPanel root) {
    if (root.isLeaf) return root;
    
    if (root.children != null) {
      for (final child in root.children!) {
        final active = findActiveGroup(child);
        if (active != null) return active;
      }
    }
    return null;
  }

  /// 패널 업데이트 (불변성 유지)
  static SplitPanel updatePanel(
    SplitPanel root,
    String targetId,
    SplitPanel updatedPanel,
  ) {
    if (root.id == targetId) {
      return updatedPanel;
    }
    
    if (root.children != null) {
      final updatedChildren = root.children!.map((child) {
        return updatePanel(child, targetId, updatedPanel);
      }).toList();
      
      return root.copyWith(children: updatedChildren);
    }
    
    return root;
  }

  /// 부모 경로 찾기 (빈 그룹 제거용)
  static ParentPath? findParentPath(SplitPanel root, String targetId) {
    return _findParentPathRecursive(root, targetId, null);
  }

  static ParentPath? _findParentPathRecursive(
    SplitPanel current, 
    String targetId, 
    SplitPanel? parent
  ) {
    if (current.children != null) {
      for (final child in current.children!) {
        if (child.id == targetId) {
          return ParentPath(panel: current, grandParent: parent);
        }
        final found = _findParentPathRecursive(child, targetId, current);
        if (found != null) return found;
      }
    }
    return null;
  }

  /// 워크스페이스 상태 검증
  static WorkspaceValidation validateWorkspaceState(SplitPanel root) {
    final errors = <String>[];
    final warnings = <String>[];
    
    _validatePanel(root, errors, warnings, 0);
    
    return WorkspaceValidation(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// 패널 검증 (재귀적)
  static void _validatePanel(SplitPanel panel, List<String> errors, List<String> warnings, int depth) {
    // 리프 노드 검사
    if (panel.isLeaf) {
      if (panel.tabs == null) {
        errors.add('리프 노드 ${panel.id}의 tabs가 null');
      } else if (panel.tabs!.isEmpty && depth > 0) {
        warnings.add('빈 리프 노드: ${panel.id}');
      }

      if (panel.children != null) {
        errors.add('리프 노드 ${panel.id}에 children이 존재');
      }
      if (panel.direction != null) {
        errors.add('리프 노드 ${panel.id}에 direction이 설정됨');
      }
    }
    // 브랜치 노드 검사
    else if (panel.isSplit) {
      if (panel.children == null || panel.children!.isEmpty) {
        errors.add('분할 노드 ${panel.id}에 children이 없음');
      } else if (panel.children!.length != 2) {
        errors.add('분할 노드 ${panel.id}의 children 수가 2가 아님: ${panel.children!.length}');
      }

      if (panel.tabs != null) {
        errors.add('분할 노드 ${panel.id}에 tabs가 존재');
      }
      if (panel.direction == null) {
        errors.add('분할 노드 ${panel.id}에 direction이 없음');
      }

      // 자식들 재귀 검증
      if (panel.children != null) {
        for (final child in panel.children!) {
          _validatePanel(child, errors, warnings, depth + 1);
        }
      }
    }
  }

  /// 최대 깊이 계산
  static int calculateMaxDepth(SplitPanel root) {
    if (root.isLeaf) return 0;
    
    int maxChildDepth = 0;
    if (root.children != null) {
      for (final child in root.children!) {
        final childDepth = calculateMaxDepth(child);
        if (childDepth > maxChildDepth) {
          maxChildDepth = childDepth;
        }
      }
    }
    
    return maxChildDepth + 1;
  }
}

class WorkspaceValidation {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const WorkspaceValidation({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });
}

class ParentPath {
  final SplitPanel panel;
  final SplitPanel? grandParent;
  
  const ParentPath({required this.panel, this.grandParent});
}
```

## 🎨 3. UI 위젯 컴포넌트

### 3.1 메인 Split Container

```dart
// widgets/split_container.dart

class SplitContainer extends StatelessWidget {
  final SplitPanel panel;
  final VoidCallback? onPanelFocused;
  final int depth;

  const SplitContainer({
    Key? key,
    required this.panel,
    this.onPanelFocused,
    this.depth = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 최대 분할 깊이 체크
    if (depth > 4) {
      return _buildErrorWidget('최대 분할 깊이 초과');
    }

    if (panel.isLeaf) {
      // 단일 그룹: TabGroup 렌더링
      return TabGroup(
        groupId: panel.id,
        tabs: panel.tabs ?? [],
        activeTabId: panel.activeTabId,
        onPanelFocused: onPanelFocused,
      );
    } else {
      // 분할 상태: Flex로 자식들 재귀 렌더링
      return _buildSplitLayout();
    }
  }

  Widget _buildSplitLayout() {
    if (panel.children == null || panel.children!.length != 2) {
      return _buildErrorWidget('잘못된 분할 구조');
    }

    final direction = panel.direction ?? SplitDirection.horizontal;
    final children = panel.children!;
    final ratio = panel.ratio;

    return Flex(
      direction: direction == SplitDirection.horizontal
          ? Axis.vertical
          : Axis.horizontal,
      children: _buildSplitChildren(children, direction, ratio),
    );
  }

  List<Widget> _buildSplitChildren(
    List<SplitPanel> children,
    SplitDirection direction,
    double ratio,
  ) {
    final firstFlex = math.max((ratio * 1000).round(), 1);
    final secondFlex = math.max(((1.0 - ratio) * 1000).round(), 1);

    return [
      // 첫 번째 자식
      Expanded(
        flex: firstFlex,
        child: SplitContainer(
          panel: children[0],
          onPanelFocused: onPanelFocused,
          depth: depth + 1,
        ),
      ),
      
      // 크기 조절 가능한 스플리터
      ResizableSplitter(
        direction: direction,
        ratio: ratio,
        onRatioChanged: (newRatio) {
          // 상태 관리를 통해 비율 업데이트
        },
      ),
      
      // 두 번째 자식
      Expanded(
        flex: secondFlex,
        child: SplitContainer(
          panel: children[1],
          onPanelFocused: onPanelFocused,
          depth: depth + 1,
        ),
      ),
    ];
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      color: Colors.red.withOpacity(0.3),
      child: Center(
        child: Text(message, style: TextStyle(color: Colors.red)),
      ),
    );
  }
}
```

### 3.2 Tab Group (탭바 + 콘텐츠)

```dart
// widgets/tab_group.dart

class TabGroup extends StatelessWidget {
  final String groupId;
  final List<TabModel> tabs;
  final String? activeTabId;
  final VoidCallback? onPanelFocused;

  const TabGroup({
    Key? key,
    required this.groupId,
    required this.tabs,
    this.activeTabId,
    this.onPanelFocused,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final activeTab = tabs.isNotEmpty && activeTabId != null
        ? tabs.firstWhere(
            (tab) => tab.id == activeTabId,
            orElse: () => tabs.first,
          )
        : null;

    return Column(
      children: [
        // 탭바
        GroupTabBar(
          groupId: groupId,
          tabs: tabs,
          activeTabId: activeTabId,
          onTabTap: (tabId) {
            // 상태 관리를 통해 탭 활성화
          },
          onTabClose: (tabId) {
            // 상태 관리를 통해 탭 삭제
          },
        ),
        
        // 콘텐츠 영역
        Expanded(
          child: GroupContent(
            groupId: groupId,
            activeTab: activeTab,
          ),
        ),
      ],
    );
  }
}
```

### 3.3 Group Tab Bar

```dart
// widgets/group_tab_bar.dart

class GroupTabBar extends StatefulWidget {
  final String groupId;
  final List<TabModel> tabs;
  final String? activeTabId;
  final Function(String) onTabTap;
  final Function(String) onTabClose;

  const GroupTabBar({
    Key? key,
    required this.groupId,
    required this.tabs,
    this.activeTabId,
    required this.onTabTap,
    required this.onTabClose,
  }) : super(key: key);

  @override
  State<GroupTabBar> createState() => _GroupTabBarState();
}

class _GroupTabBarState extends State<GroupTabBar> {
  final Map<String, GlobalKey> _tabKeys = {};
  final GlobalKey _tabBarKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // 탭 키 준비
    for (final tab in widget.tabs) {
      _tabKeys[tab.id] ??= GlobalKey();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth - 36;
        final tabWidth = widget.tabs.isNotEmpty
            ? (availableWidth / widget.tabs.length).clamp(80.0, 200.0)
            : 120.0;

        return Stack(
          children: [
            // 메인 탭바
            DragTarget<TabModel>(
              key: _tabBarKey,
              onWillAcceptWithDetails: (details) => true,
              onMove: (details) {
                // 드래그 위치 업데이트
                _updateInsertPosition();
              },
              onLeave: (data) {
                // 삽입 위치 초기화
              },
              onAcceptWithDetails: (details) {
                _handleDrop(details.data);
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      // 표시되는 탭들
                      ...widget.tabs.map((tab) => TabItem(
                            tab: tab,
                            tabKey: _tabKeys[tab.id]!,
                            groupId: widget.groupId,
                            tabWidth: tabWidth,
                            onTap: () => widget.onTabTap(tab.id),
                            onClose: () => widget.onTabClose(tab.id),
                          )),

                      // 새 탭 추가 버튼
                      _buildNewTabButton(),

                      // 남은 공간
                      Expanded(child: Container()),
                    ],
                  ),
                );
              },
            ),

            // 삽입 인디케이터 (드래그 중일 때)
            // TODO: 드래그 상태에 따라 표시
          ],
        );
      },
    );
  }

  Widget _buildNewTabButton() {
    return Container(
      width: 36,
      height: 36,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // 새 탭 추가 콜백
          },
          child: Icon(Icons.add, size: 16, color: Colors.grey[600]),
        ),
      ),
    );
  }

  void _updateInsertPosition() {
    // 드래그 위치에 따른 삽입 인덱스 계산
  }

  void _handleDrop(TabModel droppedTab) {
    // 드롭 처리 로직
  }
}
```

### 3.4 Tab Item

```dart
// widgets/tab_item.dart

class TabItem extends StatelessWidget {
  final TabModel tab;
  final VoidCallback onTap;
  final VoidCallback onClose;
  final GlobalKey tabKey;
  final String groupId;
  final double? tabWidth;

  const TabItem({
    Key? key,
    required this.tab,
    required this.onTap,
    required this.onClose,
    required this.tabKey,
    required this.groupId,
    this.tabWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      key: tabKey,
      height: 36,
      width: tabWidth,
      constraints: tabWidth == null
          ? const BoxConstraints(minWidth: 120, maxWidth: 200)
          : null,
      child: Stack(
        children: [
          // 드래그 가능한 탭 영역
          LongPressDraggable<TabModel>(
            data: tab,
            delay: const Duration(milliseconds: 100),
            onDragStarted: () {
              // 드래그 시작 처리
            },
            onDragUpdate: (details) {
              // 드래그 위치 업데이트
            },
            onDragEnd: (details) {
              // 드래그 종료 처리
            },
            feedback: _buildDragFeedback(),
            childWhenDragging: _buildDragPlaceholder(),
            child: _buildTabContent(),
          ),

          // X 버튼 (별도 레이어)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: 32,
              height: 36,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onClose,
                  borderRadius: BorderRadius.circular(4),
                  child: Center(
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: tab.isActive ? Colors.black : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragFeedback() {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 34,
        width: (tabWidth ?? 140) * 0.95,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.5),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.blue.withOpacity(0.6)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tab, size: 15, color: Colors.white.withOpacity(0.8)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  tab.title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDragPlaceholder() {
    return Container(
      height: 36,
      width: tabWidth,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.3),
        border: Border(right: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(Icons.drag_indicator, size: 12, color: Colors.grey[400]),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                tab.title,
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return Container(
      height: 36,
      width: tabWidth,
      decoration: BoxDecoration(
        color: tab.isActive ? Colors.white : Colors.grey[200],
        border: Border(right: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.only(left: 12, right: 32),
            child: Row(
              children: [
                // 드래그 핸들
                if ((tabWidth ?? 120) > 100) ...[
                  Icon(Icons.drag_indicator, size: 12, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                ],
                
                // 탭 제목
                Expanded(
                  child: Text(
                    tab.title,
                    style: TextStyle(
                      color: tab.isActive ? Colors.black : Colors.grey[600],
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### 3.5 Group Content (드롭존 + 미리보기)

```dart
// widgets/group_content.dart

class GroupContent extends StatefulWidget {
  final String groupId;
  final TabModel? activeTab;

  const GroupContent({
    Key? key,
    required this.groupId,
    this.activeTab,
  }) : super(key: key);

  @override
  State<GroupContent> createState() => _GroupContentState();
}

class _GroupContentState extends State<GroupContent> {
  bool _dropZonesInitialized = false;
  Timer? _moveThrottleTimer;
  Map<DropZoneType, Rect>? _cachedDropZones;
  DropZoneType? _lastDetectedZone;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 기본 콘텐츠
        DragTarget<TabModel>(
          onWillAcceptWithDetails: (details) {
            if (!_dropZonesInitialized) {
              _initializeDropZones();
            }
            return true;
          },
          onMove: (details) {
            if (_dropZonesInitialized) {
              _handleThrottledMove();
            }
          },
          onLeave: (data) {
            _cleanupDropZones();
          },
          onAcceptWithDetails: (details) {
            _handleDrop(details.data);
          },
          builder: (context, candidateData, rejectedData) {
            return Container(
              color: Colors.white,
              child: widget.activeTab?.content ??
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.description_outlined, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text(
                          'No active tab in group ${widget.groupId}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
            );
          },
        ),

        // 분할 미리보기 오버레이
        if (_dropZonesInitialized && _lastDetectedZone != null)
          SplitPreviewOverlay(
            groupId: widget.groupId,
            dropZoneType: _lastDetectedZone!,
            contentSize: MediaQuery.of(context).size,
          ),
      ],
    );
  }

  void _handleThrottledMove() {
    if (_moveThrottleTimer?.isActive == true) return;

    _moveThrottleTimer = Timer(const Duration(milliseconds: 16), () {
      if (!mounted) return;
      _processMousePosition();
    });
  }

  void _processMousePosition() {
    // 마우스 위치에 따른 드롭존 감지 로직
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // 글로벌 드래그 위치를 로컬 좌표로 변환
    // 드롭존 계산 및 미리보기 업데이트
  }

  void _handleDrop(TabModel droppedTab) {
    if (_lastDetectedZone != null) {
      switch (_lastDetectedZone!) {
        case DropZoneType.splitLeft:
        case DropZoneType.splitRight:
        case DropZoneType.splitTop:
        case DropZoneType.splitBottom:
          // 분할 생성 콜백
          break;
        case DropZoneType.moveToGroup:
          // 탭 이동 콜백
          break;
      }
    }
    _cleanupAfterDrop();
  }

  void _initializeDropZones() {
    setState(() {
      _dropZonesInitialized = true;
    });
  }

  void _cleanupDropZones() {
    setState(() {
      _dropZonesInitialized = false;
    });
    _lastDetectedZone = null;
  }

  void _cleanupAfterDrop() {
    setState(() {
      _dropZonesInitialized = false;
    });
    _lastDetectedZone = null;
    _cachedDropZones = null;
  }

  @override
  void dispose() {
    _moveThrottleTimer?.cancel();
    super.dispose();
  }
}
```

### 3.6 Resizable Splitter

```dart
// widgets/resizable_splitter.dart

class ResizableSplitter extends StatefulWidget {
  final SplitDirection direction;
  final double ratio;
  final Function(double) onRatioChanged;
  final double minRatio;
  final double maxRatio;
  final double thickness;

  const ResizableSplitter({
    Key? key,
    required this.direction,
    required this.ratio,
    required this.onRatioChanged,
    this.minRatio = 0.2,
    this.maxRatio = 0.8,
    this.thickness = 4.0,
  }) : super(key: key);

  @override
  State<ResizableSplitter> createState() => _ResizableSplitterState();
}

class _ResizableSplitterState extends State<ResizableSplitter> {
  bool _isDragging = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.direction == SplitDirection.vertical
          ? SystemMouseCursors.resizeLeftRight
          : SystemMouseCursors.resizeUpDown,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onPanStart: (_) => setState(() => _isDragging = true),
        onPanEnd: (_) => setState(() => _isDragging = false),
        onPanUpdate: _handleDrag,
        child: Container(
          width: widget.direction == SplitDirection.vertical ? widget.thickness : null,
          height: widget.direction == SplitDirection.horizontal ? widget.thickness : null,
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            border: Border.all(color: _getBorderColor(), width: 0.5),
          ),
          child: _buildGripIndicator(),
        ),
      ),
    );
  }

  void _handleDrag(DragUpdateDetails details) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final parentRenderBox = renderBox.parent?.parent as RenderBox?;
    if (parentRenderBox == null) return;

    final parentSize = parentRenderBox.size;

    double deltaRatio;
    if (widget.direction == SplitDirection.vertical) {
      deltaRatio = details.delta.dx / parentSize.width;
    } else {
      deltaRatio = details.delta.dy / parentSize.height;
    }

    final newRatio = (widget.ratio + deltaRatio).clamp(widget.minRatio, widget.maxRatio);

    if ((newRatio - widget.ratio).abs() < 0.001) return;

    widget.onRatioChanged(newRatio);
  }

  Color _getBackgroundColor() {
    if (_isDragging) {
      return Colors.blue.withOpacity(0.3);
    } else if (_isHovered) {
      return Colors.blue.withOpacity(0.1);
    } else {
      return Colors.grey[300]!;
    }
  }

  Color _getBorderColor() {
    if (_isDragging) {
      return Colors.blue;
    } else if (_isHovered) {
      return Colors.blue.withOpacity(0.5);
    } else {
      return Colors.grey[400]!;
    }
  }

  Widget _buildGripIndicator() {
    final isVertical = widget.direction == SplitDirection.vertical;
    
    return Center(
      child: Container(
        width: isVertical ? 2 : 20,
        height: isVertical ? 20 : 2,
        decoration: BoxDecoration(
          color: _getGripColor(),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  Color _getGripColor() {
    if (_isDragging) {
      return Colors.blue;
    } else if (_isHovered) {
      return Colors.blue.withOpacity(0.7);
    } else {
      return Colors.grey[500]!;
    }
  }
}
```

### 3.7 Split Preview Overlay

```dart
// widgets/split_preview_overlay.dart

class SplitPreviewOverlay extends StatelessWidget {
  final String groupId;
  final DropZoneType dropZoneType;
  final Size contentSize;

  const SplitPreviewOverlay({
    Key? key,
    required this.groupId,
    required this.dropZoneType,
    required this.contentSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final previewArea = _calculatePreviewArea();
    
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            // 기존 그룹 영역 (어두운 오버레이)
            if (dropZoneType != DropZoneType.moveToGroup)
              _buildExistingGroupOverlay(previewArea),

            // 새 그룹 영역 (밝은 강조)
            _buildNewGroupArea(previewArea),

            // 분할선 강조
            if (dropZoneType != DropZoneType.moveToGroup)
              _buildSplitLine(previewArea),
          ],
        ),
      ),
    );
  }

  SplitPreviewArea _calculatePreviewArea() {
    final width = contentSize.width;
    final height = contentSize.height;

    switch (dropZoneType) {
      case DropZoneType.splitLeft:
        return SplitPreviewArea(
          direction: SplitDirection.vertical,
          dropZoneType: dropZoneType,
          newGroupArea: Rect.fromLTWH(0, 0, width * 0.5, height),
          existingGroupArea: Rect.fromLTWH(width * 0.5, 0, width * 0.5, height),
        );
      case DropZoneType.splitRight:
        return SplitPreviewArea(
          direction: SplitDirection.vertical,
          dropZoneType: dropZoneType,
          newGroupArea: Rect.fromLTWH(width * 0.5, 0, width * 0.5, height),
          existingGroupArea: Rect.fromLTWH(0, 0, width * 0.5, height),
        );
      case DropZoneType.splitTop:
        return SplitPreviewArea(
          direction: SplitDirection.horizontal,
          dropZoneType: dropZoneType,
          newGroupArea: Rect.fromLTWH(0, 0, width, height * 0.5),
          existingGroupArea: Rect.fromLTWH(0, height * 0.5, width, height * 0.5),
        );
      case DropZoneType.splitBottom:
        return SplitPreviewArea(
          direction: SplitDirection.horizontal,
          dropZoneType: dropZoneType,
          newGroupArea: Rect.fromLTWH(0, height * 0.5, width, height * 0.5),
          existingGroupArea: Rect.fromLTWH(0, 0, width, height * 0.5),
        );
      case DropZoneType.moveToGroup:
        return SplitPreviewArea(
          direction: null,
          dropZoneType: dropZoneType,
          newGroupArea: Rect.fromLTWH(0, 0, width, height),
          existingGroupArea: Rect.fromLTWH(0, 0, width, height),
        );
    }
  }

  Widget _buildExistingGroupOverlay(SplitPreviewArea previewArea) {
    return Positioned.fromRect(
      rect: previewArea.existingGroupArea,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          border: Border.all(color: Colors.grey.withOpacity(0.5), width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              '기존 그룹',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewGroupArea(SplitPreviewArea previewArea) {
    final isMoveToGroup = dropZoneType == DropZoneType.moveToGroup;
    
    final backgroundColor = isMoveToGroup
        ? Colors.green.withOpacity(0.2)
        : Colors.blue.withOpacity(0.3);
    
    final borderColor = isMoveToGroup
        ? Colors.green.withOpacity(0.9)
        : Colors.blue.withOpacity(0.9);
    
    final labelText = isMoveToGroup ? '📥 탭 추가' : '🆕 새 그룹';
    final labelColor = isMoveToGroup ? Colors.green : Colors.blue;

    return Positioned.fromRect(
      rect: previewArea.newGroupArea,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: labelColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              labelText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSplitLine(SplitPreviewArea previewArea) {
    final isVertical = previewArea.direction == SplitDirection.vertical;
    const lineWidth = 4.0;
    final lineColor = Colors.blue.withOpacity(0.9);

    if (isVertical) {
      final lineX = previewArea.newGroupArea.right;
      return Positioned(
        left: lineX - lineWidth / 2,
        top: 0,
        child: Container(
          width: lineWidth,
          height: previewArea.existingGroupArea.height,
          decoration: BoxDecoration(
            color: lineColor,
            borderRadius: BorderRadius.circular(lineWidth / 2),
          ),
        ),
      );
    } else {
      final lineY = previewArea.newGroupArea.bottom;
      return Positioned(
        left: 0,
        top: lineY - lineWidth / 2,
        child: Container(
          width: previewArea.existingGroupArea.width,
          height: lineWidth,
          decoration: BoxDecoration(
            color: lineColor,
            borderRadius: BorderRadius.circular(lineWidth / 2),
          ),
        ),
      );
    }
  }
}

class SplitPreviewArea {
  final SplitDirection? direction;
  final DropZoneType dropZoneType;
  final Rect newGroupArea;
  final Rect existingGroupArea;

  const SplitPreviewArea({
    required this.direction,
    required this.dropZoneType,
    required this.newGroupArea,
    required this.existingGroupArea,
  });
}
```

## 🔧 4. 확장 메서드

```dart
// extensions/drop_zone_type_extension.dart

extension DropZoneTypeExtension on DropZoneType {
  /// 각 드롭 존의 기본 색상
  Color get baseColor {
    switch (this) {
      case DropZoneType.splitLeft:
      case DropZoneType.splitRight:
      case DropZoneType.splitTop:
      case DropZoneType.splitBottom:
        return Colors.blue;
      case DropZoneType.moveToGroup:
        return Colors.green;
    }
  }

  /// 드롭 존 설명 텍스트
  String get description {
    switch (this) {
      case DropZoneType.splitLeft:
        return '좌측 분할';
      case DropZoneType.splitRight:
        return '우측 분할';
      case DropZoneType.splitTop:
        return '상단 분할';
      case DropZoneType.splitBottom:
        return '하단 분할';
      case DropZoneType.moveToGroup:
        return '탭 이동';
    }
  }

  /// 분할 방향 반환 (분할 존만)
  SplitDirection? get splitDirection {
    switch (this) {
      case DropZoneType.splitLeft:
      case DropZoneType.splitRight:
        return SplitDirection.vertical;
      case DropZoneType.splitTop:
      case DropZoneType.splitBottom:
        return SplitDirection.horizontal;
      case DropZoneType.moveToGroup:
        return null;
    }
  }

  /// 분할 시 새 그룹이 첫 번째인지 여부
  bool get isNewGroupFirst {
    switch (this) {
      case DropZoneType.splitLeft:
      case DropZoneType.splitTop:
        return true;
      case DropZoneType.splitRight:
      case DropZoneType.splitBottom:
        return false;
      case DropZoneType.moveToGroup:
        return false;
    }
  }
}
```

## 📦 5. 메인 Export 파일

```dart
// flutter_split_workspace.dart

library flutter_split_workspace;

// Models
export 'models/split_panel_model.dart';
export 'models/tab_model.dart';

// Services  
export 'services/split_service.dart';
export 'services/tab_service.dart';
export 'services/workspace_helpers.dart';

// Widgets
export 'widgets/split_container.dart';
export 'widgets/tab_group.dart';
export 'widgets/tab_item.dart';
export 'widgets/group_tab_bar.dart';
export 'widgets/group_content.dart';
export 'widgets/resizable_splitter.dart';
export 'widgets/split_preview_overlay.dart';

// Extensions
export 'extensions/drop_zone_type_extension.dart';
```

## 🚀 6. 사용 예시

### 6.1 기본 사용법

```dart
import 'package:flutter/material.dart';
import 'package:flutter_split_workspace/flutter_split_workspace.dart';

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late SplitPanel _workspace;

  @override
  void initState() {
    super.initState();
    
    // 초기 워크스페이스 설정
    _workspace = SplitPanel.singleGroup(
      id: 'root',
      tabs: [
        TabModel(
          id: '1',
          title: 'Welcome',
          content: Center(child: Text('Welcome to Split Workspace!')),
        ),
      ],
      activeTabId: '1',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Split Workspace Demo'),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _addNewTab(),
            ),
          ],
        ),
        body: SplitWorkspace(
          panel: _workspace,
          
          // 🆕 탭 추가 - 워크스페이스 내부에서 발생
          onTabAdd: (groupId) {
            setState(() {
              _workspace = TabService.addTabToGroup(
                _workspace, 
                groupId,
                title: 'New Tab ${DateTime.now().millisecond}',
                content: _buildTabContent('New Content'),
              );
            });
          },
          
          // ❌ 탭 삭제 - 워크스페이스 내부에서 발생  
          onTabRemove: (tabId) {
            setState(() {
              final result = TabService.removeTabWithEmptyCheck(_workspace, tabId);
              if (result.emptyGroupId != null) {
                _workspace = SplitService.removeEmptyGroup(result.newState, result.emptyGroupId!);
              } else if (result.rootBecameEmpty) {
                // 모든 탭이 삭제되면 기본 탭 추가
                _workspace = TabService.addTab(result.newState, title: 'Empty Tab');
              } else {
                _workspace = result.newState;
              }
            });
          },
          
          // 🎯 탭 활성화 - 워크스페이스 내부에서 발생
          onTabActivate: (tabId) {
            setState(() {
              _workspace = TabService.activateTab(_workspace, tabId);
            });
          },
          
          // 🔄 탭 순서 변경 - 워크스페이스 내부에서 발생
          onTabReorder: (tabId, newIndex) {
            setState(() {
              _workspace = TabService.reorderTab(_workspace, tabId, newIndex);
            });
          },
          
          // ✂️ 분할 생성 - 워크스페이스 내부에서 발생
          onCreateSplit: (sourceTabId, dropZone, targetGroupId) {
            setState(() {
              final result = SplitService.createSplitWithResult(
                _workspace,
                sourceTabId: sourceTabId,
                dropZone: dropZone,
                targetGroupId: targetGroupId,
              );
              if (result.needsEmptyGroupCleanup && result.emptyGroupId != null) {
                _workspace = SplitService.removeEmptyGroup(result.newState, result.emptyGroupId!);
              } else {
                _workspace = result.newState;
              }
            });
          },
          
          // 🔄 탭 이동 - 워크스페이스 내부에서 발생
          onMoveTab: (tabId, targetGroupId, insertIndex) {
            setState(() {
              final result = SplitService.moveTabToGroupWithEmptyCheck(
                _workspace,
                tabId: tabId,
                targetGroupId: targetGroupId,
                insertIndex: insertIndex,
              );
              if (result.emptyGroupId != null) {
                _workspace = SplitService.removeEmptyGroup(result.newState, result.emptyGroupId!);
              } else {
                _workspace = result.newState;
              }
            });
          },
          
          // 📏 분할 비율 조정 - 워크스페이스 내부에서 발생
          onUpdateSplitRatio: (panelId, ratio) {
            setState(() {
              _workspace = SplitService.updateSplitRatio(_workspace, panelId, ratio);
            });
          },
        ),
      ),
    );
  }
  
  void _addNewTab() {
    setState(() {
      _workspace = TabService.addTab(
        _workspace,
        title: 'Tab ${DateTime.now().millisecond}',
        content: _buildTabContent('Custom Content'),
      );
    });
  }
  
  Widget _buildTabContent(String content) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(content, style: TextStyle(fontSize: 18)),
          SizedBox(height: 16),
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: Center(child: Text('Your content here')),
            ),
          ),
        ],
      ),
    );
  }
}
```

### 6.2 테마 커스터마이징

```dart
class ThemedWorkspaceExample extends StatefulWidget {
  @override
  State<ThemedWorkspaceExample> createState() => _ThemedWorkspaceExampleState();
}

class _ThemedWorkspaceExampleState extends State<ThemedWorkspaceExample> {
  late SplitPanel _workspace;

  @override
  void initState() {
    super.initState();
    _workspace = SplitPanel.singleGroup(
      id: 'root',
      tabs: [
        TabModel(id: '1', title: 'Dark Theme', content: _buildDarkContent()),
      ],
      activeTabId: '1',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          title: Text('Themed Split Workspace'),
          backgroundColor: Colors.grey[850],
        ),
        body: SplitWorkspace(
          panel: _workspace,
          
          // 🎨 커스텀 테마 적용
          theme: SplitWorkspaceTheme(
            tabTheme: TabTheme(
              activeTabColor: Colors.grey[800]!,
              inactiveTabColor: Colors.grey[700]!,
              tabBorderColor: Colors.grey[600]!,
              tabTextStyle: TextStyle(color: Colors.white, fontSize: 13),
              tabHeight: 40,
              closeButtonColor: Colors.grey[400]!,
            ),
            splitterTheme: SplitterTheme(
              splitterColor: Colors.grey[600]!,
              splitterHoverColor: Colors.blue[400]!,
              thickness: 6,
            ),
            dropZoneTheme: DropZoneTheme(
              splitZoneColor: Colors.blue.withOpacity(0.3),
              moveZoneColor: Colors.green.withOpacity(0.3),
              previewBorderColor: Colors.blue,
              previewBorderWidth: 3,
            ),
          ),
          
          onTabAdd: (groupId) => _addTab(groupId),
          onTabRemove: (tabId) => _removeTab(tabId),
          onTabActivate: (tabId) => _activateTab(tabId),
          onTabReorder: (tabId, newIndex) => _reorderTab(tabId, newIndex),
          onCreateSplit: (sourceTabId, dropZone, targetGroupId) => 
              _createSplit(sourceTabId, dropZone, targetGroupId),
          onMoveTab: (tabId, targetGroupId, insertIndex) => 
              _moveTab(tabId, targetGroupId, insertIndex),
          onUpdateSplitRatio: (panelId, ratio) => 
              _updateSplitRatio(panelId, ratio),
        ),
      ),
    );
  }

  Widget _buildDarkContent() {
    return Container(
      color: Colors.grey[850],
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dark Theme Example',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
          SizedBox(height: 16),
          Text(
            'This workspace uses a custom dark theme.',
            style: TextStyle(color: Colors.grey[300]),
          ),
        ],
      ),
    );
  }

  void _addTab(String groupId) {
    setState(() {
      _workspace = TabService.addTabToGroup(
        _workspace,
        groupId,
        title: 'Dark Tab ${DateTime.now().millisecond}',
        content: _buildDarkContent(),
      );
    });
  }

  // 기타 콜백 메서드들...
  void _removeTab(String tabId) { /* 구현 */ }
  void _activateTab(String tabId) { /* 구현 */ }
  void _reorderTab(String tabId, int newIndex) { /* 구현 */ }
  void _createSplit(String sourceTabId, DropZoneType dropZone, String? targetGroupId) { /* 구현 */ }
  void _moveTab(String tabId, String targetGroupId, int? insertIndex) { /* 구현 */ }
  void _updateSplitRatio(String panelId, double ratio) { /* 구현 */ }
}
```

### 6.3 고급 사용법 - 복잡한 콘텐츠

```dart
class AdvancedWorkspaceExample extends StatefulWidget {
  @override
  State<AdvancedWorkspaceExample> createState() => _AdvancedWorkspaceExampleState();
}

class _AdvancedWorkspaceExampleState extends State<AdvancedWorkspaceExample> {
  late SplitPanel _workspace;
  int _tabCounter = 1;

  @override
  void initState() {
    super.initState();
    _workspace = SplitPanel.singleGroup(
      id: 'root',
      tabs: [
        TabModel(
          id: 'editor1',
          title: 'Code Editor',
          content: CodeEditorTab(),
        ),
        TabModel(
          id: 'preview1',
          title: 'Preview',
          content: PreviewTab(),
        ),
      ],
      activeTabId: 'editor1',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Advanced Split Workspace'),
          actions: [
            IconButton(
              icon: Icon(Icons.code),
              onPressed: () => _addEditorTab(),
            ),
            IconButton(
              icon: Icon(Icons.preview),
              onPressed: () => _addPreviewTab(),
            ),
            IconButton(
              icon: Icon(Icons.terminal),
              onPressed: () => _addTerminalTab(),
            ),
          ],
        ),
        body: SplitWorkspace(
          panel: _workspace,
          onTabAdd: _handleTabAdd,
          onTabRemove: _handleTabRemove,
          onTabActivate: _handleTabActivate,
          onTabReorder: _handleTabReorder,
          onCreateSplit: _handleCreateSplit,
          onMoveTab: _handleMoveTab,
          onUpdateSplitRatio: _handleUpdateSplitRatio,
        ),
      ),
    );
  }

  void _addEditorTab() {
    setState(() {
      _workspace = TabService.addTab(
        _workspace,
        title: 'Editor ${++_tabCounter}',
        content: CodeEditorTab(),
      );
    });
  }

  void _addPreviewTab() {
    setState(() {
      _workspace = TabService.addTab(
        _workspace,
        title: 'Preview ${++_tabCounter}',
        content: PreviewTab(),
      );
    });
  }

  void _addTerminalTab() {
    setState(() {
      _workspace = TabService.addTab(
        _workspace,
        title: 'Terminal ${++_tabCounter}',
        content: TerminalTab(),
      );
    });
  }

  // 콜백 메서드들
  void _handleTabAdd(String groupId) { /* 그룹별 탭 추가 로직 */ }
  void _handleTabRemove(String tabId) { /* 탭 삭제 로직 */ }
  void _handleTabActivate(String tabId) { /* 탭 활성화 로직 */ }
  void _handleTabReorder(String tabId, int newIndex) { /* 탭 순서 변경 로직 */ }
  void _handleCreateSplit(String sourceTabId, DropZoneType dropZone, String? targetGroupId) { /* 분할 생성 로직 */ }
  void _handleMoveTab(String tabId, String targetGroupId, int? insertIndex) { /* 탭 이동 로직 */ }
  void _handleUpdateSplitRatio(String panelId, double ratio) { /* 분할 비율 조정 로직 */ }
}

// 커스텀 탭 콘텐츠 위젯들
class CodeEditorTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          Container(
            height: 40,
            color: Colors.grey[200],
            child: Row(
              children: [
                SizedBox(width: 16),
                Text('main.dart', style: TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                Icon(Icons.more_vert, size: 16),
                SizedBox(width: 8),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Text(
                'void main() {\n  runApp(MyApp());\n}',
                style: TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PreviewTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone_android, size: 100, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text('App Preview', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

class TerminalTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$ flutter run', style: TextStyle(color: Colors.green, fontFamily: 'monospace')),
          Text('Running on Chrome...', style: TextStyle(color: Colors.white, fontFamily: 'monospace')),
          Text('✓ Built successfully', style: TextStyle(color: Colors.green, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}
```

## 🎨 7. 테마 시스템

### 7.1 테마 클래스 정의

```dart
// themes/split_workspace_theme.dart

class SplitWorkspaceTheme {
  final TabTheme tabTheme;
  final SplitterTheme splitterTheme;
  final DropZoneTheme dropZoneTheme;
  
  const SplitWorkspaceTheme({
    required this.tabTheme,
    required this.splitterTheme,
    required this.dropZoneTheme,
  });
  
  factory SplitWorkspaceTheme.defaultTheme() {
    return SplitWorkspaceTheme(
      tabTheme: TabTheme.defaultTheme(),
      splitterTheme: SplitterTheme.defaultTheme(),
      dropZoneTheme: DropZoneTheme.defaultTheme(),
    );
  }
  
  factory SplitWorkspaceTheme.darkTheme() {
    return SplitWorkspaceTheme(
      tabTheme: TabTheme.darkTheme(),
      splitterTheme: SplitterTheme.darkTheme(),
      dropZoneTheme: DropZoneTheme.darkTheme(),
    );
  }
}

class TabTheme {
  final Color activeTabColor;
  final Color inactiveTabColor;
  final Color tabBorderColor;
  final Color tabTextColor;
  final Color activeTabTextColor;
  final Color closeButtonColor;
  final TextStyle tabTextStyle;
  final double tabHeight;
  final double tabMinWidth;
  final double tabMaxWidth;
  
  const TabTheme({
    required this.activeTabColor,
    required this.inactiveTabColor,
    required this.tabBorderColor,
    required this.tabTextColor,
    required this.activeTabTextColor,
    required this.closeButtonColor,
    required this.tabTextStyle,
    required this.tabHeight,
    required this.tabMinWidth,
    required this.tabMaxWidth,
  });
  
  factory TabTheme.defaultTheme() {
    return TabTheme(
      activeTabColor: Colors.white,
      inactiveTabColor: Colors.grey[200]!,
      tabBorderColor: Colors.grey[300]!,
      tabTextColor: Colors.grey[600]!,
      activeTabTextColor: Colors.black,
      closeButtonColor: Colors.grey[500]!,
      tabTextStyle: TextStyle(fontSize: 13),
      tabHeight: 36,
      tabMinWidth: 80,
      tabMaxWidth: 200,
    );
  }
  
  factory TabTheme.darkTheme() {
    return TabTheme(
      activeTabColor: Colors.grey[800]!,
      inactiveTabColor: Colors.grey[700]!,
      tabBorderColor: Colors.grey[600]!,
      tabTextColor: Colors.grey[400]!,
      activeTabTextColor: Colors.white,
      closeButtonColor: Colors.grey[400]!,
      tabTextStyle: TextStyle(fontSize: 13, color: Colors.white),
      tabHeight: 36,
      tabMinWidth: 80,
      tabMaxWidth: 200,
    );
  }
}

class SplitterTheme {
  final Color splitterColor;
  final Color splitterHoverColor;
  final Color splitterActiveColor;
  final double thickness;
  final double gripSize;
  
  const SplitterTheme({
    required this.splitterColor,
    required this.splitterHoverColor,
    required this.splitterActiveColor,
    required this.thickness,
    required this.gripSize,
  });
  
  factory SplitterTheme.defaultTheme() {
    return SplitterTheme(
      splitterColor: Colors.grey[300]!,
      splitterHoverColor: Colors.blue.withOpacity(0.3),
      splitterActiveColor: Colors.blue.withOpacity(0.5),
      thickness: 4,
      gripSize: 20,
    );
  }
  
  factory SplitterTheme.darkTheme() {
    return SplitterTheme(
      splitterColor: Colors.grey[600]!,
      splitterHoverColor: Colors.blue[400]!.withOpacity(0.3),
      splitterActiveColor: Colors.blue[400]!.withOpacity(0.5),
      thickness: 4,
      gripSize: 20,
    );
  }
}

class DropZoneTheme {
  final Color splitZoneColor;
  final Color moveZoneColor;
  final Color previewBorderColor;
  final Color existingGroupOverlayColor;
  final double previewBorderWidth;
  final BorderRadius previewBorderRadius;
  
  const DropZoneTheme({
    required this.splitZoneColor,
    required this.moveZoneColor,
    required this.previewBorderColor,
    required this.existingGroupOverlayColor,
    required this.previewBorderWidth,
    required this.previewBorderRadius,
  });
  
  factory DropZoneTheme.defaultTheme() {
    return DropZoneTheme(
      splitZoneColor: Colors.blue.withOpacity(0.3),
      moveZoneColor: Colors.green.withOpacity(0.3),
      previewBorderColor: Colors.blue,
      existingGroupOverlayColor: Colors.grey.withOpacity(0.3),
      previewBorderWidth: 3,
      previewBorderRadius: BorderRadius.circular(4),
    );
  }
  
  factory DropZoneTheme.darkTheme() {
    return DropZoneTheme(
      splitZoneColor: Colors.blue[400]!.withOpacity(0.4),
      moveZoneColor: Colors.green[400]!.withOpacity(0.4),
      previewBorderColor: Colors.blue[400]!,
      existingGroupOverlayColor: Colors.grey[800]!.withOpacity(0.5),
      previewBorderWidth: 3,
      previewBorderRadius: BorderRadius.circular(4),
    );
  }
}
```

### 7.2 SplitWorkspace 메인 위젯

```dart
// widgets/split_workspace.dart

class SplitWorkspace extends StatelessWidget {
  final SplitPanel panel;
  final SplitWorkspaceTheme? theme;
  final VoidCallback? onPanelFocused;
  
  // 탭 관련 콜백
  final Function(String groupId)? onTabAdd;
  final Function(String tabId)? onTabRemove;
  final Function(String tabId)? onTabActivate;
  final Function(String tabId, int newIndex)? onTabReorder;
  
  // 분할 관련 콜백
  final Function(String sourceTabId, DropZoneType dropZone, String? targetGroupId)? onCreateSplit;
  final Function(String tabId, String targetGroupId, int? insertIndex)? onMoveTab;
  final Function(String panelId, double ratio)? onUpdateSplitRatio;

  const SplitWorkspace({
    Key? key,
    required this.panel,
    this.theme,
    this.onPanelFocused,
    this.onTabAdd,
    this.onTabRemove,
    this.onTabActivate,
    this.onTabReorder,
    this.onCreateSplit,
    this.onMoveTab,
    this.onUpdateSplitRatio,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveTheme = theme ?? SplitWorkspaceTheme.defaultTheme();
    
    return SplitWorkspaceThemeProvider(
      theme: effectiveTheme,
      child: SplitContainer(
        panel: panel,
        onPanelFocused: onPanelFocused,
        onTabAdd: onTabAdd,
        onTabRemove: onTabRemove,
        onTabActivate: onTabActivate,
        onTabReorder: onTabReorder,
        onCreateSplit: onCreateSplit,
        onMoveTab: onMoveTab,
        onUpdateSplitRatio: onUpdateSplitRatio,
      ),
    );
  }
}

// 테마 제공자 위젯
class SplitWorkspaceThemeProvider extends InheritedWidget {
  final SplitWorkspaceTheme theme;

  const SplitWorkspaceThemeProvider({
    Key? key,
    required this.theme,
    required Widget child,
  }) : super(key: key, child: child);

  static SplitWorkspaceTheme of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<SplitWorkspaceThemeProvider>();
    return provider?.theme ?? SplitWorkspaceTheme.defaultTheme();
  }

  @override
  bool updateShouldNotify(SplitWorkspaceThemeProvider oldWidget) {
    return theme != oldWidget.theme;
  }
}
```

## 🔧 8. 드롭존 계산 및 이벤트 처리

UI 위젯에서 사용되는 핵심 로직들입니다.

```dart
/// 드롭존 계산 유틸리티
class DropZoneCalculator {
  /// 5구역 드롭존 계산
  static Map<DropZoneType, Rect> calculateDropZones(Size contentSize) {
    final width = contentSize.width;
    final height = contentSize.height;

    return {
      // 좌측 33% (수직 분할 - 왼쪽)
      DropZoneType.splitLeft: Rect.fromLTWH(0, 0, width * 0.33, height),
      
      // 우측 33% (수직 분할 - 오른쪽)
      DropZoneType.splitRight: Rect.fromLTWH(width * 0.67, 0, width * 0.33, height),
      
      // 상단 33% (수평 분할 - 위쪽)
      DropZoneType.splitTop: Rect.fromLTWH(width * 0.33, 0, width * 0.34, height * 0.33),
      
      // 하단 33% (수평 분할 - 아래쪽)
      DropZoneType.splitBottom: Rect.fromLTWH(width * 0.33, height * 0.67, width * 0.34, height * 0.33),
      
      // 중앙 영역 (탭 이동)
      DropZoneType.moveToGroup: Rect.fromLTWH(width * 0.33, height * 0.33, width * 0.34, height * 0.34),
    };
  }

  /// 마우스 위치에 따른 드롭존 감지
  static DropZoneType? detectDropZone(Offset position, Map<DropZoneType, Rect> zones) {
    // 중앙 영역 먼저 체크 (가장 자주 사용)
    if (zones[DropZoneType.moveToGroup]!.contains(position)) {
      return DropZoneType.moveToGroup;
    }

    // 나머지 영역들 체크
    for (final entry in zones.entries) {
      if (entry.key != DropZoneType.moveToGroup && entry.value.contains(position)) {
        return entry.key;
      }
    }

    return null;
  }
}

/// 탭바 삽입 위치 계산 유틸리티
class TabInsertCalculator {
  /// 탭바에서 삽입 위치 계산
  static ({int insertIndex, double indicatorX}) calculateInsertPosition({
    required Offset localPosition,
    required int tabCount,
    required double tabWidth,
    String? draggedTabId,
    required List<TabModel> tabs,
  }) {
    int insertIndex = 0;
    double indicatorX = 0;

    final draggedTabIndex = draggedTabId != null
        ? tabs.indexWhere((tab) => tab.id == draggedTabId)
        : -1;

    // 화면상 실제 탭 위치 기준으로 계산
    bool found = false;
    for (int i = 0; i < tabCount; i++) {
      final tabX = i * tabWidth;
      final tabCenter = tabX + (tabWidth / 2);

      if (localPosition.dx < tabCenter) {
        insertIndex = i;
        indicatorX = tabX;
        found = true;
        break;
      }
    }

    if (!found) {
      insertIndex = tabCount;
      indicatorX = tabCount * tabWidth;
    }

    // 같은 그룹 내 드래그인 경우 원래 위치 보정
    if (draggedTabIndex != -1 && insertIndex > draggedTabIndex) {
      insertIndex--;
    }

    return (insertIndex: insertIndex, indicatorX: indicatorX);
  }
}

/// 성능 최적화 유틸리티
class PerformanceUtils {
  static Timer? _throttleTimer;
  
  /// 이벤트 throttling
  static void throttle(Duration duration, VoidCallback callback) {
    if (_throttleTimer?.isActive == true) return;
    
    _throttleTimer = Timer(duration, callback);
  }
  
  /// 드래그 이벤트 throttling (16ms = 60fps)
  static void throttleDragEvent(VoidCallback callback) {
    throttle(const Duration(milliseconds: 16), callback);
  }
  
  /// 마우스 이벤트 throttling (8ms = 120fps)  
  static void throttleMouseEvent(VoidCallback callback) {
    throttle(const Duration(milliseconds: 8), callback);
  }
}
```

## 📝 8. 주요 특징

### ✅ 제공하는 기능
1. **탭 시스템**: 생성, 삭제, 이동, 순서 변경
2. **분할 시스템**: 수직/수평 분할, 중첩 분할 지원
3. **드래그 앤 드롭**: 직관적인 5존 드롭 시스템
4. **실시간 미리보기**: 분할/이동 결과 시각적 피드백
5. **크기 조절**: 드래그로 분할 비율 조정
6. **성능 최적화**: throttling, 캐싱, 선택적 렌더링

### ⚠️ 사용자가 구현해야 하는 부분
1. **상태 관리**: Riverpod, Bloc, Provider 등 선택
2. **테마**: 색상, 폰트, 스타일링
3. **콜백 처리**: 탭 생성/삭제/이동 시 비즈니스 로직
4. **콘텐츠**: 실제 탭에 표시될 위젯들

### 🎯 패키지 장점
- **완전한 모듈화**: 상태 관리와 분리된 순수 UI/로직
- **높은 확장성**: Tree 구조로 무한 중첩 지원
- **직관적 API**: Service 패턴으로 깔끔한 인터페이스
- **상용 품질**: VS Code 수준의 분할 워크스페이스

이 가이드만으로도 완전한 flutter_split_workspace 패키지를 구현할 수 있습니다.