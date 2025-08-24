# Flutter Split Workspace - 단계별 구현 계획

이 문서는 flutter_split_workspace 패키지의 단계별 구현 계획을 담고 있습니다. 각 단계는 작은 기능 단위로 나누어져 있어 테스트하면서 점진적으로 개발할 수 있습니다.

## 📋 전체 개요

**목표**: VS Code와 같은 분할 가능한 탭 워크스페이스 인터페이스 제공

**핵심 기능**:
- 탭 생성, 이동, 삭제
- 화면 분할 (수직/수평, 중첩 분할 지원)
- 드래그 앤 드롭으로 탭 이동 및 분할
- 실시간 미리보기
- 크기 조절 가능한 분할선

## 🚀 Phase 1: Foundation Models ✅ **완료**

**목표**: 기본 데이터 모델과 enum 구조 구축

### 완료된 작업:
- [x] `TabModel` 생성 (id, title, tooltip, canClose, data)
- [x] `SplitPanel` 모델 생성 (단일 그룹 지원)
- [x] `SplitDirection` enum (horizontal, vertical)
- [x] `DropZoneType` enum (splitLeft, splitRight, splitTop, splitBottom, moveToGroup)
- [x] 모델 단위 테스트 작성 (18개 테스트 통과)
- [x] 메인 export 파일 업데이트

**결과**: 견고한 데이터 모델 기반 완성

---

## 📝 Phase 2: Basic Tab Management ✅ **완료**

**목표**: 기본적인 탭 관리 기능 구현

### 완료된 작업:
- [x] **TabService 클래스** - 정적 메서드로 상태관리 agnostic 구현
   - `addTab()`: 탭 추가 (인덱스 지정 가능)
   - `removeTab()`: 탭 제거  
   - `activateTab()`: 탭 활성화 검증
   - `moveTab()`: 탭 순서 변경
   - `getNextActiveTab()`: 탭 제거 시 다음 활성 탭 결정
   - `findTab()`, `hasTab()`: 유틸리티 메서드

- [x] **TabItem 위젯** - 개별 탭 표시
   - 활성/비활성 상태별 스타일링
   - 클릭 이벤트 콜백 (`onTap`)
   - 조건부 닫기 버튼 (`canClose && onClose`)
   - 긴 제목 자동 truncate

- [x] **GroupTabBar 위젯** - 탭 바 컨테이너
   - 수평 스크롤 가능한 탭 목록
   - 탭 클릭/닫기 콜백 전달
   - 빈 탭 목록 처리

- [x] **GroupContent 위젯** - 콘텐츠 영역
   - 활성 탭 콘텐츠 표시 (커스텀 `contentBuilder` 지원)
   - 빈 상태 UI (커스텀 `emptyState` 지원)
   - 기본 플레이스홀더 콘텐츠

- [x] **포괄적인 테스트 작성** (39개 테스트 케이스)
   - TabService 단위 테스트 (21개)
   - 각 위젯별 렌더링/인터렉션 테스트 (18개)

**결과**: 완전한 상태관리 분리된 탭 관리 기능 완성 🎯

---

## 🏗️ Phase 3: Single Tab Group Container

**목표**: 완전한 단일 탭 그룹 인터페이스 구현

### 구현할 기능:
1. **TabGroup 위젯**
   - GroupTabBar + GroupContent 조합
   - 탭과 콘텐츠 영역의 레이아웃 관리
   - 상태 관리 콜백 연결

2. **기본 스타일링**
   - 탭 바 스타일 (색상, 폰트, 패딩)
   - 활성/비활성 탭 구분
   - 호버 효과

3. **완전한 단일 그룹 기능**
   - 탭 추가/제거 UI
   - 탭 순서 변경
   - 키보드 네비게이션

### 테스트 계획:
- TabGroup 위젯 통합 테스트
- 사용자 인터렉션 시나리오 테스트
- 스타일링 및 레이아웃 테스트

**마일스톤**: 실제 사용 가능한 단일 패널 탭 인터페이스 완성 🎯

---

## 🌳 Phase 4: Panel Splitting Logic

**목표**: 패널 분할을 위한 비즈니스 로직 구현

### 구현할 기능:
1. **SplitPanel 모델 확장**
   - 트리 구조 완전 지원
   - 중첩 분할 처리
   - 패널 검색/탐색 메서드

2. **SplitService 클래스**
   - `splitPanel(String panelId, SplitDirection direction)`: 패널 분할
   - `mergePanel(String panelId)`: 패널 병합
   - `findPanel(String panelId)`: 패널 검색
   - `updatePanelRatio(String panelId, double ratio)`: 비율 조정

3. **workspace_helpers.dart**
   - 패널 트리 유틸리티 함수
   - 탭 이동 헬퍼 함수
   - 검증 함수들

### 테스트 계획:
- 분할/병합 로직 단위 테스트
- 복잡한 중첩 구조 테스트
- 에지 케이스 처리 테스트

**마일스톤**: 견고한 분할 로직 완성

---

## 🎨 Phase 5: Split Container UI

**목표**: 분할된 패널을 렌더링하는 UI 구현

