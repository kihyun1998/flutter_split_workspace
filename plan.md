# Split Workspace Implementation Plan

## 🎯 Goal
Implement drag-and-drop tab management with screen splitting functionality without Riverpod dependency.

## 📊 Timeline: 2-3 weeks

---

## Phase 1: Foundation - Models & Services (1-2 days)

### Objective
Pure Dart business logic without UI (copy from project_code.md)

### Files to Create
- [ ] `lib/src/models/split_data.dart`
  - [ ] `SplitPanel` class (leaf/branch node)
  - [ ] `SplitDirection` enum (horizontal/vertical)
  - [ ] `DropZoneType` enum (5 types)

- [ ] `lib/src/services/split_service.dart`
  - [ ] `createSplit()` - create screen split
  - [ ] `moveTabToGroup()` - move tab between groups
  - [ ] `removeEmptyGroup()` - cleanup empty groups

- [ ] `lib/src/services/workspace_helpers.dart`
  - [ ] `findGroupById()` - find group by ID
  - [ ] `findTabOwnerGroup()` - find tab's owner group
  - [ ] `updatePanel()` - update tree structure
  - [ ] `countTabs()`, `countGroups()` - statistics

### Completion Criteria
- [ ] Split/move/cleanup logic works without UI
- [ ] Can manipulate state tree programmatically
- [ ] Basic unit tests pass

---

## Phase 2: Basic Split UI (2-3 days)

### Objective
Render split screen statically (no drag yet)

### Files to Create
- [ ] `lib/src/widgets/split_workspace.dart`
  - [ ] Main API entry point
  - [ ] Takes `SplitPanel rootPanel`
  - [ ] Provides `onPanelChanged` callback
  - [ ] Theme configuration

- [ ] `lib/src/widgets/split_container.dart`
  - [ ] Recursive split rendering
  - [ ] Show `SplitGroup` if leaf
  - [ ] Show Flex with children if split
  - [ ] Max depth limit (4 levels)

- [ ] `lib/src/widgets/split_group.dart`
  - [ ] Single group (tab bar + content)
  - [ ] Works independently per group

- [ ] `lib/src/widgets/resizable_splitter.dart`
  - [ ] Draggable split line
  - [ ] `GestureDetector` + `MouseRegion`
  - [ ] `onRatioChanged` callback

### Example Update
- [ ] Update `example/lib/main.dart`
  - [ ] Use `SplitWorkspace` widget
  - [ ] Handle state with `setState`
  - [ ] Add manual split buttons for testing

### Completion Criteria
- [ ] 2-way split screen displays correctly
- [ ] Can adjust ratio with splitter
- [ ] Tab switching works in each group

---

## Phase 3: Drag & Drop Integration (3-4 days) ✅

### Objective
Create splits by dragging tabs

### Files to Create
- [x] `lib/src/models/drag_state.dart`
  - [x] Drag state model (isDragging, draggedTab, etc.)

- [x] `lib/src/widgets/drag_config.dart`
  - [x] InheritedWidget for drag state
  - [x] Provides drag state to descendants

- [x] `lib/src/widgets/draggable_tab_item.dart`
  - [x] Already exists in `tab_item_widget.dart`
  - [x] `LongPressDraggable`
  - [x] Updates drag state on events

- [x] `lib/src/widgets/drop_target_content.dart`
  - [x] Droppable content area
  - [x] `DragTarget<TabData>`
  - [x] Detects drop zones (5 areas)
  - [x] Triggers split or move action

- [x] `lib/src/utils/drop_zone_calculator.dart`
  - [x] Calculate 5 drop zones (left/right/top/bottom/center)
  - [x] Detect zone from mouse position

### Updates
- [x] Update `split_workspace.dart`
  - [x] Add `onSplitRequest` callback
  - [x] Wrap with `DragConfigProvider`
  - [x] Handle drag state

- [x] Update `tab_workspace.dart`
  - [x] Wrap content with `DropTargetContent`
  - [x] Handle drop events

- [x] Update `example/main.dart`
  - [x] Add `_onSplitRequest` handler

