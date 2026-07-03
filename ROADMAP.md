# NYC Roadmap

## App Store Connect (2026-07-03)
- [x] Support URL set to `https://nyc.heyitsmejosh.com`.
- [x] iOS target exists (`NYCSurvive-iOS`), bundle ID + App Store provisioning profile registered.
- [ ] iOS submission BLOCKED: no iOS distribution signing cert with a local private key — generate one (CSR started in scratchpad, not finished) or import an existing cert+key, then `asc xcode export` → upload → submit.
- [ ] Description + keywords still missing for en-US listing (flagged by `asc apps info edit`).

## Phase 1: Unified Mobile Architecture (DONE)

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
