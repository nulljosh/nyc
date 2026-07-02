// Game systems -- NeedsSystem, TimeSystem, ResourceSystem, BuildSystem, JobSystem, QuestSystem

import { grantXP, takeDamage, updateColonistState, gameLog, createBuilding, createColonist,
    WeaponTypes, BuildingType, QuestBuildings, CategoryInfo, DifficultyXP,
    activeQuests, addQuest, randomColonistName, colonistClass, syncQuestsToLocalStorage,
    currentPhase, GamePhase } from './state.js';
import { spawnDamage, spawnXP, spawnQuestComplete, spawnLevelUp } from './particles.js';
import { TileType, tileAt, setTile, GRID_SIZE } from './world.js';

// TimeSystem -- uses real clock for day/night in wallpaper mode
const TICKS_PER_DAY = 240;
let accumulated = 0;
let TICK_INTERVAL = 0.25;
export function setDifficulty(level) {
    if (level === 'easy')   { TICK_INTERVAL = 0.35; }
    if (level === 'medium') { TICK_INTERVAL = 0.25; }
    if (level === 'hard')   { TICK_INTERVAL = 0.15; }
}

export function timeTick(dt, state) {
    if (state.isPaused) return false;
    accumulated += dt;
    if (accumulated >= TICK_INTERVAL) {
        accumulated -= TICK_INTERVAL;
        state.currentTick++;
        if (state.wallpaperMode) {
            state.currentHour = new Date().getHours();
        } else {
            state.currentHour = Math.floor((state.currentTick % TICKS_PER_DAY) / 10);
        }
        state.isNight = state.currentHour >= 20 || state.currentHour < 6;
        return true;
    }
    return false;
}

// NeedsSystem -- reduced decay in wallpaper mode
const GRACE_PERIOD = 120;

export function needsTick(state) {
    const inGrace = state.currentTick < GRACE_PERIOD;
    const wallpaperMult = state.wallpaperMode ? 0.3 : 1.0; // colonists survive longer in wallpaper

    for (let i = 0; i < state.colonists.length; i++) {
        const c = state.colonists[i];
        if (c.state === 'dead') continue;

        if (!inGrace) {
            const endMult = 1.0 - c.stats.end * 0.05;
            const sleepMult = c.trait === 'insomniac' ? 0.7 : 1.0;
            const o2Mult = c.trait === 'ironlung' ? 0.7 : 1.0;
            const stressMult = c.trait === 'anxious' ? 2.0 : 1.0;

            c.hunger = Math.max(0, c.hunger - 0.0625 * endMult * wallpaperMult);
            c.oxygen = Math.max(0, c.oxygen - 0.025 * o2Mult * wallpaperMult);
            c.stress = Math.min(100, c.stress + 0.0375 * stressMult * wallpaperMult);
            c.sleep = Math.max(0, c.sleep - 0.0375 * sleepMult * wallpaperMult);
        }

        // CHA stress reduction from nearby colonists
        for (let j = 0; j < state.colonists.length; j++) {
            if (j === i || state.colonists[j].state === 'dead') continue;
            const dist = Math.abs(state.colonists[j].col - c.col) + Math.abs(state.colonists[j].row - c.row);
            if (dist <= 3) c.stress = Math.max(0, c.stress - c.stats.cha * 0.02);
        }

        // Building effects
        for (const b of state.buildings) {
            if (!b.isActive) continue;
            const dist = Math.abs(b.col - c.col) + Math.abs(b.row - c.row);
            if (dist > 3) continue;

            switch (b.type) {
                case 'shelter':
                    c.stress = Math.max(0, c.stress - 0.5);
                    c.sleep = Math.min(100, c.sleep + 0.4);
                    break;
                case 'foodStall':
                    if ((state.resources.food || 0) > 0) {
                        c.hunger = Math.min(100, c.hunger + 2.0);
                        state.resources.food--;
                    }
                    break;
                case 'filterStation':
                    if ((state.resources.power || 0) > 0) {
                        c.oxygen = Math.min(100, c.oxygen + 1.0);
                    }
                    break;
                case 'generator':
                    state.resources.power = (state.resources.power || 0) + 1;
                    break;
                case 'billboard':
                    state.resources.cash = (state.resources.cash || 0) + 1;
                    break;
                // Quest buildings restore needs too
                case 'gym':
                    c.stress = Math.max(0, c.stress - 0.3);
                    c.health = Math.min(100, c.health + 0.1);
                    break;
                case 'library':
                    c.stress = Math.max(0, c.stress - 0.4);
                    c.sleep = Math.min(100, c.sleep + 0.2);
                    break;
                case 'workshop':
                    c.stress = Math.max(0, c.stress - 0.2);
                    break;
            }
        }

        updateColonistState(c);
        if (c.state === 'dead') gameLog(state, `${c.name} has died`);
    }
}

