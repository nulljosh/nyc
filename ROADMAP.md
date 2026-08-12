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
- [x] iOS screenshots/metadata + submit — done; verified 2026-08-04 that iOS 1.0.0 and macOS 1.0 are both WAITING_FOR_REVIEW.

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

## From App Store.pdf (imported 2026-07-29)
- [ ] NYC Survive icon needs to be more accurate/themed — user now wants this improved (previously marked "fine, no action", that's stale).

## App Store submission freeze — until 2026-08-18
- [ ] **BLOCKED: no App Store submission on any app until 2026-08-18.** Account is under a Guideline 5.6 Developer Code of Conduct review suspension (Curvely, Transcriptly, Wiretext, NYC Survive). Apple warns that continued similar submissions may result in removal from the Apple Developer Program. Full detail: wiki `ship-plan.md` § "Guideline 5.6 suspension (2026-08-10)". TestFlight builds, pushes and web deploys are still fine.
- [ ] NYC Survive iOS 1.0.0 + macOS 1.0 SUSPENDED under 5.6 (6782618198). Unlike the others this is a real app (35 Swift files / 3,615 lines) and was likely swept up in the account-level action. Keep it. Resubmit LAST, after the thin apps are withdrawn, with detailed App Review notes describing the improvements.

## 2026-08-10 — App Review notes are EMPTY, and 5.6 requires them
Apple's 5.6 letter lists this as a required action before resubmitting: "Include detailed notes of
the improvements made to the app in the Notes field of the App Review Information section in App
Store Connect." NYC Survive's review-details `notes` field is currently empty (verified via
`asc review details-for-version`). Curvely and Nullfolio have notes; NYC Survive and Wiretext do not.
- [ ] Before the post-Aug-18 resubmit, write real App Review notes: what this app is (35 Swift files / ~3,600 lines, a real game — not a wrapper), and what changed since the suspended submission. This is the single cheapest thing that separates NYC Survive from the thin apps it got batched with.

## From Apple Notes (imported 2026-08-11)
- [ ] Add light mode
- [ ] Build a landing/marketing page (currently app only, no preview)
