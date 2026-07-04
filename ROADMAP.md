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
- [ ] iOS build uploaded (`asc builds upload`, uploadId `54a757cf-d560-4d07-a85e-ec9f49ca5f6a`) but not yet showing in `asc builds list` — Apple is still processing it (normal, can take 15-30+ min). Once it appears: `asc versions attach-build --version-id f595fe11-22d1-4169-85c4-b82dc7788a36 --build <new-build-id>`.
- [ ] Then: add iOS screenshots (iPhone 6.5"/6.7", see `feedback_appstore_screenshot_resolutions` memory), fill iOS-specific description/keywords/subtitle (currently only set on the macOS localization), then `asc review submit` for macOS and iOS separately when ready — deliberately not automated, submitting is a real decision.

### Build 2 rejection fix attempt (2026-07-03, build 3)
- [x] Root cause found: `Resources/` (the asset catalog) was never in the `NYCSurvive-iOS` target's `project.yml` sources — no app icon has ever shipped in any iOS build regardless of `Contents.json`. Added the target's resources build phase, `ASSETCATALOG_COMPILER_APPICON_NAME`, generated 120/152/167/76pt icon renders, fixed `INFOPLIST_KEY_UILaunchScreen_Generation`, added `INFOPLIST_KEY_UISupportedInterfaceOrientations~ipad`. Confirmed locally in a clean simulator build: `CFBundleIconName`/icon files/orientations all present in the compiled `Info.plist`. Committed `38f768d`.
- [x] Bumped `CURRENT_PROJECT_VERSION` to 3, archived, exported (manual signing — automatic signing couldn't find a profile via `xcodebuild -exportArchive`; used the local `nyc-ios-appstore.mobileprovision` + `iPhone Distribution: Joshua Trommel` cert directly), uploaded via `asc builds upload --wait`.
- [ ] **Build 3 upload FAILED** — ASC errors `90474` and `90055`. Inspecting the actual archived IPA's `Info.plist`, only the plain `UISupportedInterfaceOrientations` key survived the `GENERATE_INFOPLIST_FILE` merge — the `~ipad`-suffixed conditional build setting did NOT get merged in as a second plist key (both keys are present in `project.pbxproj`, but only one lands in the built Info.plist). This suggests `INFOPLIST_KEY_*~ipad` conditional settings aren't honored by the plist generator the way plain per-platform xcconfig conditionals are.
  - Next step: drop `GENERATE_INFOPLIST_FILE` for the iOS target in favor of a real checked-in `Info.plist` (via `INFOPLIST_FILE`) with both orientation keys hardcoded, and re-test. `90055` not yet decoded — check on next pass.
  - Exported IPA is at `/tmp/NYCSurvive-iOS-export/NYCSurvive-iOS.ipa` (ephemeral, gone after reboot) — re-archive from `project.yml` if it's no longer there.

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
