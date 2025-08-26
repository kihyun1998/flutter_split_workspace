// lib/src/models/drag_data.dart
import 'tab_data.dart';

/// 드래그 중인 탭의 정보를 담는 모델
class DragData {
  final TabData tab;
  final int originalIndex; // 원래 위치
  final String sourceWorkspaceId; // 어느 워크스페이스에서 왔는지

  const DragData({
    required this.tab,
    required this.originalIndex,
    required this.sourceWorkspaceId,
  });

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