### 구현할 기능:
1. **SplitContainer 위젯**
   - 패널 트리 재귀 렌더링
   - 수직/수평 분할 레이아웃
   - 동적 크기 계산

2. **기본 분할 레이아웃**
   - Flex/Expanded 기반 레이아웃
   - 분할 비율 적용
   - 중첩 분할 처리

3. **분할 렌더링 테스트**
   - 목 데이터로 다양한 분할 패턴 테스트
   - 레이아웃 정확성 검증

### 테스트 계획:
- 다양한 분할 구조 렌더링 테스트
- 레이아웃 계산 정확성 테스트
- 성능 테스트

**마일스톤**: 분할된 패널 시각화 완성

---

## 📏 Phase 6: Resizable Splits

**목표**: 사용자가 패널 크기를 조절할 수 있는 기능 구현

### 구현할 기능:
1. **ResizableSplitter 위젯**
   - 드래그 핸들 UI
   - 마우스/터치 드래그 감지
   - 실시간 크기 조절

2. **크기 조절 로직**
   - 분할 비율 계산
   - 최소/최대 크기 제한
   - 부모 패널과의 연동

3. **사용자 경험 개선**
   - 드래그 중 시각적 피드백
   - 커서 변경
   - 스무스한 크기 조절

### 테스트 계획:
- 드래그 인터렉션 테스트
- 비율 계산 정확성 테스트
- 경계 조건 테스트

**마일스톤**: 완전한 크기 조절 기능 완성

---

## 🖱️ Phase 7: Drag & Drop Foundation

**목표**: 기본적인 드래그 앤 드롭 인프라 구축

### 구현할 기능:
1. **TabItem 드래그 감지**
   - 드래그 시작 감지
   - 드래그 상태 관리
   - 드래그 데이터 전달

2. **SplitPreviewOverlay 기본 구조**
   - 오버레이 위젯 기본 틀
   - 드롭 존 표시 준비
   - 좌표 계산 기반

3. **드롭 존 감지**
   - 패널별 드롭 영역 정의
   - 드롭 존 타입 판별
   - 호버 상태 감지

### 테스트 계획:
- 드래그 시작/종료 이벤트 테스트
- 드롭 존 감지 정확성 테스트
- 기본 인터렉션 테스트

**마일스톤**: 드래그 앤 드롭 기반 구조 완성

---

## 🎯 Phase 8: Complete Drag & Drop

**목표**: 완전한 드래그 앤 드롭 기능 구현

### 구현할 기능:
1. **탭 이동 기능**
   - 같은 그룹 내 탭 순서 변경
   - 다른 그룹으로 탭 이동
   - 빈 그룹 처리

2. **분할 드롭 기능**
   - 드롭 시 새 패널 생성
   - 4방향 분할 지원
   - 동적 패널 트리 업데이트

3. **완전한 프리뷰 오버레이**
   - 실시간 드롭 영역 하이라이트
   - 분할 미리보기 표시
   - 애니메이션 효과

### 테스트 계획:
- 전체 드래그 앤 드롭 시나리오 테스트
- 복잡한 분할 상황 테스트
- 사용자 경험 테스트

**마일스톤**: 완전한 드래그 앤 드롭 시스템 완성 🎯

---

## ✨ Phase 9: Polish & Integration

**목표**: 최종 완성도 향상 및 패키지 마무리

### 구현할 기능:
1. **애니메이션 및 전환 효과**
   - 탭 전환 애니메이션
   - 분할 생성/제거 애니메이션
   - 부드러운 크기 조절

2. **나머지 헬퍼 메서드들**
   - 편의 기능들
   - 고급 유틸리티
   - 성능 최적화

3. **종합 예제**
   - 완전한 사용 예제
   - 다양한 시나리오 데모
   - 문서화

### 테스트 계획:
- 성능 테스트 및 최적화
- 전체 시스템 통합 테스트
- 사용성 테스트

**마일스톤**: 프로덕션 준비 완료 패키지 🚀

---

## 📈 진행 상황

- [x] **Phase 1**: Foundation Models ✅ **완료** (2024-08-20)
- [x] **Phase 2**: Basic Tab Management ✅ **완료** (2024-08-24)
- [ ] **Phase 3**: Single Tab Group Container 🔄 **다음 단계**
- [ ] **Phase 4**: Panel Splitting Logic  
- [ ] **Phase 5**: Split Container UI
- [ ] **Phase 6**: Resizable Splits
- [ ] **Phase 7**: Drag & Drop Foundation
- [ ] **Phase 8**: Complete Drag & Drop
- [ ] **Phase 9**: Polish & Integration

---

## 🎯 주요 마일스톤

1. **Phase 3 완료**: 실제 사용 가능한 단일 패널 탭 인터페이스
2. **Phase 5 완료**: 분할된 패널 시각화 
3. **Phase 8 완료**: 완전한 드래그 앤 드롭 시스템
4. **Phase 9 완료**: 프로덕션 준비 완료

각 단계는 독립적으로 테스트 가능하며, 점진적으로 기능이 추가되는 구조입니다.