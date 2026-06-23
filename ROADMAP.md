# NYC Roadmap

## App Store Connect (2026-06-22)
- [x] macOS AppIcon was empty — generated full icon_16–1024 PNG set from `icon.svg` via ImageMagick.
- [x] Fixed `MARKETING_VERSION` mismatch (project had 0.2.0, ASC expected 1.0).
- [x] Archived, exported as .pkg, uploaded build 1.0 (1) to ASC — succeeded.
- [x] Content rights declaration set (does not use third-party content).
- [x] Copyright set on the macOS version record.
- [ ] Support URL still missing — required before submission, needs a real URL decision.
- [ ] iOS target still doesn't exist (see CLAUDE.md) — macOS only for now.

## Phase 1: Unified Mobile Architecture (DONE)
- [x] Consolidate macOS + iOS codebase (95% duplication → single Sources-Shared/)
- [x] Update project.yml for unified structure
- [x] Add portrait + landscape orientation to iOS (project.yml)
- [x] Make GameScene world size adaptive (not hardcoded 4096×4096)
- [x] Adapt HUD layout for portrait/landscape (GeometryReader, verticalSizeClass)

## Phase 2: Factorio Game Mechanics (TODO)
- [ ] ItemType enum (ore, iron_plate, copper_ore, etc.)
- [ ] Recipe system (inputs → outputs, timeTicks)
- [ ] ProductionBuilding model (replace colonist jobs)
- [ ] Belt/logistics system (item transport)
- [ ] LogisticsSystem (replaces JobSystem)
- [ ] Update SaveManager for new game state

## Phase 3: Enemy Waves & Defense (TODO)
- [ ] Enemy spawning and pathfinding
- [ ] Turret buildings
- [ ] Wall/defense mechanics

## Phase 4: Polish & Optimization (TODO)
- [ ] Performance profiling (iOS battery, frame rate)
- [ ] Mobile UI polish (touch targets ≥44pt)
- [ ] Save/load with new mechanics

## Stashed 2026-06-21
- [ ] App Store Connect shows an "NYC macOS 1.0 Prepare for Submission" entry with a placeholder icon. Project's only existing target is macOS (NYCSurvive.xcodeproj) — check its `AppIcon.appiconset` for a missing/invalid 1024x1024 icon (export from repo-root `icon.svg` if missing), since iOS doesn't even exist yet per the "Ship iOS app" item above. **Checked 2026-06-23: icon is fine** — `icon_1024.png` is a valid 1024x1024 RGBA PNG, Contents.json maps it correctly to the mac 512x512@2x slot. Placeholder is just because no build has been archived/uploaded yet for this target (same pattern as Epiphany Mac/Echo) — needs a manual Xcode archive + upload, not a code fix.
