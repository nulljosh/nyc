# NYC Roadmap

## App Store Connect (2026-07-03)
- [x] Support URL set to `https://nyc.heyitsmejosh.com`.
- [x] iOS target exists (`NYCSurvive-iOS`), bundle ID + App Store provisioning profile registered.
- [x] Generated new IOS_DISTRIBUTION cert (`38S6CX4DJ5`) with local private key, re-issued provisioning profile against it, exported and uploaded build 2 (`54a757cf-d560-4d07-a85e-ec9f49ca5f6a`) to ASC.
- [x] Description + keywords set for en-US (applied to existing macOS version localization — no iOS version exists to hold its own copy yet).
- [x] Root cause confirmed 2026-07-03: `asc validate --app 6782618198 --version-id 4610ab68-6b42-4ae0-9ba5-0965a83781a5 --platform MAC_OS` showed the stuck macOS 1.0 version had 30 blocking submission errors — that's what's locking new platform versions app-wide.
- [x] Fixed via API: primary category (GAMES), review contact (Joshua Trommel / trommatic@icloud.com / +17782014533, demo account not required), build encryption exemption (`asc builds update --uses-non-exempt-encryption=false`), content rights (no 3rd-party content), age rating (all-none baseline + infrequent/mild violence + weapons), free price schedule (`asc pricing schedule create --free`), one macOS screenshot uploaded (1280x800, `.asc/screenshots/mac_set/`).
- [x] Availability initialized 2026-07-03 via ASC dashboard (Pricing and Availability → Set Up Availability → All 175 Countries or Regions) — the one field the public API couldn't touch until visited once in the UI.
- [x] **macOS 1.0 now validates with 0 blocking errors** (`asc validate --app 6782618198 --version-id 4610ab68-6b42-4ae0-9ba5-0965a83781a5 --platform MAC_OS`). Only 2 cosmetic warnings remain (empty subtitle, no privacy policy URL) — don't block submission.
- [x] Noticed in ASC dashboard: an iOS App 1.0.0 version already exists in `Prepare for Submission` state (created automatically once availability/pricing were touched) — the earlier `asc versions create --platform IOS` API block appears resolved.
- [x] iOS build 5 (0afcefa0) attached to version f595fe11 via asc 2026-07-19 — processed VALID
- [ ] Then: add iOS screenshots (iPhone 6.5"/6.7", see `feedback_appstore_screenshot_resolutions` memory), iOS description/keywords/supportUrl copied from macOS 2026-07-19 (subtitle still empty — optional). Then: screenshots + `asc review submit` for macOS and iOS separately when ready — deliberately not automated, submitting is a real decision.

### Build 2 rejection fix attempt (2026-07-03, build 3)
- [x] Root cause found: `Resources/` (the asset catalog) was never in the `NYCSurvive-iOS` target's `project.yml` sources — no app icon has ever shipped in any iOS build regardless of `Contents.json`. Added the target's resources build phase, `ASSETCATALOG_COMPILER_APPICON_NAME`, generated 120/152/167/76pt icon renders, fixed `INFOPLIST_KEY_UILaunchScreen_Generation`, added `INFOPLIST_KEY_UISupportedInterfaceOrientations~ipad`. Confirmed locally in a clean simulator build: `CFBundleIconName`/icon files/orientations all present in the compiled `Info.plist`. Committed `38f768d`.
- [x] Bumped `CURRENT_PROJECT_VERSION` to 3, archived, exported (manual signing — automatic signing couldn't find a profile via `xcodebuild -exportArchive`; used the local `nyc-ios-appstore.mobileprovision` + `iPhone Distribution: Joshua Trommel` cert directly), uploaded via `asc builds upload --wait`.
- [x] **Build 3 upload FAILED** (90474/90055) — superseded: root cause fixed via a real checked-in `Resources/Info-iOS.plist` with both orientation keys + bundle ID correction (see nyc/CLAUDE.md 2026-07-04 entry). Build 5 (0afcefa0) uploaded 2026-07-19 and processed VALID per top-of-file entry above.

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

## From Icons.pdf / Asc.pdf (imported 2026-07-12)
- [x] NYC Survive submission blocked on iOS distribution signing cert with local private key — resolved: cert `38S6CX4DJ5` generated 2026-06-30/07-03, iOS builds 2-5 uploaded successfully since (build 5 VALID 2026-07-19).

## 2026-07-14 dump
- [ ] Splash screen redesign — sans-serif font, new app name applied throughout launch
- [ ] Investigate slow startup/loading
- [ ] Landing page (value prop, features, screenshots, download links, responsive)
