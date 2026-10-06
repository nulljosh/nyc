# nyc loop log (goal: more Factorio + Pikmin)

## Round 1, 2026-10-05: analysis

Read JobSystem, ResourceSystem, NeedsSystem, BuildingModel, TimeSystem.

Findings
- BUG: generator and billboard output lives inside the per-colonist loop in NeedsSystem.tick. They only produce when a colonist stands within 3 tiles, and produce once per colonist in range. Empty colony = zero power and zero cash. Food stall also drains food per colonist.
- Gather is instant adjacency harvest, 1 unit per tick, straight into the global pool. Nothing is carried, nothing is hauled.
- Buildings are pure proximity auras. No inputs, outputs, chains, or throughput. Nothing to optimise, so no Factorio feel.
- Every colonist needs a manual select-then-tap. No squad commands, so no Pikmin feel.
- Only 6 buildings and 5 resources. Tests: Tests/SimTests.swift only.

Plan (small slices, one per round)
1. Fix building production out of the colonist loop (BuildingSystem tick, once per building per tick). Test.
2. Carry and haul: gatherers carry a load to the nearest depot/shelter, Pikmin-style trips.
3. Squad: select group, one tap sends all, followers trail the leader.
4. Production chain: generator burns materials into power at a visible rate, throughput shown.
5. Day timer pressure (Pikmin day end) tied to night.

## Log
- R1: analysis done. Fixed: generator and billboard now produce once per building per tick, no colonist needed (NeedsSystem.tickBuildings). Test added, SimTests all green.
- Rule: colonists stay player-commanded (CLAUDE.md). Automation = machines the player builds + squad orders the player gives. No auto-assign.
- Next R2: player-ordered haul trips.
- R2: no serif was found. Removed all monospaced faces (Swift HUD + web --font-mono) so UI is sans only. Controls: selection persists after orders, drag-box selects squads, orders go to the whole squad, click a resource = gather, Esc deselects, selection ring drawn, tutorial copy rewritten. Tests added, green.
- R3: WEB BUG: #hud had pointer-events:auto set inline and covered the canvas, so no mouse click ever reached the game (fixed, hud.js). Web had no move/gather orders at all; added same squad controls + touch taps. Tutorial still taught removed DIRECTIVES; rewritten. Splash on web+native now New Game / Load Game / Settings (how to play), rounded font. Landing has a real scripted playthrough video.
- FOUND: VICTORY needs 15 alive and avg level 8, but nothing ever adds colonists past the starting 8. The web game cannot be won. Next: survivors arrive as the colony grows, then a real win condition + progression pacing for a few hours of play.
- FOUND: sprites are ~12px and resource nodes are tiny dots; unclear what is what. Next: bigger sprites + labels.
- R4: web is now winnable: a recruit arrives each day if there is a free bed (8 + 4 per shelter, cap 20) and 10 food; gathering gives 1 XP per 20 working ticks so avg lvl 8 takes roughly an hour of steady work. Tests in web/recruit.test.mjs. NOT yet mirrored in the Swift app (no recruits or victory there). Next: mirror to Swift, bigger sprites, real playtest to tune pacing.
