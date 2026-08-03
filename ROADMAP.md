# NYC Roadmap

## 2026-08-03 — macOS SUBMITTED, iOS one screenshot away

**macOS 1.0 → WAITING_FOR_REVIEW** (submission `55ebe4b1-9748-437d-95f9-f28b9e472d67`, submitted 23:53Z).
Fixed to get there: build `f7a6525b` had no encryption declaration —
`asc builds update --build-id f7a6525b-4a85-4718-a4bd-7ee0b4dc9181 --uses-non-exempt-encryption=false`.

**iOS 1.0.0 remains `PREPARE_FOR_SUBMISSION`, blocked on exactly one thing:**
- [ ] **iPad Pro 12.9" screenshot (`ipadPro129`) required** — the app is `TARGETED_DEVICE_FAMILY: "1,2"`, so Apple demands an iPad screenshot. Only `APP_IPHONE_65` exists today (set `1621cf31-af8d-48f8-86dc-8c44aceb1ad7`, version localization `d639a268-fe50-4209-8737-90698375064d`). Capture on an iPad Pro 12.9" sim, then:
  `asc screenshots upload --version-localization d639a268-fe50-4209-8737-90698375064d --device-type IPAD_PRO_3GEN_129 --file <png>`
  then add the version to a submission and submit (see the exact sequence below). Deferred this pass at 81% session usage — a sim run costs ~10%.

**Sequence that works once the screenshot is up** (iOS version id `f595fe11-22d1-4169-85c4-b82dc7788a36`):
```
asc review items add --submission <sub-id> --item-type appStoreVersions --item-id f595fe11-22d1-4169-85c4-b82dc7788a36
asc review submissions-submit --id <sub-id> --confirm
```
An empty orphan iOS submission `9338674e-4786-4003-b90a-b66ac0b95381` (READY_FOR_REVIEW, 0 items) already exists and can be reused — `items add` against it failed only because of the screenshot, not because the submission is bad.

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
