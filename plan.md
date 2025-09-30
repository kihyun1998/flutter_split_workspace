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

## Phase 3: Drag & Drop Integration (3-4 days)

### Objective
Create splits by dragging tabs

### Files to Create
- [ ] `lib/src/models/drag_state.dart`
  - [ ] Drag state model (isDragging, draggedTab, etc.)

- [ ] `lib/src/widgets/drag_config.dart`
  - [ ] InheritedWidget for drag state
  - [ ] Provides drag state to descendants

- [ ] `lib/src/widgets/draggable_tab_item.dart`
  - [ ] Draggable tab implementation
  - [ ] `LongPressDraggable`
  - [ ] Updates drag state on events

- [ ] `lib/src/widgets/drop_target_content.dart`
  - [ ] Droppable content area
  - [ ] `DragTarget<TabData>`
  - [ ] Detects drop zones (5 areas)
  - [ ] Triggers split or move action

- [ ] `lib/src/utils/drop_zone_calculator.dart`
  - [ ] Calculate 5 drop zones (left/right/top/bottom/center)
  - [ ] Detect zone from mouse position

### Updates
- [ ] Update `split_workspace.dart`
  - [ ] Add `onAction` callback
  - [ ] Wrap with `DragConfig`
  - [ ] Handle drag state

### Completion Criteria
- [ ] Tab drag starts correctly
- [ ] 5 zones detected in content area
- [ ] Drop creates split or moves tab

---

## Phase 4: Preview & Nested Split (2-3 days)

### Objective
Show preview during drag, support nested splits

### Files to Create
- [ ] `lib/src/widgets/split_preview_overlay.dart`
  - [ ] Visual preview during drag
  - [ ] Shows new/existing group areas
  - [ ] Shows split line
  - [ ] Different style for move vs split

### Features
- [ ] Nested split support
  - [ ] Use `targetGroupId` parameter
  - [ ] Can split already-split groups
  - [ ] Max depth enforcement (4 levels)

- [ ] Preview styling
  - [ ] New group area highlighted
  - [ ] Existing group dimmed
  - [ ] Split line emphasized
  - [ ] Different colors for move vs split

### Completion Criteria
- [ ] Real-time preview during drag
- [ ] Nested splits work (can create 2x2 grid)
- [ ] Depth limit prevents excessive nesting

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