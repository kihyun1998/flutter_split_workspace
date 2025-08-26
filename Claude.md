# Flutter Split Workspace 프로젝트 지침서

## 🎯 프로젝트 개요

**패키지명**: `flutter_split_workspace`  
**목표**: 드래그&드롭 탭 관리와 화면 분할 기능을 제공하는 Flutter 패키지  
**핵심 가치**: 데이터 상태관리 없이 UI와 콜백만으로 사용 가능한 사용자 친화적 패키지

## 📋 현재 프로젝트 상태

### ✅ 완성된 기능
- [x] 기본 탭 시스템 (TabData, TabWorkspace)
- [x] 드래그&드롭 탭 순서 변경
- [x] 테마 시스템 (colorScheme 중심 6가지 테마)
- [x] 스크롤 가능한 탭바
- [x] 완전한 예제 앱

### 🚧 다음 구현 예정
- [ ] 드롭존 시스템 (화면 분할을 위한 UI)
- [ ] 화면 분할 기본 기능
- [ ] 중첩 분할 지원
- [ ] 분할 비율 조정
- [ ] 미리보기 기능

## 🛠️ 개발 방침

### 📁 파일 구조 원칙
```
lib/
├── src/
│   ├── models/          # 데이터 모델
│   ├── theme/           # 테마 관련
│   ├── widgets/         # UI 위젯
│   └── enums/          # 열거형 (필요시)
└── flutter_split_workspace.dart
```

### 💻 코딩 스타일
- **주석**: 영어로 작성, API 문서를 위해 상세히 작성
- **복잡도**: 단순하게 구현, 복잡한 기능은 사전 승인 후 진행
- **아티팩트**: 코드 관리를 위해 적극 활용
- **점진적 개발**: 작은 목표로 나누어 단계별 구현

### 📋 보고 형식
파일 변경 사항을 다음과 같이 명시:
- **추가**: 새로 생성된 파일들
- **수정**: 기존 파일의 변경 사항
- **삭제**: 제거된 파일들

## 🎨 테마 시스템 아키텍처

### 핵심 컴포넌트
1. **SplitWorkspaceColorSchemeTheme**: 중앙집중식 색상 관리
2. **SplitWorkspaceTabTheme**: 탭 관련 스타일
3. **SplitWorkspaceScrollbarTheme**: 스크롤바 스타일
4. **SplitWorkspaceTheme**: 전체 테마 통합

### 지원 테마
- `defaultTheme`: Material Design 기본
- `dark`: 다크 테마
- `light`: 라이트 테마
- `minimal`: 미니멀 테마
- `compact`: 컴팩트 테마
- `highContrast`: 접근성 고대비 테마

## 📊 API 설계 원칙

### 사용자 친화성
```dart
// ❌ 복잡한 상태 관리 요구
SomeComplexStateManager(...)

// ✅ 간단한 콜백 기반
TabWorkspace(
  tabs: tabs,
  onTabTap: (tabId) => setState(() => activeTab = tabId),
  onTabReorder: (oldIndex, newIndex) => _reorderTabs(oldIndex, newIndex),
)
```

### 테마 적용 방식
```dart
// colorScheme을 활용한 일관된 색상 시스템
final backgroundColor = isActive
  ? (theme.tab.activeBackgroundColor ?? theme.colorScheme.surface)
  : (theme.tab.inactiveBackgroundColor ?? theme.colorScheme.surfaceContainerHighest);
```

## 🚀 다음 단계 로드맵

### Phase 1: 드롭존 시스템 (예정)
**목표**: 화면 분할을 위한 드롭존 UI 구현  
**추가 예정 파일**:
- `lib/src/enums/drop_zone_type.dart`
- `lib/src/models/drop_zone_data.dart` 
- `lib/src/widgets/drop_zone_overlay.dart`

### Phase 2: 화면 분할 기초 (예정)
**목표**: 기본적인 2분할 화면 기능  
**추가 예정 파일**:
- `lib/src/models/split_data.dart`
- `lib/src/widgets/split_workspace.dart`

### Phase 3: 고급 분할 기능 (예정)
**목표**: 중첩 분할, 비율 조정, 미리보기  

## 🔍 품질 관리

### 검증 체크리스트
- [ ] 모든 위젯이 colorScheme을 올바르게 활용하는가?
- [ ] API 문서(주석)가 충분한가?
- [ ] 예제에서 모든 기능이 동작하는가?
- [ ] 테마 변경이 실시간으로 적용되는가?
- [ ] 드래그&드롭이 부드럽게 동작하는가?

### 테스트 시나리오
1. **테마 전환**: 모든 테마 간 전환이 부드러운가?
2. **탭 조작**: 추가/삭제/순서변경이 올바른가?
3. **드래그&드롭**: 다양한 시나리오에서 안정적인가?
4. **빈 상태**: 탭이 없을 때 적절한 UI를 보여주는가?

## 💡 참고사항

### project_code.md 활용
완성된 고급 기능 참고용으로 활용:
- 중첩 분할 로직
- 드롭존 계산 알고리즘  
- 미리보기 시스템
- 복잡한 상태 관리

### 협업 방식
1. **단계별 승인**: 각 Phase 시작 전 계획 승인
2. **점진적 구현**: 작은 기능 단위로 개발
3. **지속적 테스트**: 각 단계마다 예제에서 검증
4. **문서화**: 모든 public API에 상세한 주석

## 📝 현재 중점 사항

**완성**: 기본 탭 시스템과 테마 시스템 안정화  
**다음**: 드롭존 시스템 구현 계획 수립  
**주의**: 복잡한 기능은 사전 논의 후 진행

---
