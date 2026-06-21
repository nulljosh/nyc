# nyc

v1.1.0 — Unified iOS + macOS Factorio-style factory sim

## Rules

- SpriteKit for all rendering, no UIKit/AppKit views in game scene
- No emojis
- **Shared codebase** for iOS (portrait + landscape) and macOS (landscape fixed)

## Structure

- **Sources-Shared/**: Game logic, models, HUD (both platforms)
- **Sources-macOS/**: macOS entry point + AudioManager only
- **Sources-iOS/**: iOS entry point + HapticManager only

## Run

```bash
# macOS
xcodegen generate && open TimesSquareSim.xcodeproj

# iOS
cd ../nyc-ios && xcodegen generate && open TimesSquareSimIOS.xcodeproj
```

## Key Files (Shared)

- Sources-Shared/Game/Scenes/GameScene.swift: Main gameplay loop
- Sources-Shared/Game/Systems/LogisticsSystem.swift: Item flow and production
- Sources-Shared/Game/Systems/BuildSystem.swift: Building placement and demolition
- Sources-Shared/Models/GameState.swift: Central state
- Sources-Shared/Models/SaveManager.swift: JSON save/load (3-slot)

## Imported from Nyc.pdf (2026-06-21)
- [ ] Ship iOS app — BLOCKED: project only has a macOS target (TimesSquareSim.xcodeproj, SDKROOT=macosx). Needs a new iOS target (UI adaptation, signing) — scoping decision: portrait iOS port of the sim engine with touch controls, no watch in v1.
- [ ] Watch app — net-new watchOS target, not started.
