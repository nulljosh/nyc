# NYC Survive loop handoff (2026-10-05, 21:32 PT)

## What the loop is

The NYC Survive loop is a continuous QA and refinement cycle. The game is winnable and shipped to App Review; the loop exits when approved or when directed.

## Where things stand

Game shipped 1.1.0 to App Review on iOS and macOS (both WAITING_FOR_REVIEW, build 202610052145, ~21:55 PT Oct 5). Made winnable with recruits (daily spawns tied to beds and food), squad controls (click/drag-select survivors, click ground to move, click resources to gather, Esc deselects), auto-feed from stockpile, building upkeep (burn materials when empty), night raids every third night unless someone is on PATROL, 10-step tutorial, bigger sprites with labels, new splash with Settings and how-to-play. Web click-blocking bug fixed (nobody could select/move/build before). Headless bot (node web/sim.mjs) plays to victory in ~2 hours; CI now runs it (winnable.test.mjs) plus Swift SimTests on macos-26. Landing page has a real playthrough video.

Web HUD is functional. Game plays from start to finish. Mid-game QA pending on nyc.heyitsmejosh.com (live recruits, breakdown view, first raid).

## Next in order

1. Live mid-game QA on the web: recruits arriving, a breakdown, first raid; fix whatever looks wrong
2. Tension and content for the second hour (threats, more buildings, end-game variety)
3. Watch App Review for 1.1.0 approvals on both platforms
4. Ship 1.2.0 if any issues found; iterate on feedback or refine content until approved

## Restart prompt

```
NYC Survive loop restarts. Shipped 1.1.0 to App Review on iOS and macOS (WAITING_FOR_REVIEW). Game is winnable with recruits, squad controls, auto-feed, building upkeep, night raids, tutorial, bigger sprites, new splash. Web HUD fixed. Bot plays to victory ~2 hours; CI tests it. Landing has real video. Web QA pending: play mid-game (recruits arriving, first raid), fix issues, then add tension/content for hour two. Watch App Review.
```
