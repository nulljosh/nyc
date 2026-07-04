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
- [x] Build 3 rejected 2026-07-04 (ITMS-90474 missing iPad orientation key, ITMS-90055 bundle ID mismatch). Root cause: `INFOPLIST_KEY_UISupportedInterfaceOrientations~ipad` build-setting syntax does NOT generate the device-qualified plist key — Xcode silently drops it. Fixed by adding a real `Resources/Info-iOS.plist` with both orientation keys. Also fixed iOS target bundle ID from `com.heyitsmejosh.nyc.ios` to `com.heyitsmejosh.nyc` to match the registered ASC app record (created new bundle ID reg + provisioning profile `39Y8RMMQMU`, ExportOptions updated). Build 5 uploaded and processed clean 2026-07-04.
- [x] Build 5 uploaded 2026-07-04, description/keywords set, 6.5" screenshot uploaded, review contact + encryption declaration filled in. `asc review submit` blocked on 3 things only fixable in ASC web UI (no API path exists): (1) App Privacy data-usage answers, (2) privacy policy URL on App Information page, (3) one iPad Pro 12.9" screenshot required since app targets iPad. Do these 3 in the dashboard, then submit.
- [ ] Watch app — net-new watchOS target, not started.
- [ ] Define concrete next steps to ship the game
- [x] Manual colonist control fixed 2026-07-01 — `assignJob()` was dead code, colonists were 100% directive-driven. Added `JobSystem.commandMove()` wired to select-then-tap-destination in GameScene.
- [x] Autoplay REMOVED 2026-07-02 — deleted the directive engine entirely (`autoAssignIdle`, `ColonyDirective`, directive HUD pills, `jobOverride`). Colonists act only on player commands (select + tap to move, job pills in ColonistPanel). Do NOT reintroduce auto-assignment.
- [ ] Improve the tutorial/onboarding polish
- [ ] Vibe-clone the portfolio UI into the project
