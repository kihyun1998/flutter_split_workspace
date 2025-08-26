// lib/src/widgets/tab_bar_widget.dart (수정)
import 'package:flutter/material.dart';

import '../models/drag_data.dart';
import '../models/tab_data.dart';
import 'tab_item_widget.dart';

class TabBarWidget extends StatefulWidget {
  final List<TabData> tabs;
  final String? activeTabId;
  final Function(String tabId)? onTabTap;
  final Function(String tabId)? onTabClose;
  final VoidCallback? onAddTab;
  final Function(int oldIndex, int newIndex)? onTabReorder; // 순서 변경 콜백 추가
  final String workspaceId; // 워크스페이스 ID 추가

  const TabBarWidget({
    super.key,
    required this.tabs,
    this.activeTabId,
    this.onTabTap,
    this.onTabClose,
    this.onAddTab,
    this.onTabReorder, // 추가
    required this.workspaceId, // 추가
  });

  @override
  State<TabBarWidget> createState() => _TabBarWidgetState();
}

class _TabBarWidgetState extends State<TabBarWidget> {
  int? _dragOverIndex; // 드래그 오버 중인 인덱스
  bool _isDragging = false; // 드래그 중인지 여부

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor, width: 1)),
      ),
      child: DragTarget<DragData>(
        onWillAcceptWithDetails: (details) {
          setState(() {
            _isDragging = true;
          });
          return true;
        },
        onLeave: (data) {
          setState(() {
            _isDragging = false;
            _dragOverIndex = null;
          });
        },
        onMove: (details) {
          _updateDragOverIndex(details.offset);
        },
        onAcceptWithDetails: (details) {
          _handleDrop(details.data);
          setState(() {
            _isDragging = false;
            _dragOverIndex = null;
          });
        },
        builder: (context, candidateData, rejectedData) {
          return Stack(
            children: [
              // 기본 탭바 레이아웃
              Row(
                children: [
                  // 탭들
                  ...widget.tabs.asMap().entries.map((entry) {
                    final index = entry.key;
                    final tab = entry.value;

                    return TabItemWidget(
                      tab: tab,
                      isActive: tab.id == widget.activeTabId,
                      onTap: () => widget.onTabTap?.call(tab.id),
                      onClose: tab.closeable
                          ? () => widget.onTabClose?.call(tab.id)
                          : null,
                      tabIndex: index,
                      workspaceId: widget.workspaceId,
                    );
                  }),

                  // 새 탭 추가 버튼
                  if (widget.onAddTab != null) _buildAddTabButton(theme),

                  // 남은 공간
                  Expanded(child: Container(color: theme.colorScheme.surface)),
                ],
              ),

              // 드래그 인디케이터
              if (_isDragging && _dragOverIndex != null)
                _buildDragIndicator(theme),
            ],
          );
        },
      ),
    );
  }

  /// 새 탭 추가 버튼
  Widget _buildAddTabButton(ThemeData theme) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: theme.dividerColor, width: 1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onAddTab,
          child: Icon(
            Icons.add,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  /// 드래그 인디케이터 (세로선)
  Widget _buildDragIndicator(ThemeData theme) {
    if (_dragOverIndex == null) return const SizedBox.shrink();

    // 실제 탭 너비 기반으로 인디케이터 위치 계산
    final tabWidth = _calculateTabWidth();
    final indicatorX = _dragOverIndex! * tabWidth;

    return Positioned(
      left: indicatorX,
      top: 0,
      child: Container(
        width: 3,
        height: 36,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(1.5),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }

  /// 드래그 오버 인덱스 업데이트
  void _updateDragOverIndex(Offset offset) {
    // 실제 렌더링된 위젯의 위치를 기반으로 계산
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    int newIndex = 0;
    double accumulatedWidth = 0;

    // 각 탭의 실제 위치를 계산하여 가장 가까운 인덱스 찾기
    for (int i = 0; i < widget.tabs.length; i++) {
      // 탭의 최소/최대 너비를 고려한 실제 너비 추정
      final tabWidth = _calculateTabWidth();
      final tabCenter = accumulatedWidth + (tabWidth / 2);

      if (offset.dx < tabCenter) {
        newIndex = i;
        break;
      }

      accumulatedWidth += tabWidth;
      newIndex = i + 1; // 마지막 탭 뒤쪽
    }

    // 범위 제한
    newIndex = newIndex.clamp(0, widget.tabs.length);

    if (newIndex != _dragOverIndex) {
      setState(() {
        _dragOverIndex = newIndex;
      });
    }
  }

  /// 탭 너비 계산 (constraints에 기반)
  double _calculateTabWidth() {
    // TabItemWidget의 constraints와 동일하게 계산
    final availableWidth = MediaQuery.of(context).size.width - 36 - 50; // 여유분
    final tabCount = widget.tabs.length;

    if (tabCount == 0) return 120.0;

    final calculatedWidth = availableWidth / tabCount;
    return calculatedWidth.clamp(120.0, 200.0); // TabItemWidget과 동일한 제약
  }

  /// 드롭 처리
  void _handleDrop(DragData dragData) {
    // 같은 워크스페이스 내에서의 순서 변경만 처리
    if (dragData.sourceWorkspaceId == widget.workspaceId &&
        _dragOverIndex != null) {
      final oldIndex = dragData.originalIndex;
      final newIndex = _dragOverIndex!;

      // 실제로 위치가 변경된 경우에만 콜백 호출
      if (oldIndex != newIndex) {
        widget.onTabReorder?.call(oldIndex, newIndex);
      }
    }

    // TODO: 다른 워크스페이스에서 온 탭 처리는 4단계에서 구현
  }
}
