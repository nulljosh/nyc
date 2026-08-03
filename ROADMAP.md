# NYC Roadmap

## ASC readiness verified 2026-08-03
`asc review doctor --app 6782618198` reports **0 errors, 0 blocking** on iOS 1.0.0 (`PREPARE_FOR_SUBMISSION`): "No submission blockers detected. Submit the version when ready." Availability is fully set (175/175 territories, `availableInNewTerritories: true`) and pricing is a free schedule (`isFree: true`) — the old "availability is a dashboard-only dead end" belief was a CLI paging bug, now disproven (fetch territories with `--limit 200`).

This contradicts the root `CLAUDE.md` claim that NYC still has "3 ASC-web-UI-only items (App Privacy answers, privacy policy URL, iPad 12.9" screenshot)" — App Privacy is not flagged at all, and the remaining two are **warnings, not blockers**:
- [ ] privacy policy URL is empty (`en-US`, `appInfoLocalization` 1b2dd20c-83ff-4c4b-a2de-721682dd3e4d) — warning only
- [ ] subtitle is empty (same localization) — warning only

Not submitted this pass: submitting is a deliberate decision, and the sweep that verified this was availability-only in scope.

## App Store Connect (2026-07-03)
- [ ] Then: add iOS screenshots (iPhone 6.5"/6.7", see `feedback_appstore_screenshot_resolutions` memory), iOS description/keywords/supportUrl copied from macOS 2026-07-19 (subtitle still empty — optional). Then: screenshots + `asc review submit` for macOS and iOS separately when ready — deliberately not automated, submitting is a real decision.

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

## 2026-07-14 dump
- [ ] Splash screen redesign — sans-serif font, new app name applied throughout launch
- [ ] Investigate slow startup/loading
- [ ] Landing page (value prop, features, screenshots, download links, responsive)

## From App Store.pdf (imported 2026-07-28)
- [ ] Redesign the NYC Survive app icon (ASC 6782618198) so it actually matches what the game is (Times Square city sim), not a generic mark.

## From App Store.pdf (imported 2026-07-29)
- [ ] NYC Survive icon needs to be more accurate/themed — user now wants this improved (previously marked "fine, no action", that's stale).