// ResourceSystem
export function resourceTick(state) {
    for (const rn of state.resourceNodes) {
        if (rn.remaining <= 0) {
            rn.ticksSinceDepleted++;
            if (rn.ticksSinceDepleted >= rn.respawnTicks) {
                rn.remaining = rn.maxAmount;
                rn.ticksSinceDepleted = 0;
            }
        }
    }

    for (const c of state.colonists) {
        if (c.job !== 'gather' || c.state === 'dead') continue;
        for (const rn of state.resourceNodes) {
            if (rn.remaining <= 0) continue;
            const dist = Math.abs(rn.col - c.col) + Math.abs(rn.row - c.row);
            if (dist <= 1) {
                const taken = Math.min(1, rn.remaining);
                rn.remaining -= taken;
                if (taken > 0) state.resources[rn.type] = (state.resources[rn.type] || 0) + taken;
                break;
            }
        }
    }
}

// BuildSystem
export function canPlace(type, col, row, grid, state) {
    const bt = BuildingType[type];
    const [w, h] = bt.size;
    for (let r = row; r < row + h; r++) {
        for (let c = col; c < col + w; c++) {
            const t = tileAt(grid, c, r);
            if (t === null || !isWalkable(t)) return false;
        }
    }
    for (const [res, amt] of Object.entries(bt.cost)) {
        if ((state.resources[res] || 0) < amt) return false;
    }
    return true;
}

function isWalkable(t) { return t === TileType.road || t === TileType.sidewalk || t === TileType.subway; }

export function placeBuilding(type, col, row, grid, state, pathfinder) {
    if (!canPlace(type, col, row, grid, state)) return null;
    const bt = BuildingType[type];
    for (const [res, amt] of Object.entries(bt.cost)) {
        state.resources[res] -= amt;
    }
    const [w, h] = bt.size;
    for (let r = row; r < row + h; r++) {
        for (let c = col; c < col + w; c++) {
            setTile(grid, c, r, TileType.building);
            pathfinder.removeNode(c, r);
        }
    }
    const model = createBuilding(type, col, row);
    state.buildings.push(model);
    gameLog(state, `Built ${bt.name}`);
    return model;
}

export function demolishBuilding(id, grid, state, pathfinder) {
    const idx = state.buildings.findIndex(b => b.id === id);
    if (idx === -1) return;
    const b = state.buildings[idx];
    const bt = BuildingType[b.type];
    const [w, h] = bt.size;
    for (let r = b.row; r < b.row + h; r++) {
        for (let c = b.col; c < b.col + w; c++) {
            setTile(grid, c, r, TileType.sidewalk);
            pathfinder.addNode(c, r);
        }
    }
    state.buildings.splice(idx, 1);
    gameLog(state, `Demolished ${bt.name}`);
}

// JobSystem
export function jobTick(state, pathfinder) {
    autoAssignIdle(state, pathfinder);

    for (let i = 0; i < state.colonists.length; i++) {
        const c = state.colonists[i];
        if (c.state === 'dead') continue;

        if (c.job === 'attack') {
            tickCombat(i, state, pathfinder);
        }

        if (c.pathIndex >= c.pathCols.length) {
            if (c.job === 'gather') {
                awardXP(c, 10, 2, state);
                assignRandomGatherTarget(i, state);
            } else if (c.job === 'patrol') {
                awardXP(c, 5, 1, state);
                c.job = 'idle';
            }
            continue;
        }

        const speed = Math.max(1, Math.floor(1.0 + c.stats.agi * 0.1));
        for (let s = 0; s < speed; s++) {
            if (c.pathIndex >= c.pathCols.length) break;
            c.col = c.pathCols[c.pathIndex];
            c.row = c.pathRows[c.pathIndex];
            c.pathIndex++;
        }
    }
}

