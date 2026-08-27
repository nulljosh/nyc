<img src="icon.svg" width="80">

# NYC Survive

### Build the City That Never Sleeps

![version](https://img.shields.io/badge/version-v1.3.1-blue) ![license](https://img.shields.io/badge/license-MIT-green)
[![GitHub](https://img.shields.io/badge/GitHub-nulljosh%2Fnyc-black?logo=github)](https://github.com/nulljosh/nyc)

NYC Survive: Factorio-style production game. SpriteKit, Swift 6, iOS + macOS (portrait/landscape).

## Features

- **Unified iOS + macOS codebase** (shared `Sources/`, per-platform app entry points)
- **Responsive layouts** (portrait + landscape on iOS, fixed 1280×800 on macOS)
- **Factory production chains** (4 building types: miner, smelter, assembler, storage)
- **Auto-pull logistics** (adjacent buildings automatically pull required inputs)
- **Production tracking** (progress bars show recipe completion)
- **3-slot save system** with auto-save
- **Item-based inventory** (ore, iron_plate, copper_ore, gear)

## Run

```bash
# macOS
xcodegen generate && open NYCSurvive.xcodeproj

# iOS
cd ../nyc-ios && xcodegen generate && open NYCSurviveIOS.xcodeproj
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

### Phase 2: ✅ Factorio Mechanics

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
- [x] Autoplay fully resolved 2026-08-02 — 2026-07-02 only removed the directive engine entry point; two other systems were perpetuating autoplay: hardcoded startup job assignments and self-renewing job-tick loops. Removed both. Also cleaned dead web autopilot block. Colonists act only on player commands.

## Remaining Tasks

- [ ] Landing page (GitHub Pages, `docs/` folder): hero, subtitle, gameplay summary, screenshots, how-to-play tutorial
- [ ] README screenshots (gameplay capture via simulator)

## Architecture

- **Sources-Shared/**: Game logic, models, HUD (both platforms)
- **Sources-macOS/**: macOS entry point + AudioManager
- **Sources-iOS/**: iOS entry point + HapticManager
- **Game Systems**: ProductionSystem (recipe execution + auto-pull), BuildSystem, CameraController
- **Models**: ProductionBuilding, ItemType, Recipe, GameState
- **Rendering**: SpriteKit only (no UIKit/AppKit views in game scene)

## Changelog

### v1.3.1 (Current)

- Fix tutorial/HUD unclickable on macOS and iOS (HUD subtree had hit-testing disabled; taps fell through to the game scene)
- Harden SaveManager: corrupt saves log instead of failing silently, guard against invalid grid size
- Test suite expanded to 19 tests: no-autoplay regression, move orders, save round-trip, legacy save decode, tutorial flow

### v1.3.0

- Sprite refresh: colonists get hair, skin-tone faces, two-tone outfits; textured road/sidewalk/empty tiles; all sprites now export @1x/@2x/@3x (crisp on Retina)
- Controls reference in Settings now covers select-then-tap move orders and macOS keyboard shortcuts (WASD, B, 1-6, Space, Cmd+S, Esc)

### v1.2.0

- Removed autoplay completely: deleted colony directive engine (`autoAssignIdle`, `ColonyDirective`, directive HUD pills, `jobOverride`)
- Game is fully player-controlled: select colonist + tap to move, assign jobs via colonist panel
- Tutorial step 6 now teaches manual command instead of directives
- Applies to both macOS and iOS targets (shared `Sources/`)

### v1.1.0

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

## Whitepaper

[Technical whitepaper](WHITEPAPER.md)

## API and agent tools

No HTTP API — client-only game, saves in the browser's `localStorage`. The web
app registers WebMCP tools so a browser-based AI agent can inspect and drive
the game. See [docs/API.md](docs/API.md).
