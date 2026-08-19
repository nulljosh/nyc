# NYC Roadmap

## App Review rejection reason — READ FROM RESOLUTION CENTER 2026-08-12

**Guideline 5.6 — Developer Code of Conduct — Review Suspended.** Not an app-specific
defect. Verbatim: *"the current submission does not meet the required quality standard for
distribution on the App Store... this app is not eligible for resubmission before August
18th, 2026. Replies and resubmissions before this date will not be reviewed."*

Apple's listed next steps before resubmitting: no placeholder/unfinished/unrefined content;
every screen reviewed and tested; stable across **all** supported devices (iPad included if
the app is offered there); and **detailed notes of the improvements made** in the App Review
Information → Notes field. Continued similar submissions are warned as grounds for removal
from the Developer Program.

This hit 4 apps at once on 2026-08-09: curvely, nyc, transcriptly, wiretext.

Source: `asc web review show --app 6782618198 --apple-id trommatic@icloud.com` (needs `asc-login`;
the public API only returns a generic "unresolved issues" wrapper). Submissions frozen
The freeze lifted 2026-08-18; submission is now gated only on the four in-flight review verdicts.

## ASC state VERIFIED 2026-08-12 (`asc versions list`)

**Both platforms are `REJECTED`** — iOS 1.0.0 and macOS 1.0. The section below records both
as WAITING_FOR_REVIEW after the 2026-08-04 submission; they were reviewed and rejected.
Reasons are Resolution-Center-only (needs `asc-login`).

Freeze lifted 2026-08-18 (Guideline 5.6 suspension expired). Submitted that day and now
WAITING_FOR_REVIEW: Curvely iOS 1.2.0, Wiretext iOS 1.1.0, Wordroot iOS 1.0, Healstack iOS 2.3.4.
**Held pending those four verdicts — never a batch:** Sparkjar iOS+Mac, BCGD iOS+Mac, Wordroot Mac,
Lexly Mac. All six are `asc validate` clean (0 errors, 0 blocking) with a VALID build attached, so
each is one `asc review submit` away. Do not submit until the in-flight verdicts land.

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

**Deploy gotcha:** `web/.vercel` is a stale leftover. `nyc.heyitsmejosh.com` is a CNAME to `nyc-bum.pages.dev` — **Cloudflare Pages, not Vercel**. Deploying with `vercel --prod` succeeds and changes nothing live. Correct command:
```
cd web && npx wrangler pages deploy . --project-name nyc --commit-dirty=true
```
Cloudflare edge cache can serve the old page for a minute or two afterward; the `CLOUDFLARE_DNS_TOKEN` lacks cache-purge permission, so just wait it out.

Availability confirmed fine (175/175 territories, free price schedule) — the "dashboard-only dead end" belief was a CLI paging bug (fetch territories with `--limit 200`).

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

## App Store submission freeze — LIFTED 2026-08-18
Freeze lifted 2026-08-18 (Guideline 5.6 suspension expired). Submitted that day and now
WAITING_FOR_REVIEW: Curvely iOS 1.2.0, Wiretext iOS 1.1.0, Wordroot iOS 1.0, Healstack iOS 2.3.4.
**Held pending those four verdicts — never a batch:** Sparkjar iOS+Mac, BCGD iOS+Mac, Wordroot Mac,
Lexly Mac. All six are `asc validate` clean (0 errors, 0 blocking) with a VALID build attached, so
each is one `asc review submit` away. Do not submit until the in-flight verdicts land.
- [ ] NYC Survive iOS 1.0.0 + macOS 1.0 SUSPENDED under 5.6 (6782618198). Unlike the others this is a real app (35 Swift files / 3,615 lines) and was likely swept up in the account-level action. Keep it. Resubmit LAST, after the thin apps are withdrawn, with detailed App Review notes describing the improvements.

## 2026-08-10 — App Review notes are EMPTY, and 5.6 requires them
Apple's 5.6 letter lists this as a required action before resubmitting: "Include detailed notes of
the improvements made to the app in the Notes field of the App Review Information section in App
Store Connect." NYC Survive's review-details `notes` field is currently empty (verified via
`asc review details-for-version`). Curvely and Nullfolio have notes; NYC Survive and Wiretext do not.

## From Apple Notes (imported 2026-08-11)
- [ ] Add light mode
- [ ] Build a landing/marketing page (currently app only, no preview)

> Resume note (2026-08-11): a `wip: partial work from /work notes ingest` commit holds unfinished, unverified changes for the items above. Review `git show HEAD` before building on it — it was committed mid-flight, not reviewed, and is unpushed.

## Guideline 5.6 resubmission checklist — prepared 2026-08-12, DO NOT SUBMIT BEFORE 2026-08-18

Apple's 5.6 notice makes one thing mandatory that is easy to miss: **"Include detailed notes
of the improvements made to the app in the Notes field of the App Review Information section."**
A resubmission without those notes is a wasted attempt, and 5.6 warns that repeat submissions
with the same issues can mean removal from the Developer Program.

The notes must describe improvements that were **actually made**. Nothing has been written into
ASC yet on purpose — there is nothing truthful to claim until the work below is done.

Before resubmitting:

- [ ] Fix something real, and write down what. No placeholder, unfinished, or unrefined content
      anywhere in the app.
- [ ] Walk every screen and interaction once, on device. 5.6 is a quality judgement, not a
      spec violation — the reviewer decided the app felt unfinished.