function autoAssignIdle(state, pathfinder) {
    if (state.currentDirective === 'idle') return;

    for (let i = 0; i < state.colonists.length; i++) {
        const c = state.colonists[i];
        if (c.state === 'dead' || c.job !== 'idle' || c.jobOverride) continue;

        switch (state.currentDirective) {
            case 'gather': assignNearestGatherTarget(i, state, pathfinder); break;
            case 'build':  assignNearestBuildTarget(i, state, pathfinder); break;
            case 'patrol': assignRandomPatrolTarget(i, state, pathfinder); break;
        }
    }
}

function assignNearestGatherTarget(i, state, pathfinder) {
    const c = state.colonists[i];
    const available = state.resourceNodes.filter(r => r.remaining > 0);
    if (!available.length) return;
    available.sort((a, b) =>
        (Math.abs(a.col - c.col) + Math.abs(a.row - c.row)) -
        (Math.abs(b.col - c.col) + Math.abs(b.row - c.row))
    );
    const target = available[0];
    const path = pathfinder.findPath(c.col, c.row, target.col, target.row);
    if (!path.length) return;
    c.job = 'gather';
    c.pathCols = path.map(p => p.col);
    c.pathRows = path.map(p => p.row);
    c.pathIndex = 0;
}

function assignNearestBuildTarget(i, state, pathfinder) {
    const c = state.colonists[i];
    const unfinished = state.buildings.filter(b => !b.isActive);
    if (!unfinished.length) { assignRandomPatrolTarget(i, state, pathfinder); return; }
    unfinished.sort((a, b) =>
        (Math.abs(a.col - c.col) + Math.abs(a.row - c.row)) -
        (Math.abs(b.col - c.col) + Math.abs(b.row - c.row))
    );
    const target = unfinished[0];
    const path = pathfinder.findPath(c.col, c.row, target.col, target.row);
    if (!path.length) return;
    c.job = 'build';
    c.pathCols = path.map(p => p.col);
    c.pathRows = path.map(p => p.row);
    c.pathIndex = 0;
}

function assignRandomPatrolTarget(i, state, pathfinder) {
    const c = state.colonists[i];
    const destCol = Math.max(0, Math.min(GRID_SIZE - 1, c.col + Math.floor(Math.random() * 31) - 15));
    const destRow = Math.max(0, Math.min(GRID_SIZE - 1, c.row + Math.floor(Math.random() * 31) - 15));
    const path = pathfinder.findPath(c.col, c.row, destCol, destRow);
    if (path.length) {
        c.job = 'patrol';
        c.pathCols = path.map(p => p.col);
        c.pathRows = path.map(p => p.row);
        c.pathIndex = 0;
    }
}

function assignRandomGatherTarget(i, state) {
    const available = state.resourceNodes.filter(r => r.remaining > 0);
    if (!available.length) return;
    const target = available[Math.floor(Math.random() * available.length)];
    const c = state.colonists[i];
    const dist = Math.abs(target.col - c.col) + Math.abs(target.row - c.row);
    if (dist > 2) {
        c.pathCols = [target.col];
        c.pathRows = [target.row];
        c.pathIndex = 0;
    }
}

// AutoplaySystem -- priority-based AI that builds, recruits, and balances colony
const AUTOPLAY_INTERVAL = 8;

function computeColonyMetrics(state, alive) {
    const res = state.resources;
    const counts = {};
    for (const b of state.buildings) counts[b.type] = (counts[b.type] || 0) + 1;
    return {
        avgHunger: alive.reduce((s, c) => s + c.hunger, 0) / alive.length,
        avgOxygen: alive.reduce((s, c) => s + c.oxygen, 0) / alive.length,
        avgStress: alive.reduce((s, c) => s + c.stress, 0) / alive.length,
        avgSleep: alive.reduce((s, c) => s + c.sleep, 0) / alive.length,
        avgLevel: alive.reduce((s, c) => s + c.level, 0) / alive.length,
        res, counts, phase: currentPhase(state),
    };
}

