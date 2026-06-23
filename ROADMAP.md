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
- [x] App Store Connect shows an "NYC macOS 1.0 Prepare for Submission" entry with a placeholder icon. **Resolved 2026-06-23**: icon was always fine (`icon_1024.png`, valid 1024x1024 RGBA PNG, correctly mapped in Contents.json). Real cause: builds were already archived + uploaded (`asc builds list` showed 2 VALID macOS builds from 06-21/06-22) but never attached to the app store version. Fixed with `asc versions attach-build --version-id 4610ab68-6b42-4ae0-9ba5-0965a83781a5 --build 53ed106f-72d0-4b0a-9906-1eda12ef8daf`. Placeholder should clear in ASC now that a build is linked.
