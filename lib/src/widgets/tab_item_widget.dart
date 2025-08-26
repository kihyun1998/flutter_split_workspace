// lib/src/widgets/tab_item_widget.dart (수정)
import 'package:flutter/material.dart';

import '../models/drag_data.dart';
import '../models/tab_data.dart';
import '../theme/split_workspace_theme.dart'; // SplitWorkspaceTheme 임포트

class TabItemWidget extends StatelessWidget {
  final TabData tab;
  final bool isActive;
  final VoidCallback? onTap;
  final VoidCallback? onClose;
  final int tabIndex;
  final String workspaceId;
  final SplitWorkspaceTheme? theme; // 🆕 테마 추가

  const TabItemWidget({
    super.key,
    required this.tab,
    required this.isActive,
    this.onTap,
    this.onClose,
    required this.tabIndex,
    required this.workspaceId,
    this.theme, // 🆕 테마 파라미터 추가
  });

  @override
  Widget build(BuildContext context) {
    // 널 안전성을 위해 기본 테마를 사용
    final workspaceTheme = theme ?? SplitWorkspaceTheme.defaultTheme;

    return LongPressDraggable<DragData>(
      // 드래그 데이터
      data: DragData(
        tab: tab,
        originalIndex: tabIndex,
        sourceWorkspaceId: workspaceId,
      ),

      // 드래그 시작 지연 (실수 방지)
      delay: const Duration(milliseconds: 200),

      // 드래그 중 표시될 위젯 (피드백)
      feedback: _buildDragFeedback(context, workspaceTheme),

      // 드래그 시작할 때 원본 위치에 표시될 위젯
      childWhenDragging: _buildDragPlaceholder(context, workspaceTheme),

      // 기본 상태의 탭
      child: _buildNormalTab(context, workspaceTheme),
    );
  }

  /// 일반 상태의 탭 위젯
  Widget _buildNormalTab(BuildContext context, SplitWorkspaceTheme theme) {
    return Container(
      height: 36,
      constraints: const BoxConstraints(minWidth: 120, maxWidth: 200),
      decoration: BoxDecoration(
        // 테마 색상 사용
        color: isActive
            ? theme.colorScheme.surface
            : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: Border(
          right: BorderSide(color: theme.colorScheme.dividerColor, width: 1),
        ), // 테마 색상 사용
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.only(left: 12, right: tab.closeable ? 4 : 12),
            child: Row(
              children: [
                // 드래그 핸들 아이콘
                Icon(
                  Icons.drag_indicator,
                  size: 12,
                  // 테마 색상 사용
                  color: isActive
                      ? theme.colorScheme.onSurface.withOpacity(0.7)
                      : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
                const SizedBox(width: 6),

                // 탭 제목
                Expanded(
                  child: Text(
                    tab.title,
                    // 테마 텍스트 스타일 사용
                    style: theme.tab.textStyle?.copyWith(
                      color: isActive
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // 닫기 버튼
                if (tab.closeable)
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onClose,
                        borderRadius: BorderRadius.circular(4),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          // 테마 색상 사용
                          color: isActive
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 드래그 중 표시될 피드백 위젯
  Widget _buildDragFeedback(BuildContext context, SplitWorkspaceTheme theme) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 36,
        width: 160, // 고정 너비
        decoration: BoxDecoration(
          // 테마 색상 사용
          color: theme.colorScheme.primaryContainer.withOpacity(0.9),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            // 테마 색상 사용
            color: theme.colorScheme.primary.withOpacity(0.7),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(
                Icons.tab,
                size: 16,
                // 테마 색상 사용
                color: theme.colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tab.title,
                  // 테마 텍스트 스타일 사용
                  style: theme.tab.textStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 드래그 시작 시 원본 위치에 표시될 플레이스홀더
  Widget _buildDragPlaceholder(
    BuildContext context,
    SplitWorkspaceTheme theme,
  ) {
    return Container(
      height: 36,
      constraints: const BoxConstraints(minWidth: 120, maxWidth: 200),
      decoration: BoxDecoration(
        // 테마 색상 사용
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: Border(
          right: BorderSide(color: theme.colorScheme.dividerColor, width: 1),
        ), // 테마 색상 사용
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Container(
          width: 80,
          height: 2,
          decoration: BoxDecoration(
            // 테마 색상 사용
            color: theme.colorScheme.outline.withOpacity(0.5),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }
}