function tryBuild(type, alive, grid, state, placeBuildingFn) {
    const bt = BuildingType[type];
    if (!bt) return false;
    const [w, h] = bt.size;
    const res = state.resources;
    for (const [r, amt] of Object.entries(bt.cost)) {
        if ((res[r] || 0) < amt) return false;
    }
    const centerCol = Math.round(alive.reduce((s, c) => s + c.col, 0) / alive.length);
    const centerRow = Math.round(alive.reduce((s, c) => s + c.row, 0) / alive.length);
    for (let radius = 2; radius < 15; radius++) {
        for (let dc = -radius; dc <= radius; dc++) {
            for (let dr = -radius; dr <= radius; dr++) {
                const col = centerCol + dc;
                const row = centerRow + dr;
                if (col < 0 || row < 0 || col + w >= GRID_SIZE || row + h >= GRID_SIZE) continue;
                if (canPlace(type, col, row, grid, state)) {
                    placeBuildingFn(type, col, row);
                    return true;
                }
            }
        }
    }
    return false;
}

function survivalActions(state, grid, alive, m, placeBuildingFn) {
    // Food critical
    if (m.avgHunger < 50) {
        state.currentDirective = 'gather';
        if (!m.counts.foodStall || m.counts.foodStall < Math.ceil(alive.length / 3)) {
            tryBuild('foodStall', alive, grid, state, placeBuildingFn);
        }
    }
    // Oxygen / power critical
    if (m.avgOxygen < 60 || (m.res.power || 0) < 3) {
        if (!m.counts.generator || m.counts.generator < 2) {
            tryBuild('generator', alive, grid, state, placeBuildingFn);
        }
        if (!m.counts.filterStation) {
            tryBuild('filterStation', alive, grid, state, placeBuildingFn);
        }
    }
    // Stress / sleep critical
    if (m.avgStress > 50 || m.avgSleep < 40) {
        if (!m.counts.shelter || m.counts.shelter < Math.ceil(alive.length / 3)) {
            tryBuild('shelter', alive, grid, state, placeBuildingFn);
        }
    }
}

function infrastructureActions(state, grid, alive, m, placeBuildingFn) {
    // Quest buildings for active quests
    const quests = activeQuests(state);
    if (quests.length) {
        const needed = new Set(quests.map(q => QuestBuildings[q.category] || 'questBoard'));
        for (const type of needed) {
            if (!m.counts[type]) tryBuild(type, alive, grid, state, placeBuildingFn);
        }
    }
    // Cash generation
    if ((m.res.cash || 0) < 15 && (!m.counts.billboard || m.counts.billboard < 2)) {
        tryBuild('billboard', alive, grid, state, placeBuildingFn);
    }
}

function growthActions(state, alive, m, pathfinder) {
    // Recruit when stable
    if (alive.length < 20 && m.avgHunger > 40 && m.avgOxygen > 40 && (m.res.food || 0) > 5) {
        if (state.currentTick % (AUTOPLAY_INTERVAL * 2) === 0) {
            const name = randomColonistName(state.colonists);
            const spawnC = alive[Math.floor(Math.random() * alive.length)];
            if (spawnC) {
                state.colonists.push(createColonist(name, spawnC.col + 1, spawnC.row));
                gameLog(state, `${name} joined the colony`);
            }
        }
    }

    // Streak bonuses
    if (state.playerStreak >= 7 && state.currentTick % (AUTOPLAY_INTERVAL * 5) === 0) {
        if (alive.length < 25) {
            const name = randomColonistName(state.colonists);
            const spawnC = alive[Math.floor(Math.random() * alive.length)];
            if (spawnC) {
                const recruit = createColonist(name, spawnC.col + 1, spawnC.row);
                const stats = ['str','int','agi','end','cha'];
                for (const s of stats) recruit.stats[s] = Math.min(10, recruit.stats[s] + 2);
                state.colonists.push(recruit);
                gameLog(state, `${name} joined (${state.playerStreak}-day streak bonus)`);
            }
        }
    }
    if (state.playerStreak >= 30 && state.currentTick % (AUTOPLAY_INTERVAL * 10) === 0) {
        for (const c of alive) {
            c.stress = Math.max(0, c.stress - 15);
            c.sleep = Math.min(100, c.sleep + 10);
        }
        gameLog(state, `30-day streak: colony morale surge`);
    }
}

