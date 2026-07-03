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
- [ ] Ship iOS app — BLOCKED 2026-07-03: bundle ID `com.heyitsmejosh.nyc.ios` registered, App Store provisioning profile created (ASC id `Y3T59BYVQ5`), but no local private key for an iOS distribution cert exists on this Mac (only Apple Development + Mac 3rd Party Application identities in keychain) — `xcodebuild -exportArchive` can't sign an App Store IPA until a new IOS_DISTRIBUTION cert is generated with its key kept locally (CSR started, not finished) or an existing cert+key pair is imported. Support URL set to `https://nyc.heyitsmejosh.com`.
- [ ] Watch app — net-new watchOS target, not started.
- [ ] Define concrete next steps to ship the game
- [x] Manual colonist control fixed 2026-07-01 — `assignJob()` was dead code, colonists were 100% directive-driven. Added `JobSystem.commandMove()` wired to select-then-tap-destination in GameScene.
- [x] Autoplay REMOVED 2026-07-02 — deleted the directive engine entirely (`autoAssignIdle`, `ColonyDirective`, directive HUD pills, `jobOverride`). Colonists act only on player commands (select + tap to move, job pills in ColonistPanel). Do NOT reintroduce auto-assignment.
- [ ] Improve the tutorial/onboarding polish
- [ ] Vibe-clone the portfolio UI into the project
