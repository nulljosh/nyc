// Recruits arrive daily when there is a free bed and food; gathering levels colonists up.
import { test } from 'node:test';
import assert from 'node:assert';
import { createGameState, createColonist } from './js/state.js';
import { recruitTick, resourceTick } from './js/systems.js';

function colony(n) {
    const s = createGameState();
    for (let i = 0; i < n; i++) s.colonists.push(createColonist('C' + i, 5, 5));
    s.resources.food = 100;
    return s;
}

test('no bed, no recruit; a shelter opens four beds', () => {
    const s = colony(8);
    s.currentTick = 240;
    assert.equal(recruitTick(s), null);
    s.buildings.push({ id: 'b', type: 'shelter', col: 1, row: 1, isActive: true });
    assert.ok(recruitTick(s));
    assert.equal(s.colonists.length, 9);
    assert.equal(s.resources.food, 90);
});

test('no food, no recruit', () => {
    const s = colony(2);
    s.currentTick = 240;
    s.resources.food = 5;
    assert.equal(recruitTick(s), null);
});

test('gathering earns XP', () => {
    const s = colony(1);
    s.colonists[0].job = 'gather';
    s.resourceNodes = [{ id: 'r', type: 'materials', col: 5, row: 5, remaining: 50, maxAmount: 50, respawnTicks: 60, ticksSinceDepleted: 0 }];
    for (let t = 4; t <= 2000; t += 20) { s.currentTick = t; resourceTick(s); }
    assert.ok(s.colonists[0].level > 0 || s.colonists[0].xp > 0);
});