function assignIdleColonists(state, pathfinder, alive, m) {
    const hasQuests = activeQuests(state).length > 0;
    const hasQuestBuildings = state.buildings.some(b =>
        ['questBoard', 'gym', 'library', 'workshop'].includes(b.type) && b.isActive
    );

    let questAssigned = 0;
    for (let i = 0; i < alive.length; i++) {
        const c = alive[i];
        if (c.job !== 'idle' || c.jobOverride || c._questPending) continue;

        const idx = state.colonists.indexOf(c);
        if (idx < 0) continue;

        // Priority: quests first (leave idle so questTick picks them up)
        if (hasQuests && hasQuestBuildings && questAssigned < Math.ceil(alive.length * 0.6)) {
            // Leave idle -- questTick will assign them to quest buildings
            questAssigned++;
            continue;
        }

        // Resources low -> gather
        if (m.avgHunger < 50 || (m.res.food || 0) < 10 || (m.res.materials || 0) < 15) {
            assignNearestGatherTarget(idx, state, pathfinder);
            continue;
        }

        // Otherwise split between gather and patrol
        if (Math.random() < 0.5) {
            assignNearestGatherTarget(idx, state, pathfinder);
        } else {
            assignRandomPatrolTarget(idx, state, pathfinder);
        }
    }
}

const AUTO_QUEST_TEMPLATES = [
    { cond: (m) => m.avgHunger < 40, title: 'Scavenge food supplies', category: 'errand', difficulty: 'D' },
    { cond: (m) => m.avgOxygen < 50, title: 'Repair air filters', category: 'work', difficulty: 'D' },
    { cond: (m) => (m.res.power || 0) < 3, title: 'Restore power grid', category: 'work', difficulty: 'C' },
    { cond: (m) => !m.counts.shelter && m.phase !== GamePhase.SURVIVAL, title: 'Build emergency shelter', category: 'work', difficulty: 'C' },
    { cond: (m) => m.avgHunger > 50 && m.avgOxygen > 50, title: 'Recruit new survivor', category: 'errand', difficulty: 'B' },
    { cond: (m) => m.avgLevel < 3, title: 'Combat training', category: 'fitness', difficulty: 'C' },
    { cond: (m) => m.avgLevel >= 2, title: 'Study survival techniques', category: 'study', difficulty: 'B' },
    { cond: (m) => m.avgLevel >= 4, title: 'Creative problem solving', category: 'creative', difficulty: 'B' },
    { cond: (m) => m.avgLevel >= 5, title: 'Lead exploration party', category: 'personal', difficulty: 'A' },
    { cond: (m, alive) => alive.length >= 12 && m.avgLevel >= 7, title: 'Reclaim Times Square', category: 'work', difficulty: 'S' },
];

function autoGenerateQuests(state, m, alive) {
    if (state.currentTick % (AUTOPLAY_INTERVAL * 4) !== 0) return;

    const active = activeQuests(state);
    const autoActive = active.filter(q => q.autoGenerated);
    if (autoActive.length >= 3) return;

    const activeTitles = new Set(active.map(q => q.title));
    for (const t of AUTO_QUEST_TEMPLATES) {
        if (autoActive.length >= 3) break;
        if (activeTitles.has(t.title)) continue;
        if (t.cond(m, alive)) {
            addQuest(state, { title: t.title, category: t.category, difficulty: t.difficulty, autoGenerated: true });
            autoActive.push({}); // count limiter
        }
    }
}

