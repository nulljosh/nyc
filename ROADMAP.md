# NYC Roadmap

## App Store Connect (2026-07-03)
- [x] Support URL set to `https://nyc.heyitsmejosh.com`.
- [x] iOS target exists (`NYCSurvive-iOS`), bundle ID + App Store provisioning profile registered.
- [x] Generated new IOS_DISTRIBUTION cert (`38S6CX4DJ5`) with local private key, re-issued provisioning profile against it, exported and uploaded build 2 (`54a757cf-d560-4d07-a85e-ec9f49ca5f6a`) to ASC.
- [x] Description + keywords set for en-US (applied to existing macOS version localization — no iOS version exists to hold its own copy yet).
- [ ] iOS screenshots not yet generated/uploaded (blocked on the item below).
- [ ] BLOCKED 2026-07-03: `asc versions create --app 6782618198 --platform IOS` fails with "You cannot create a new version of the App in the current state." The macOS version 1.0 (build 1, uploaded 2026-06-21) has sat in `PREPARE_FOR_SUBMISSION` unsubmitted ever since — this is almost certainly what's locking new platform versions. Fix path: either submit/finish the macOS 1.0 version, or check Agreements/Tax/Banking status in ASC (incomplete agreements block new versions app-wide). Once unblocked: `asc versions create --platform IOS --version 1.0.0`, attach build 2 (`54a757cf-d560-4d07-a85e-ec9f49ca5f6a`), add iOS screenshots, then submit.

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
