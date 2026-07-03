# NYC Roadmap

## App Store Connect (2026-07-03)
- [x] Support URL set to `https://nyc.heyitsmejosh.com`.
- [x] iOS target exists (`NYCSurvive-iOS`), bundle ID + App Store provisioning profile registered.
- [x] Generated new IOS_DISTRIBUTION cert (`38S6CX4DJ5`) with local private key, re-issued provisioning profile against it, exported and uploaded build 2 (`54a757cf-d560-4d07-a85e-ec9f49ca5f6a`) to ASC.
- [x] Description + keywords set for en-US (applied to existing macOS version localization — no iOS version exists to hold its own copy yet).
- [ ] iOS screenshots not yet generated/uploaded (blocked on the item below).
- [x] Root cause confirmed 2026-07-03: `asc validate --app 6782618198 --version-id 4610ab68-6b42-4ae0-9ba5-0965a83781a5 --platform MAC_OS` showed the stuck macOS 1.0 version had 30 blocking submission errors — that's what's locking new platform versions app-wide.
- [x] Fixed via API: primary category (GAMES), review contact (Joshua Trommel / trommatic@icloud.com / +17782014533, demo account not required), build encryption exemption (`asc builds update --uses-non-exempt-encryption=false`), content rights (no 3rd-party content), age rating (all-none baseline + infrequent/mild violence + weapons).
- [ ] Still blocking macOS 1.0 submission (real content/decisions, not scriptable): screenshots (none uploaded for any device size) and app availability/pricing/territories (`asc pricing` — not yet configured).
- [ ] Once macOS 1.0 clears validation and is submitted/resolved: re-run `asc versions create --app 6782618198 --platform IOS --version 1.0.0`, attach build 2 (`54a757cf-d560-4d07-a85e-ec9f49ca5f6a`), add iOS screenshots, then submit.

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