export function autoplayTick(state, grid, pathfinder, placeBuildingFn) {
    if (!state.autoplay) return;
    if (state.currentTick % AUTOPLAY_INTERVAL !== 0) return;

    const alive = state.colonists.filter(c => c.state !== 'dead');
    if (!alive.length) return;

    const m = computeColonyMetrics(state, alive);

    // Phase transitions -- milestone events
    if (!state._lastPhase) state._lastPhase = GamePhase.SURVIVAL;
    if (m.phase !== state._lastPhase) {
        gameLog(state, `-- PHASE: ${m.phase} --`);
        state.toastMessage = { text: `Phase: ${m.phase}`, ticks: 120 };
        // Bonus XP on phase transition
        for (const c of alive) grantXP(c, 25);
        state._lastPhase = m.phase;
    }

    // Run all priority actions (not mutually exclusive)
    survivalActions(state, grid, alive, m, placeBuildingFn);
    infrastructureActions(state, grid, alive, m, placeBuildingFn);
    growthActions(state, alive, m, pathfinder);
    autoGenerateQuests(state, m, alive);
    assignIdleColonists(state, pathfinder, alive, m);

    // Set directive for non-autoplay colonist assignment
    if (m.avgHunger < 50 || (m.res.food || 0) < 5) {
        state.currentDirective = 'gather';
    } else {
        state.currentDirective = state.currentTick % 60 < 30 ? 'gather' : 'patrol';
    }

    // Boss encounters
    if (state.currentTick % (AUTOPLAY_INTERVAL * 8) === 0) {
        bossCheck(state, alive, pathfinder);
    }
}

function bossCheck(state, alive, pathfinder) {
    if (!state.questList) return;
    const now = Date.now();
    const DAY_MS = 86400000;

    for (const q of state.questList) {
        if (q.completed || !q.dueDate) continue;
        const due = new Date(q.dueDate).getTime();
        const hoursLeft = (due - now) / (1000 * 60 * 60);

        // Spawn boss if deadline within 24 hours and no existing boss for this quest
        if (hoursLeft > 0 && hoursLeft < 24) {
            const bossId = `boss_${q.id}`;
            if (state.colonists.some(c => c.id === bossId)) continue; // already spawned

            const spawnC = alive[Math.floor(Math.random() * alive.length)];
            if (!spawnC) continue;

            const phase = currentPhase(state);
            const bossHP = phase === GamePhase.VICTORY ? 600 : phase === GamePhase.MASTERY ? 400 : 200;
            const bossLvl = phase === GamePhase.VICTORY ? 10 : phase === GamePhase.MASTERY ? 8 : 5;
            const bossWeapon = phase === GamePhase.VICTORY ? 'rifle' : phase === GamePhase.MASTERY ? 'shotgun' : 'rifle';

            const boss = createColonist(`BOSS: ${q.title.slice(0, 12)}`, spawnC.col + 5, spawnC.row + 5);
            boss.id = bossId;
            boss.stats = { str: 10, int: 10, agi: 8, end: 10, cha: 1 };
            if (phase === GamePhase.VICTORY) { boss.stats.str = 12; boss.stats.end = 12; }
            boss.health = bossHP;
            boss.weapon = bossWeapon;
            boss.level = bossLvl;
            boss.trait = 'hustler';
            boss.questBubble = { text: `Deadline: ${q.title}`, ticks: 60 };
            state.colonists.push(boss);
            gameLog(state, `BOSS spawned: ${q.title} deadline approaching`);

            // Auto-assign nearest colonist to attack
            let nearest = null;
            let nearDist = Infinity;
            for (const c of alive) {
                const d = Math.abs(c.col - boss.col) + Math.abs(c.row - boss.row);
                if (d < nearDist) { nearest = c; nearDist = d; }
            }
            if (nearest) {
                nearest.job = 'attack';
                nearest.attackTargetId = boss.id;
                nearest.jobOverride = true;
                const path = pathfinder.findPath(nearest.col, nearest.row, boss.col, boss.row);
                if (path.length) {
                    nearest.pathCols = path.map(p => p.col);
                    nearest.pathRows = path.map(p => p.row);
                    nearest.pathIndex = 0;
                }
                gameLog(state, `${nearest.name} moves to fight the boss`);
            }
        }
    }
}

// QuestSystem -- colonists perform real-life quests
export const QUEST_WORK_TICKS = 30;

