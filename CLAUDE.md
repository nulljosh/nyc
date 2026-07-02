# nyc

v1.2.0 — macOS + iOS colony sim, fully player-controlled (no autoplay)

## Rules

- SpriteKit for all rendering, no UIKit/AppKit views in game scene
- No emojis

## Structure

- **Sources/**: the actual build target (see `project.yml`) — game logic, models, HUD.
- **Sources-Shared/**: stale duplicate, NOT in `project.yml`, not compiled. Do not edit; a prior iOS-sharing plan never landed here. Delete or revive deliberately, don't let it silently drift from `Sources/` again.
- `Sources-macOS/`, `Sources-iOS/`, `nyc-ios/` referenced by older notes don't exist on disk.

## Run

```bash
xcodegen generate && open NYCSurvive.xcodeproj
```

## Key Files

- Sources/Game/Scenes/GameScene.swift: Main gameplay loop, input → command wiring
- Sources/Game/Systems/JobSystem.swift: Colonist job assignment (auto-directive + manual commandMove)
- Sources/Game/Systems/BuildSystem.swift: Building placement and demolition
- Sources/Models/GameState.swift: Central state
- Sources/Models/SaveManager.swift: JSON save/load (3-slot)

## Imported from Nyc.pdf (2026-06-21)
- [ ] Ship iOS app — BLOCKED: project only has a macOS target (NYCSurvive.xcodeproj, SDKROOT=macosx). Needs a new iOS target (UI adaptation, signing) — scoping decision: portrait iOS port of the sim engine with touch controls, no watch in v1.
- [ ] Watch app — net-new watchOS target, not started.
- [ ] Define concrete next steps to ship the game
- [x] Manual colonist control fixed 2026-07-01 — `assignJob()` was dead code, colonists were 100% directive-driven. Added `JobSystem.commandMove()` wired to select-then-tap-destination in GameScene.
- [x] Autoplay REMOVED 2026-07-02 — deleted the directive engine entirely (`autoAssignIdle`, `ColonyDirective`, directive HUD pills, `jobOverride`). Colonists act only on player commands (select + tap to move, job pills in ColonistPanel). Do NOT reintroduce auto-assignment.
- [ ] Improve the tutorial/onboarding polish
- [ ] Vibe-clone the portfolio UI into the project
