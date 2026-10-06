// Headless bot: plays the web game start to finish and reports pace. node web/sim.mjs [seed-ignored]
import { createGameState, createColonist, checkVictory, currentPhase, randomColonistName } from './js/state.js';
import { generateWorld, GRID_SIZE, TileType } from './js/world.js';
import { Pathfinder } from './js/pathfinder.js';
import { needsTick, jobTick, resourceTick, recruitTick, placeBuilding, canPlace } from './js/systems.js';

const TPD = 240, TICK_S = 0.25; // medium difficulty
const w = generateWorld(); const grid = w.grid;
const state = createGameState(); state.resourceNodes = w.resources;
const pf = new Pathfinder(); pf.buildGraph(grid);
const c0 = GRID_SIZE / 2;
for (let i = 0; i < 8; i++) {
    let col = c0, row = c0;
    outer: for (let dc = 0; dc < 10; dc++) for (let dr = 0; dr < 10; dr++) {
        const t = grid[c0 + dr]?.[c0 + dc + i]; if (t === 0 || t === 1 || t === 4) { col = c0 + dc + i; row = c0 + dr; break outer; }
    }
    { const c = createColonist(randomColonistName(state.colonists), col, row); c.job = 'gather'; state.colonists.push(c); }
}
const alive = () => state.colonists.filter(c => c.state !== 'dead');
function tryBuild(type) {
    const a = alive()[0]; if (!a) return false;
    for (let d = 2; d < 12; d++) for (const [dc, dr] of [[d,0],[-d,0],[0,d],[0,-d],[d,d],[-d,-d]]) {
        const col = a.col + dc, row = a.row + dr;
        if (canPlace(type, col, row, grid, state)) { return !!placeBuilding(type, col, row, grid, state, pf); }
    }
    return false;
}
let lastLog = -1, won = null, peakDead = 0;
for (let t = 1; t <= TPD * 400; t++) {
    state.currentTick = t; state.currentHour = Math.floor((t % TPD) / 10);
    // bot decisions, once per half-day (a human would do this every few minutes)
    if (t % 60 === 0) {
        for (const c of alive()) { if (c.job === 'gather' && c.sleep < 35) c.job = 'idle'; else if (c.job === 'idle' && c.sleep > 85) c.job = 'gather'; }
        const n = alive().length, shelters = state.buildings.filter(b => b.type === 'shelter').length;
        if (n >= 8 + 4 * shelters) tryBuild('shelter');
        if (state.buildings.filter(b => b.type === 'foodStall').length < Math.ceil(n / 3)) tryBuild('foodStall');
        if (state.buildings.filter(b => b.type === 'filterStation').length < Math.ceil(n / 5)) tryBuild('filterStation');
        if (state.buildings.filter(b => b.type === 'generator').length < 2) tryBuild('generator');
    }
    needsTick(state); jobTick(state, pf); resourceTick(state); recruitTick(state);
    peakDead = Math.max(peakDead, state.colonists.length - alive().length);
    if (t % (TPD * 5) === 0 && t !== lastLog) {
        lastLog = t; const a = alive(); const avg = a.reduce((s, c) => s + c.level, 0) / (a.length || 1);
        console.log(`day ${t / TPD} | ${(t * TICK_S / 60).toFixed(0)} min | alive ${a.length} | avg lvl ${avg.toFixed(1)} | ${currentPhase(state)} | food ${state.resources.food} mat ${state.resources.materials} pwr ${state.resources.power} dead ${state.colonists.length - a.length}`);
    }
    if (checkVictory(state)) { won = t; break; }
    if (!alive().length) { console.log('EVERYONE DIED at day', t / TPD); break; }
}
console.log(won ? `VICTORY at day ${(won / TPD).toFixed(0)} = ${(won * TICK_S / 3600).toFixed(2)} hours of play` : 'NO VICTORY in 400 days');
const d = state.colonists.filter(c => c.state === 'dead').slice(-5).map(c => `h${c.hunger.toFixed(0)} o${c.oxygen.toFixed(0)} s${c.stress.toFixed(0)} z${c.sleep.toFixed(0)} hp${c.health.toFixed(0)}`);
console.log('last dead needs:', d.join(' | '));