function awardXP(c, xpAmount, playerXPAmount, state) {
    const leveled = grantXP(c, xpAmount);
    state.playerXP += playerXPAmount;
    if (leveled) {
        spawnLevelUp(c.col, c.row, c.level);
        gameLog(state, `${c.name} reached level ${c.level}`);
    }
}

const questBubbles = {
    fitness: ['Hitting the gym', 'Lifting weights', 'Running laps', 'Working out', 'Getting strong'],
    study: ['Reading books', 'Taking notes', 'Studying hard', 'At the library', 'Deep focus'],
    work: ['Coding away', 'In the zone', 'Building apps', 'Shipping code', 'Deploying'],
    personal: ['Self-care time', 'Getting organized', 'Journaling', 'Meditating', 'Reflecting'],
    creative: ['Making art', 'Writing music', 'Designing', 'Creating', 'Brainstorming'],
    errand: ['Running errands', 'Getting supplies', 'Out and about', 'On a mission', 'Shopping'],
};

export function questTick(state, grid, pathfinder) {
    const quests = activeQuests(state);

    const questBuildings = state.buildings.filter(b =>
        ['questBoard', 'gym', 'library', 'workshop'].includes(b.type) && b.isActive
    );

    for (const c of state.colonists) {
        if (c.state === 'dead') continue;

        // Convert pending quest to active when colonist arrives at building
        if (c._questPending && c.pathIndex >= c.pathCols.length) {
            const nearBuilding = questBuildings.some(b =>
                Math.abs(c.col - b.col) + Math.abs(c.row - b.row) <= 3
            );
            if (nearBuilding) {
                c.activeQuest = { ...c._questPending, ticksRemaining: QUEST_WORK_TICKS };
                c._questPending = null;
                const bubbles = questBubbles[c.activeQuest.category] || questBubbles.personal;
                c.questBubble = { text: bubbles[Math.floor(Math.random() * bubbles.length)], ticks: 40 };
            } else {
                // Path ended but not near building -- reset
                c._questPending = null;
                c.job = 'idle';
            }
        }

        // Already on a quest -- tick it down (only when actually working at building)
        if (c.activeQuest) {
            c.activeQuest.ticksRemaining--;
            if (c.activeQuest.ticksRemaining <= 0) {
                const xp = DifficultyXP[c.activeQuest.difficulty] || 50;
                const prevLevel = c.level;
                grantXP(c, xp);
                spawnXP(c.col, c.row, xp);
                if (c.level > prevLevel) spawnLevelUp(c.col, c.row, c.level);
                spawnQuestComplete(c.col, c.row);
                c.questsCompleted = (c.questsCompleted || 0) + 1;
                if (!c._catCounts) c._catCounts = {};
                const cat = c.activeQuest.category;
                c._catCounts[cat] = (c._catCounts[cat] || 0) + 1;
                const topCat = Object.entries(c._catCounts).sort((a,b) => b[1]-a[1])[0];
                if (topCat) c.dominantCategory = topCat[0];
                const info = CategoryInfo[cat];
                if (info && c.questsCompleted % 5 === 0) {
                    for (const stat of info.statBoost) {
                        c.stats[stat] = Math.min(10, c.stats[stat] + 1);
                    }
                    gameLog(state, `${c.name} grew stronger from ${info.label} training`);
                }
                c.questBubble = { text: `Done: ${c.activeQuest.title}`, ticks: 40 };
                gameLog(state, `${c.name} completed: ${c.activeQuest.title}`);
                state.questLog.push({ colonist: c.name, quest: c.activeQuest.title, tick: state.currentTick });
                state.playerXP += xp;
                c.activeQuest = null;
                c.job = 'idle';
            }
            continue;
        }

        // Skip if already traveling to quest or busy
        if (c._questPending) continue;
        if (c.job !== 'idle' || c.jobOverride) continue;
        if (!quests.length || !questBuildings.length) continue;

        // Pick a quest
        const quest = quests[Math.floor(Math.random() * quests.length)];
        const targetType = QuestBuildings[quest.category] || 'questBoard';
        const target = questBuildings.find(b => b.type === targetType) || questBuildings[0];

        const dist = Math.abs(c.col - target.col) + Math.abs(c.row - target.row);
        if (dist <= 3) {
            // Already at building -- start immediately
            c.job = 'quest';
            c.activeQuest = { ...quest, ticksRemaining: QUEST_WORK_TICKS };
            const bubbles = questBubbles[quest.category] || questBubbles.personal;
            c.questBubble = { text: bubbles[Math.floor(Math.random() * bubbles.length)], ticks: 40 };
        } else {
            // Find walkable tile adjacent to building (building tiles are removed from pathfinder)
            const bt = BuildingType[target.type];
            const [bw, bh] = bt ? bt.size : [2, 2];
            let destCol = -1, destRow = -1, bestDist = Infinity;
            for (let dr = -1; dr <= bh; dr++) {
                for (let dc = -1; dc <= bw; dc++) {
                    if (dr >= 0 && dr < bh && dc >= 0 && dc < bw) continue; // skip building tiles
                    const tc = target.col + dc;
                    const tr = target.row + dr;
                    if (tc < 0 || tr < 0 || tc >= GRID_SIZE || tr >= GRID_SIZE) continue;
                    const t = tileAt(grid, tc, tr);
                    if (t === null || t === TileType.building) continue;
                    const d = Math.abs(c.col - tc) + Math.abs(c.row - tr);
                    if (d < bestDist) { destCol = tc; destRow = tr; bestDist = d; }
                }
            }
            if (destCol < 0) continue; // no walkable neighbor

            const path = pathfinder.findPath(c.col, c.row, destCol, destRow);
            if (path.length) {
                c.job = 'quest';
                c.pathCols = path.map(p => p.col);
                c.pathRows = path.map(p => p.row);
                c.pathIndex = 0;
                c._questPending = { ...quest };
                c.questBubble = { text: quest.title, ticks: 30 };
            }
        }
    }

    // Tick down speech bubbles and toast
    for (const c of state.colonists) {
        if (c.questBubble) {
            c.questBubble.ticks--;
            if (c.questBubble.ticks <= 0) c.questBubble = null;
        }
    }
    if (state.toastMessage) {
        state.toastMessage.ticks--;
        if (state.toastMessage.ticks <= 0) state.toastMessage = null;
    }
}

