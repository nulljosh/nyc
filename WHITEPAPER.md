# NYC Survive Technical Whitepaper

**v1.3.1** | August 2026

NYC Survive is a Factorio-style production game for iOS and macOS: place
buildings on a grid, chain them into production lines, and keep the city fed.
SpriteKit, Swift 6, one shared codebase for both platforms. A web port lives
at nyc.heyitsmejosh.com.

## Core Mechanic: Auto-Pull Production Chains

The economy is item-based (ore, copper ore, iron plates, gears) and flows
through four building types — miner, smelter, assembler, storage. The defining
rule is **adjacency auto-pull**: a building automatically pulls its recipe
inputs from adjacent buildings, so logistics is spatial. A working factory is
`miner → smelter → assembler` laid out tile-by-tile, with progress bars
showing each recipe tick.

Colonists are **fully player-controlled**. The original auto-directive engine
was deleted (2026-07-02) — colonists act only on explicit commands (select,
then tap a destination via `JobSystem.commandMove()`), and auto-assignment
must not be reintroduced. The game is deliberately a hands-on sim, not an
idle game.

## Architecture

- **Rendering**: SpriteKit only — no UIKit/AppKit views inside the game scene.
- **Layout**: responsive portrait + landscape on iOS, fixed 1280×800 on macOS,
  from one `Sources/` tree with per-platform app entry points (xcodegen,
  `project.yml`).
- **State**: `GameState.swift` is the single source of truth;
  `SaveManager.swift` serializes it to JSON across a 3-slot save system with
  auto-save.
- **Systems**: `GameScene.swift` (input → command wiring),
  `JobSystem.swift` (manual colonist commands), `BuildSystem.swift`
  (placement/demolition with ore costs).

Note: `Sources-Shared/` on disk is a stale, non-compiled duplicate — the build
target is `Sources/` only.

## Planned: Spatial Partitioning

Two loops in `web/js/systems.js` scale badly with colony size. The colonist
interaction pass compares every colonist against every other colonist (O(n²)
per tick), and the job-assignment pass walks the entire resource-node list for
each idle colonist to find the nearest one (O(n·m) per tick). Both run every
frame, so the tick cost grows quadratically with a number the player is
directly encouraged to increase.

The fix is a uniform spatial hash: one grid of buckets sized to roughly the
interaction radius, rebuilt from scratch each tick (rebuilding is O(n) and
cheaper than maintaining incremental membership). Neighbour queries then read
the 3×3 block of buckets around a position instead of the whole list, which
turns both passes into O(n) with a small constant for the density the map
actually supports.

The same grid answers "nearest resource node" by searching outward ring by
ring from the colonist's bucket and stopping at the first ring that cannot
contain anything closer than the best candidate found so far.

## Platforms

| Platform | Status |
|---|---|
| macOS | Builds clean (Xcode 16+, macOS 15+) |
| iOS | Build on ASC, processed clean; submission still gated on the ASC-web-only items (App Privacy answers, privacy policy URL, iPad 12.9" screenshot) |
| Web | Port recovered to `web/`, deploys to Cloudflare Pages (the Vercel project was deleted 2026-08-17) |

## Roadmap

Phase 3 (optional): enemy waves, turret defense, walls, pollution.
Phase 2.5 (optional): conveyor belts, item filters. Phase 4: performance
profiling for iOS battery and frame rate.
