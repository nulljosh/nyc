# NYC Roadmap

## 2026-08-04 — BOTH PLATFORMS SUBMITTED

**iOS 1.0.0 → WAITING_FOR_REVIEW** (submission `9338674e-4786-4003-b90a-b66ac0b95381`, build **6** `fcac5768-0102-41bb-9a32-667479f660e7`).
**macOS 1.0 → WAITING_FOR_REVIEW** (submission `55ebe4b1-9748-437d-95f9-f28b9e472d67`).

The orphan iOS submission was reused rather than minting a new one — `items add` against it succeeded once the screenshot existed, confirming the submission itself was never bad.

### Shipped a new build (6), not just a screenshot

Capturing the iPad screenshot surfaced a real defect: **`showsFPS`/`showsNodeCount` were set unconditionally**, so the debug FPS/node counter rendered on top of gameplay for real users in the shipping build (5). Both `Sources/App/NYCSurviveApp.swift` and `Sources/AppiOS/NYCSurviveApp.swift` are now `#if DEBUG` gated. Build 6 was archived from Release and verified clean before capture.

Screenshot is real gameplay (colony grid, resource HUD, 5 colonists, minimap), captured from a **Release** sim build so it matches what ships — asset `e0bc7e8f-432f-4a44-8f08-822dfbac1a8a`, set `63384daa-adb9-4bc1-bae9-3bfb493afa1b`, 2064×2752.

Entitlements verified on the exported IPA — NYC does **not** have the ITMS-90886 defect that affects curvely/wiretext/inkpress:
```
application-identifier  QMM486NPYC.com.heyitsmejosh.nyc
beta-reports-active     true      ← TestFlight-eligible
get-task-allow          false
```

### Still open
- [ ] In-app title screen reads **"TIMES SQUARE / SURVIVAL SIMULATOR"** while the App Store name is "NYC Survive". The in-game log does say "Welcome to NYC Survive", so it's only the title screen. Both existing store screenshots (iPhone 6.5" and the new iPad one) are consistent with the store name, and this wasn't flagged in review — but it's the same in-app branding drift that caught four other apps on 2026-08-03. Decide whether the title screen should say NYC Survive.

### Corrections to the earlier 2026-08-03 note (it was wrong)
**`asc review doctor` is NOT a reliable submission gate.** It reported `errors: 0, blocking: 0` on iOS while `asc review items add` immediately rejected the version with two hard blockers doctor never mentioned:
- `appDataUsages`: "You must have published answers to your app's data usages"
- `appScreenshots`: "A screenshot with type ipadPro129 is required but was not provided"

So the original root-`CLAUDE.md` claim of "3 ASC-web-UI-only items" was **right**, and the "stale, warnings only" verdict was wrong. Always try `review items add` to learn the real blockers — doctor's clean bill means nothing.

Two of those three are now fixed **via CLI, no dashboard needed** (also disproving "ASC-web-UI-only"):
- [x] App Privacy published — `asc web privacy apply --app 6782618198 --file <json> --confirm` then `asc web privacy publish --app 6782618198 --confirm`. Declaration is `DATA_NOT_COLLECTED`. Note `publish` 409s unless `apply --file` runs first.
- [x] Privacy policy URL set to `https://nyc.heyitsmejosh.com/privacy` — a real policy page was written (`web/privacy.html`) and deployed, because `/privacy` previously returned HTTP 200 serving the *game page* via catch-all. Pointing Apple at that would have been worse than leaving it blank.
- [x] Subtitle set to "Times Square colony sim" (30-char limit; "Colony sim in besieged Times Square" was rejected as too long).

**Deploy gotcha:** `web/.vercel` is a stale leftover. `nyc.heyitsmejosh.com` is a CNAME to `nyc-bum.pages.dev` — **Cloudflare Pages, not Vercel**. Deploying with `vercel --prod` succeeds and changes nothing live. Correct command:
```
cd web && npx wrangler pages deploy . --project-name nyc --commit-dirty=true
```
Cloudflare edge cache can serve the old page for a minute or two afterward; the `CLOUDFLARE_DNS_TOKEN` lacks cache-purge permission, so just wait it out.

Availability confirmed fine (175/175 territories, free price schedule) — the "dashboard-only dead end" belief was a CLI paging bug (fetch territories with `--limit 200`).

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