- [ ] Test on **every** device family the app is offered on. If `TARGETED_DEVICE_FAMILY` is
      `"1,2"` the app must be genuinely good on iPad, not merely launchable. Narrowing to
      iPhone-only is a legitimate alternative to making iPad good.
- [ ] Confirm a non-empty "What's New" (`asc metadata push`).
- [x] Then write the improvement notes — **already done**, both platforms (verified 2026-08-19).
      Read them back with `asc review details-for-version --version-id <VERSION id>`
      (iOS `f595fe11-22d1-4169-85c4-b82dc7788a36`, macOS `4610ab68-6b42-4ae0-9ba5-0965a83781a5`).
- [ ] Only then submit. Review detail id for this version: `9d5b49ba-8c2d-41ef-8bcb-80e59e7dec18 (iOS) / d7fd2481-09c9-4a23-b5e3-83738f9a4199 (macOS)`.

### From Notes (2026-08-14)
- [ ] **Automated full-playthrough test.** A script that drives an actual game start to finish, so a
      regression in the game loop fails loudly. Strictly a test harness — the shipped game must never
      play itself (see [[project_nyc_no_autoplay]]; the directive engine was deleted 2026-07-02 and
      does not come back).

## Ingested 2026-08-18
- [x] App Review notes still empty for 5.6 resubmission — **STALE CLAIM, verified 2026-08-19.**
      Both platforms already carry the full 5.6 improvement notes (~2,300 chars each), read back
      via `asc review details-for-version --version-id <id>`. iOS detail `9d5b49ba-8c2d-41ef-8bcb-80e59e7dec18`,
      macOS detail `d7fd2481-09c9-4a23-b5e3-83738f9a4199`. Note the flag is `--version-id` (the
      version id), not `--id` (the detail id) — the checklist below had that wrong.

## 5.6 defect verification 2026-08-18

**Verdict: "Play Now does nothing" reproduced-and-already-fixed; app not resubmitted.**

- Commit `d71b944` ("Fix Play Now: serve the game at /app") closed it.
  `nyc.heyitsmejosh.com` → 200, and the landing page's `Play now` link (`landing/index.html`
  lines 132/175, `href="/app"`) → 200 after redirect to `/app/`. Claim no longer holds.
- Not a WKWebView shell: `Sources/` is 3126 lines of native Swift, no WebKit import.
- ASC state unchanged and correct: iOS 1.0.0 and macOS 1.0 both REJECTED, **neither
  resubmitted**. Still blocked on an iOS distribution signing cert with a local private key
  (`ship-plan.md`). Leave it that way until Curvely/Wiretext clear review — one app at a time.
- `nycsurvive.heyitsmejosh.com` does not resolve, but no ASC record references it. Cosmetic.

## From Notes (imported 2026-08-19)
- [x] Tutorial is gone — **root cause found and fixed 2026-08-19.** The *web* game was the
      regression (native iOS/macOS was always fine — `onNewGame` sets `tutorialStep = 0`).
      Commit `68e72d5` ("disable autoplay") added `state.tutorialStep = null; // skip tutorial
      in auto-start` inside `freshWorld()` in `web/js/main.js`. But there is no auto-start any
      more — `freshWorld()` is only reached from the NEW GAME button and the failed-load
      fallback, so that line silently killed the tutorial for *every* new game. Deleted the
      line; `createGameState()` already defaults `tutorialStep: 0`, and the load path still
      nulls it explicitly. Regression test added at `web/tutorial.test.mjs` (`node
      web/tutorial.test.mjs`). Rebuilt via `scripts/build-site.sh` and deployed to Cloudflare
      Pages; verified the shipped `/app/js/main.js` no longer contains the line and
      `nyc.heyitsmejosh.com/app/` returns 200. No autoplay/directive code reintroduced.

## 2026-08-19 — hold confirmed, NOT resubmitted

Checked before doing anything: both NYC versions are still `REJECTED`
(iOS 1.0.0 `f595fe11-22d1-4169-85c4-b82dc7788a36`, macOS 1.0 `4610ab68-6b42-4ae0-9ba5-0965a83781a5`).

**Did not submit, on purpose.** The four in-flight reviews this repo gates on have not returned
a verdict — all still `WAITING_FOR_REVIEW` as of today: Curvely iOS 1.2.0, Wiretext iOS 1.1.0,
Wordroot iOS 1.0, Healstack iOS 2.3.4. (Wordroot macOS 1.0 is `PREPARE_FOR_SUBMISSION`.) The
standing one-app-at-a-time rule holds, and 5.6 explicitly warns that repeat submissions with the
same issues risk removal from the Developer Program.

`asc web review show` could not be re-read: Apple's SRP signin endpoint returned **503** on both
`asc web review show` and `asc-login`. Server-side and transient — not a credential problem, and
no 2FA prompt was ever reached. The verbatim reason recorded 2026-08-12 (Guideline 5.6,
account-level, not an app-specific defect) is still the best information we have.

- [ ] Resubmit NYC iOS 1.0.0 + macOS 1.0 once the four in-flight verdicts land. Still also
      blocked on an iOS distribution signing cert with a local private key (see `ship-plan.md`).
      The 5.6 improvement notes are already written on both platforms, so once unblocked this is
      a build + `asc review submit` away. The tutorial fix above is a genuine, describable
      improvement to add to the notes at that time.
