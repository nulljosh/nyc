# NYC Roadmap

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
- [ ] App Store Connect shows an "NYC macOS 1.0 Prepare for Submission" entry with a placeholder icon. Project's only existing target is macOS (TimesSquareSim.xcodeproj) — check its `AppIcon.appiconset` for a missing/invalid 1024x1024 icon (export from repo-root `icon.svg` if missing), since iOS doesn't even exist yet per the "Ship iOS app" item above.