// Wallpaper auto-camera -- slow drift
let cameraDriftAngle = 0;
export function wallpaperCameraTick(camera, state) {
    if (!state.wallpaperMode) return;
    cameraDriftAngle += 0.002;
    const alive = state.colonists.filter(c => c.state !== 'dead');
    if (!alive.length) return;
    // Follow a random alive colonist, slowly
    const target = alive[Math.floor(state.currentTick / 120) % alive.length];
    const targetX = target.col * 32 + 16;
    const targetY = target.row * 32 + 16;
    camera.x += (targetX - camera.x) * 0.02;
    camera.y += (targetY - camera.y) * 0.02;
}

function tickCombat(i, state, pathfinder) {
    const attacker = state.colonists[i];
    if (!attacker.attackTargetId) { attacker.job = 'idle'; return; }
    const targetIdx = state.colonists.findIndex(c => c.id === attacker.attackTargetId);
    if (targetIdx === -1) { attacker.job = 'idle'; attacker.attackTargetId = null; return; }

    const target = state.colonists[targetIdx];
    if (target.state === 'dead') {
        attacker.job = 'idle';
        attacker.attackTargetId = null;
        awardXP(attacker, 30, 10, state);
        gameLog(state, `${attacker.name} killed ${target.name}`);
        return;
    }

    const dist = Math.abs(attacker.col - target.col) + Math.abs(attacker.row - target.row);
    const weapon = WeaponTypes[attacker.weapon];

    if (dist <= weapon.range) {
        const dmg = weapon.damage * (1.0 + attacker.stats.str * 0.1);
        takeDamage(target, dmg);
        spawnDamage(target.col, target.row, dmg);
        awardXP(attacker, 5, 1, state);
    } else if (attacker.pathIndex >= attacker.pathCols.length) {
        const path = pathfinder.findPath(attacker.col, attacker.row, target.col, target.row);
        if (path.length) {
            attacker.pathCols = path.map(p => p.col);
            attacker.pathRows = path.map(p => p.row);
            attacker.pathIndex = 0;
        }
    }
}
