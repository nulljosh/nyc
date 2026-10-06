# NYC Survive loop handoff (2026-10-05, 21:32 PT)

## What the loop is

The NYC Survive loop is a continuous QA and refinement cycle. The game is winnable and shipped to App Review; the loop exits when approved or when directed.

## Where things stand

iOS 1.1.0 approved and live as of 2026-10-06 03:30 PT. macOS 1.1.0 still WAITING_FOR_REVIEW. Game is fully winnable with recruits, squad controls, auto-feed, building upkeep, night raids unless PATROL, tutorial, bigger sprites with labels, new splash with Settings, night tint for day timer visibility. Headless bot plays to victory in ~2 hours; CI runs it (winnable.test.mjs) plus Swift SimTests on macos-26. Landing page has real playthrough video. Web HUD functional, no blocking issues. Loop is quiet: hourly App Review checks on macOS. Mid-game QA on web pending (test live recruits, first raid scenarios).

## Next in order

1. Live mid-game QA on the web: recruits arriving, a breakdown, first raid; fix whatever looks wrong
2. Tension and content for the second hour (threats, more buildings, end-game variety)
3. Watch App Review for 1.1.0 approvals on both platforms
4. Ship 1.2.0 if any issues found; iterate on feedback or refine content until approved

## Restart prompt

```
NYC Survive loop restarts. iOS 1.1.0 live as of 2026-10-06 03:30 PT; macOS 1.1.0 in review. Game fully winnable with recruits, squad controls, auto-feed, upkeep, raids, tutorial, night tint for timer. Bot plays to victory ~2 hours; CI tests it. Landing has real video. Loop quiet: hourly App Review checks on macOS. Web QA pending: live mid-game (recruits arriving, first raid), fix issues, add tension/content for hour two if macOS approved. Watch App Review.
```