### Completion Criteria
- [x] Tab drag starts correctly
- [x] 5 zones detected in content area
- [x] Drop creates split or moves tab

---

## Phase 4: Preview & Nested Split (2-3 days) ✅

### Objective
Show preview during drag, support nested splits

### Files to Create
- [x] `lib/src/widgets/split_preview_overlay.dart`
  - [x] Visual preview during drag
  - [x] Shows new/existing group areas
  - [x] Shows split line
  - [x] Different style for move vs split

### Updates
- [x] Update `tab_workspace.dart`
  - [x] Add Stack with LayoutBuilder
  - [x] Show preview overlay during drag
  - [x] Use DragConfig context extension

### Features
- [x] Nested split support
  - [x] Use `targetGroupId` parameter (already in Phase 3)
  - [x] Can split already-split groups (SplitService supports this)
  - [x] Max depth enforcement (4 levels - in SplitService)

- [x] Preview styling
  - [x] New group area highlighted
  - [x] Existing group dimmed
  - [x] Split line emphasized
  - [x] Different colors for move vs split

### Completion Criteria
- [x] Real-time preview during drag
- [x] Nested splits work (can create 2x2 grid)
- [x] Depth limit prevents excessive nesting

---

## Phase 5: Polish & Documentation (2-3 days)

### Objective
Production ready with complete documentation

### Tasks
- [ ] Theme integration
  - [ ] Integrate with existing theme system
  - [ ] Customizable drag/drop colors
  - [ ] Preview style options

- [ ] Error handling
  - [ ] Invalid state recovery
  - [ ] Auto-cleanup empty groups
  - [ ] Prevent circular references

- [ ] API documentation
  - [ ] All public APIs have English comments
  - [ ] Usage examples in comments
  - [ ] Clear parameter descriptions

- [ ] Example app enhancement
  - [ ] Multiple demo scenarios
  - [ ] Theme switching
  - [ ] Clear instructions

### Completion Criteria
- [ ] All public APIs documented
- [ ] Example app is complete and clear
- [ ] No critical bugs
- [ ] Follows CLAUDE.md guidelines

---

## 🎯 What's Needed vs What's Not

### ✅ Essential (Keep)
1. **Core functionality**
   - Split/move/cleanup logic
   - Drag and drop
   - Preview
   - Nested splits

2. **User-facing features**
   - Resizable splitter
   - Visual feedback
   - Theme customization

3. **API & Documentation**
   - Clear callbacks
   - English comments
   - Usage examples

4. **Basic validation**
   - Does it work in example app?
   - Can user accomplish tasks?

### ❌ Not Needed (Remove)
1. **Development overhead**
   - ~~Console log checks~~
   - ~~Detailed test scenarios with print statements~~
   - ~~Manual debugging procedures~~

2. **Advanced optimization**
   - ~~Performance measurement (DevTools)~~
   - ~~Memory profiling~~
   - ~~FPS monitoring~~
   - ~~Throttling optimization~~ (add only if performance issue appears)

3. **Excessive validation**
   - ~~Unit tests for every function~~
   - ~~Complex test scenarios~~
   - ~~Automated testing setup~~

4. **Over-engineering**
   - ~~Custom painter for preview~~ (use simple widgets first)
   - ~~Advanced caching strategies~~ (add only if needed)
   - ~~Complex state management~~ (keep it simple with callbacks)

---

## 📋 Simple Validation Per Phase

### Phase 1
Run the service functions manually, check if state tree changes correctly.

### Phase 2
Open example app, manually create split with buttons, see if screen splits.

### Phase 3
Drag a tab, see if zones are detected, drop to see if split is created.

### Phase 4
Drag a tab, confirm preview appears, try nested split.

### Phase 5
Use example app with different themes, try various scenarios.

---

## 💡 Notes

- **CLAUDE.md Compliance**
  - Incremental development
  - Simple callback-based API
  - Get approval for complex features

- **Code Reuse**
  - Copy Services from project_code.md
  - Only remove Riverpod references

- **Documentation**
  - English comments for all public APIs
  - Include code examples

---

## 🚀 Ready to Start?

Begin with **Phase 1** - copy Models and Services from project_code.md, remove Riverpod dependencies.