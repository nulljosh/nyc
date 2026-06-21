<img src="icon.svg" width="80">

# nyc

![version](https://img.shields.io/badge/version-v1.1.0-blue)

Times Square Factory Sim: Factorio-style production game. SpriteKit, Swift 6, iOS + macOS (portrait/landscape).

## Features

- **Unified iOS + macOS codebase** (95% code deduplication via Sources-Shared)
- **Responsive layouts** (portrait + landscape on iOS, fixed 1280×800 on macOS)
- **Factory production chains** (4 building types: miner, smelter, assembler, storage)
- **Auto-pull logistics** (adjacent buildings automatically pull required inputs)
- **Production tracking** (progress bars show recipe completion)
- **3-slot save system** with auto-save
- **Item-based inventory** (ore, iron_plate, copper_ore, gear)

## Run

```bash
# macOS
xcodegen generate && open TimesSquareSim.xcodeproj

# iOS
cd ../nyc-ios && xcodegen generate && open TimesSquareSimIOS.xcodeproj
```

Requires Xcode 16+, macOS 15.0+, iOS 17.0+, xcodegen.

## Gameplay

1. Start with ore, copper ore, iron plates in inventory
2. Place a **Miner** (costs 5 ore) → produces ore
3. Place a **Smelter** adjacent (costs 10 ore) → auto-pulls ore, produces plates
4. Place an **Assembler** adjacent (costs 15 ore) → auto-pulls plates, produces gears
5. Watch production tick — progress bars fill as recipes complete

## Roadmap

### Phase 1: ✅ Mobile Architecture
- [x] Unified iOS + macOS codebase
- [x] Portrait + landscape support
- [x] Adaptive HUD layout

### Phase 2: ✅ Factorio Mechanics
- [x] Production building system
- [x] Auto-pull logistics
- [x] Item inventory (ore, plates, gears)
- [x] 4 building types + recipes
- [x] Progress bars + production tracking
- [x] Save/load integration

### Phase 3: Planned (Optional)
- [ ] Enemy waves (biters) spawning periodically
- [ ] Turret defense buildings
- [ ] Wall blocks + repair mechanics
- [ ] Pollution system (factories emit, triggers enemy waves)

### Phase 2.5: Optional
- [ ] Conveyor belt system (directional item flow)
- [ ] Advanced logistics (item filters, priority)
- [ ] Research/tech tree for building unlocks

### Phase 4: Polish
- [ ] Performance profiling (iOS battery, frame rate)
- [ ] Mobile UI refinements (button sizing, adaptive menus)
- [ ] Sound design & music
- [ ] App Store ship pass: tutorial/onboarding polish, accessibility audit (VoiceOver labels, Dynamic Type, contrast), final mobile-friendly pass
- [ ] No "autoplay" feature exists in this codebase (checked `Sources-Shared/`, `Sources-iOS/`, `Sources-macOS/`) — a 2026-06 task note asked to disable an autoplay feature, but the repo has since pivoted from a Times Square survival sim to this Factorio-style factory game and that feature doesn't exist here. If autoplay still needs disabling, it's likely in a different/older build — flag before assuming this repo.

## Architecture

- **Sources-Shared/**: Game logic, models, HUD (both platforms)
- **Sources-macOS/**: macOS entry point + AudioManager
- **Sources-iOS/**: iOS entry point + HapticManager
- **Game Systems**: ProductionSystem (recipe execution + auto-pull), BuildSystem, CameraController
- **Models**: ProductionBuilding, ItemType, Recipe, GameState
- **Rendering**: SpriteKit only (no UIKit/AppKit views in game scene)

## Changelog

### v1.1.0 (Current)

- Transformed from colony sim → Factorio-style factory game
- Unified iOS + macOS codebase (single Sources-Shared/)
- Added portrait + landscape support (iOS only)
- Replaced colonist AI with production building system
- 4 building types with auto-pull logistics
- ItemType-based inventory (replaced ResourceType)
- Progress bar visualization for production recipes
- Simplified GameState (no colonists, no complex resources)
- Updated SaveManager for new model schema

### v1.0.0

- Stable colony sim release
- Colonist AI, weapons, building placement
- 3-slot save system, interactive tutorial
- Camera controls, mini-map

## License

MIT 2026 Joshua Trommel
