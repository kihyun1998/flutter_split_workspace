# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter package that provides a split workspace interface with tabbed panels, similar to VS Code's panel system. The package allows users to create, move, and split tabs with drag-and-drop functionality, resizable dividers, and real-time previews.

**Core Features:**
- Tab creation, movement, and deletion
- Screen splitting (vertical/horizontal with nested support)
- Drag & drop tab movement and splitting
- Real-time preview during drag operations
- Resizable split dividers

## Architecture

The package follows a clean layered architecture:

```
lib/
├── models/              # Data models (tree structure for splits)
│   ├── split_panel_model.dart    # SplitPanel with SplitDirection enum
│   └── tab_model.dart            # TabModel with content data
├── services/            # Business logic layer
│   ├── split_service.dart        # Panel splitting operations
│   ├── tab_service.dart          # Tab management operations  
│   └── workspace_helpers.dart    # Utility functions
├── widgets/             # UI components
│   ├── split_container.dart      # Main container widget
│   ├── tab_group.dart           # Individual tab group container
│   ├── tab_item.dart            # Single tab widget
│   ├── group_tab_bar.dart       # Tab bar for groups
│   ├── group_content.dart       # Content area for active tab
│   ├── resizable_splitter.dart  # Drag handle for resizing
│   └── split_preview_overlay.dart # Drag preview overlay
├── extensions/          # Extension methods
│   └── drop_zone_type_extension.dart
└── flutter_split_workspace.dart  # Main export file
```

**Key Architectural Concepts:**
- **Tree Structure**: SplitPanel uses a tree structure where leaf nodes contain tabs and branch nodes define split directions
- **State Management Agnostic**: The package provides business logic but users implement their own state management
- **Service Layer**: Clear separation between UI widgets and business logic through service classes

## Development Commands

**Note**: Claude Code runs in WSL environment but the actual development is done on Windows. Please ask the user to run these commands in their Windows development environment:

```bash
# Run tests
flutter test

# Run analyzer
flutter analyze

# Format code
dart format .

# Check for lint issues
flutter analyze --no-fatal-infos

# Publish dry run
flutter packages pub publish --dry-run
```

When implementing features, Claude should ask the user to run tests and validation commands rather than executing them directly.

## Incremental Implementation Plan

The package should be implemented in small, testable increments:

### Phase 1: Foundation Models (Start Here)
1. Create basic `TabModel` with essential properties
2. Create simple `SplitPanel` model for single groups only
3. Add basic enums (`SplitDirection`, `DropZoneType`)
4. Write unit tests for models

### Phase 2: Basic Tab Management
1. Implement `TabService` with add/remove/activate operations
2. Create simple `TabItem` widget
3. Create basic `GroupTabBar` widget
4. Create `GroupContent` widget for displaying active tab
5. Test basic tab functionality

### Phase 3: Single Tab Group Container
1. Implement `TabGroup` widget combining tab bar and content
2. Add basic styling and layout
3. Test complete single-group functionality
4. This creates a working single-panel tab interface

### Phase 4: Panel Splitting Logic
1. Extend `SplitPanel` model to support tree structure
2. Implement `SplitService` with split/merge operations
3. Add workspace helper utilities
4. Write comprehensive tests for split logic

### Phase 5: Split Container UI
1. Create `SplitContainer` widget for rendering panel trees
2. Add recursive rendering for nested splits
3. Implement basic split layouts (no resizing yet)
4. Test split rendering with mock data

### Phase 6: Resizable Splits
1. Implement `ResizableSplitter` widget
2. Add ratio adjustment logic to services
3. Connect splitter to panel resize operations
4. Test resize functionality

### Phase 7: Drag & Drop Foundation
1. Add drag detection to `TabItem`
2. Create basic `SplitPreviewOverlay`
3. Implement drop zone detection
4. Test basic drag interactions

### Phase 8: Complete Drag & Drop
1. Implement tab movement between groups
2. Add split-on-drop functionality
3. Complete preview overlay with visual feedback
4. Test all drag & drop scenarios

### Phase 9: Polish & Integration
1. Add animations and transitions
2. Implement remaining helper methods
3. Add comprehensive example
4. Performance testing and optimization

## Testing Strategy

- **Models**: Unit tests for all data structures and business logic
- **Services**: Comprehensive testing of split/merge operations and edge cases
- **Widgets**: Widget tests for UI components and interactions
- **Integration**: Test complete workflows like drag-to-split operations

Each phase should be fully tested before moving to the next. This approach allows for incremental validation and easier debugging.

## Important Notes

- The package is state management agnostic - users provide their own state solution
- Focus on clean separation between UI widgets and business logic
- All widgets should accept callback functions for state changes
- Maintain immutable data models where possible
- Follow Flutter package conventions for exports and documentation