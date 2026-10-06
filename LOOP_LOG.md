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
