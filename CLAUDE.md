# nyc

v1.3.1 — macOS + iOS colony sim, fully player-controlled (no autoplay)

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
- [x] iOS target added 2026-06-30 (`NYCSurvive-iOS` scheme, touch controls) — builds clean for simulator.
- [x] iOS build 2 uploaded to ASC 2026-07-03 — generated new IOS_DISTRIBUTION cert (`38S6CX4DJ5`, key kept in login keychain), provisioning profile `HZKYCVUVRH`, exported + uploaded via `asc xcode export` / `asc builds upload`. Support URL set to `https://nyc.heyitsmejosh.com`.
- [ ] Ship iOS app — remaining: en-US description/keywords (missing, blocks submit) and iOS screenshots, then submit for review.
- [ ] Watch app — net-new watchOS target, not started.
- [ ] Define concrete next steps to ship the game
- [x] Manual colonist control fixed 2026-07-01 — `assignJob()` was dead code, colonists were 100% directive-driven. Added `JobSystem.commandMove()` wired to select-then-tap-destination in GameScene.
- [x] Autoplay REMOVED 2026-07-02 — deleted the directive engine entirely (`autoAssignIdle`, `ColonyDirective`, directive HUD pills, `jobOverride`). Colonists act only on player commands (select + tap to move, job pills in ColonistPanel). Do NOT reintroduce auto-assignment.
- [ ] Improve the tutorial/onboarding polish
- [ ] Vibe-clone the portfolio UI into the project
