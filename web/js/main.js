// Main entry -- game loop, init, auto-start

import { createGameState, createColonist, gameLog, grantXP, BuildingType, migrateQuestData,
    randomColonistName, activeQuests, addQuest, completeQuestInList, syncQuestsToLocalStorage,
    checkVictory, currentPhase } from './state.js';
import { initClaudeBridge } from './claude.js';
import { generateWorld, GRID_SIZE, TILE_SIZE, tileAt, worldToTile } from './world.js';
import { Pathfinder } from './pathfinder.js';
import { timeTick, needsTick, resourceTick, jobTick, placeBuilding, demolishBuilding,
    questTick, wallpaperCameraTick, setDifficulty } from './systems.js';
import { Camera } from './camera.js';
import { renderWorld, renderMinimap } from './renderer.js';
import { setupInput } from './input.js';
import { updateHUD, checkTutorialAdvance } from './hud.js';
import { saveGame, loadGame, listSlots, rebuildGrid } from './save.js';
import { tickParticles, spawnBuildDust } from './particles.js';

let selectedDifficulty = 'medium';
let state = null;
let grid = null;
let pathfinder = null;
let camera = null;
let canvas = null;
let ctx = null;
let minimapCanvas = null;
let minimapCtx = null;
let lastTime = 0;
let running = false;

function init() {
    canvas = document.getElementById('game');
    ctx = canvas.getContext('2d');
    minimapCanvas = document.getElementById('minimap');
    minimapCtx = minimapCanvas.getContext('2d');
    if (!ctx || !minimapCtx) return;

    resizeCanvas();
    window.addEventListener('resize', resizeCanvas);

    showMenu();
}

function resizeCanvas() {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
}

function showMenu() {
    running = false;
    const menu = document.getElementById('menu');
    const hud = document.getElementById('hud');
    menu.style.display = 'flex';
    hud.style.display = 'none';
    canvas.style.cursor = 'default';

    const slots = listSlots();
    const slotsContainer = document.getElementById('menu-slots');
    slotsContainer.textContent = '';

    for (let i = 0; i < 3; i++) {
        const s = slots[i];
        const btn = document.createElement('button');
        btn.className = 'menu-slot-btn' + (s ? '' : ' empty');
        if (s) {
            btn.textContent = `SLOT ${i + 1} -- Day ${s.dayCount} | ${s.colonistCount} alive`;
            const slot = i + 1;
            btn.onclick = () => startGame(slot);
        } else {
            btn.textContent = `SLOT ${i + 1} -- EMPTY --`;
            btn.disabled = true;
        }
        slotsContainer.appendChild(btn);
    }

    document.getElementById('menu-new').onclick = () => {
        setDifficulty(selectedDifficulty);
        startGame(null);
    };
}

function startGame(loadSlot) {
    document.getElementById('menu').style.display = 'none';
    document.getElementById('hud').style.display = 'block';

    state = createGameState();
    pathfinder = new Pathfinder();
    camera = new Camera();

    if (loadSlot) {
        const save = loadGame(loadSlot);
        if (save) {
            grid = rebuildGrid(save);
            state.colonists = save.colonists;
            state.selectedColonistIds = new Set();
            state.buildings = save.buildings;
            state.resourceNodes = save.resourceNodes;
            state.resources = save.resources;
            state.currentTick = save.currentTick;
            state.currentHour = Math.floor((save.currentTick % 240) / 10);
            state.lastSaveSlot = loadSlot;
            state.tutorialStep = null;
            // Restore quest data from save
            if (save.questList) state.questList = save.questList;
            if (save.rewardList) state.rewardList = save.rewardList;
            if (save.playerXP) state.playerXP = save.playerXP;
            if (save.playerStreak) state.playerStreak = save.playerStreak;
            if (save.playerLastActive) state.playerLastActive = save.playerLastActive;
            gameLog(state, 'Game loaded');
        } else {
            freshWorld();
        }
    } else {
        freshWorld();
        const mult = selectedDifficulty === 'easy' ? 1.5 : selectedDifficulty === 'hard' ? 0.6 : 1;
        Object.keys(state.resources).forEach(k => { state.resources[k] = Math.round((state.resources[k] || 0) * mult); });
    }

    // Migrate quest data from standalone Quest app
    migrateQuestData(state);

    pathfinder.buildGraph(grid);

    const center = GRID_SIZE / 2;
    camera.x = center * TILE_SIZE;
    camera.y = center * TILE_SIZE;

    // Expose state for quest board HUD
    window._gameState = state;
    window._gameCallbacks = {
        addQuest: (data) => { addQuest(state, data); updateHUD(state, hudCallbacks); },
        completeQuest: (id) => { completeQuestInList(state, id); updateHUD(state, hudCallbacks); },
        toggleWallpaper: () => {
            state.wallpaperMode = !state.wallpaperMode;
            updateHUD(state, hudCallbacks);
        },
    };

    initClaudeBridge(state);

    setupInput(canvas, camera, state, {
        onSelectEntity: (wx, wy) => selectEntity(wx, wy),
        onPlaceBuilding: (col, row) => handlePlace(col, row),
        onDemolish: (wx, wy) => handleDemolish(wx, wy),
        onBoxSelect: (start, end) => boxSelect(start, end),
        onSave: () => performSave(),
        onHudUpdate: () => updateHUD(state, hudCallbacks),
        onTutorial: (event) => { checkTutorialAdvance(state, event); updateHUD(state, hudCallbacks); },
    });

    updateHUD(state, hudCallbacks);

    running = true;
    lastTime = 0;
    requestAnimationFrame(gameLoop);
}

function freshWorld() {
    const result = generateWorld();
    grid = result.grid;
    state.resourceNodes = result.resources;
    state.tutorialStep = null; // skip tutorial in auto-start

    const center = GRID_SIZE / 2;
    for (let i = 0; i < 8; i++) {
        const name = randomColonistName(state.colonists);
        let col = center, row = center;
        for (let dc = 0; dc < 10; dc++) {
            for (let dr = 0; dr < 10; dr++) {
                const c = center + dc + i;
                const r = center + dr;
                const t = tileAt(grid, c, r);
                if (t !== null && (t === 0 || t === 1 || t === 4)) { col = c; row = r; dc = 99; break; }
            }
        }
        state.colonists.push(createColonist(name, col, row));
    }

    state.colonists[0].job = 'gather';
    state.colonists[1].job = 'gather';
    state.lastSaveSlot = 1;

    gameLog(state, 'Welcome to Times Square');
}

const hudCallbacks = {
    onHudUpdate: () => updateHUD(state, hudCallbacks),
    onSaveSlot: (slot) => performSave(slot),
};

function gameLoop(timestamp) {
    if (!running) return;

    try {
        const dt = lastTime === 0 ? 0 : (timestamp - lastTime) / 1000;
        lastTime = timestamp;

        camera.update(dt);
        wallpaperCameraTick(camera, state);

        if (timeTick(dt, state)) {
            needsTick(state);
            jobTick(state, pathfinder);
            resourceTick(state);
            questTick(state, grid, pathfinder);
            tickParticles();

            // Victory check
            if (checkVictory(state) && !state.victoryShown) {
                state.victoryShown = true;
                state.isPaused = true;
                gameLog(state, 'TIMES SQUARE RECLAIMED');
                const elapsed = Math.floor(state.currentTick / 60);
                state.toastMessage = { text: `Victory in ${elapsed} minutes`, ticks: 300 };
            }

            if (state.autoSaveEnabled && state.currentTick > 0 && state.currentTick % 60 === 0 && state.lastSaveSlot) {
                performSave(state.lastSaveSlot);
            }

            // Sync quests to localStorage periodically
            if (state.currentTick % 120 === 0) syncQuestsToLocalStorage(state);

            updateHUD(state, hudCallbacks);
        }

        ctx.clearRect(0, 0, canvas.width, canvas.height);
        ctx.fillStyle = '#0a0a0c';
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        renderWorld(ctx, canvas, camera, grid, state);

        if (Math.floor(timestamp / 16) % 10 === 0) {
            renderMinimap(minimapCtx, minimapCanvas, grid, state, camera);
        }
    } catch (e) {
        console.error('Game loop error:', e);
    }

    requestAnimationFrame(gameLoop);
}

function selectEntity(wx, wy) {
    state.selectedColonistId = null;
    state.selectedColonistIds = new Set();
    for (const c of state.colonists) {
        const cx = c.col * TILE_SIZE + TILE_SIZE / 2;
        const cy = c.row * TILE_SIZE + TILE_SIZE / 2;
        if (Math.abs(wx - cx) < 20 && Math.abs(wy - cy) < 20) {
            state.selectedColonistId = c.id;
            gameLog(state, `Selected ${c.name}`);
            updateHUD(state, hudCallbacks);
            return;
        }
    }
    updateHUD(state, hudCallbacks);
}

function boxSelect(start, end) {
    const minX = Math.min(start.x, end.x);
    const maxX = Math.max(start.x, end.x);
    const minY = Math.min(start.y, end.y);
    const maxY = Math.max(start.y, end.y);

    state.selectedColonistIds = new Set();
    state.selectedColonistId = null;

    for (const c of state.colonists) {
        const cx = c.col * TILE_SIZE + TILE_SIZE / 2;
        const cy = c.row * TILE_SIZE + TILE_SIZE / 2;
        if (cx >= minX && cx <= maxX && cy >= minY && cy <= maxY) {
            state.selectedColonistIds.add(c.id);
        }
    }

    if (state.selectedColonistIds.size === 1) {
        state.selectedColonistId = state.selectedColonistIds.values().next().value;
    }
    if (state.selectedColonistIds.size > 0) {
        gameLog(state, `Selected ${state.selectedColonistIds.size} colonists`);
    }
    updateHUD(state, hudCallbacks);
}

function handlePlace(col, row) {
    if (!state.selectedBuildingType) return;
    const model = placeBuilding(state.selectedBuildingType, col, row, grid, state, pathfinder);
    if (model) {
        const bt = BuildingType[state.selectedBuildingType];
        spawnBuildDust(col, row, bt.size[0], bt.size[1]);
        for (const c of state.colonists) {
            if (c.job === 'build' && c.state !== 'dead') {
                const dist = Math.abs(c.col - col) + Math.abs(c.row - row);
                if (dist <= 5) grantXP(c, 10);
            }
        }
        updateHUD(state, hudCallbacks);
    }
}

function handleDemolish(wx, wy) {
    const tile = worldToTile(wx, wy);
    for (const b of state.buildings) {
        const bt = BuildingType[b.type];
        const [w, h] = bt.size;
        if (tile.col >= b.col && tile.col < b.col + w && tile.row >= b.row && tile.row < b.row + h) {
            demolishBuilding(b.id, grid, state, pathfinder);
            updateHUD(state, hudCallbacks);
            return;
        }
    }
}

function performSave(slot) {
    const targetSlot = slot || state.lastSaveSlot || 1;
    saveGame(targetSlot, state, grid);
    state.lastSaveSlot = targetSlot;
    state.showSaveIndicator = true;
    gameLog(state, `Saved to slot ${targetSlot}`);
    updateHUD(state, hudCallbacks);
    setTimeout(() => { state.showSaveIndicator = false; updateHUD(state, hudCallbacks); }, 2000);
}

document.addEventListener('DOMContentLoaded', () => {
    document.querySelectorAll('.diff-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            document.querySelectorAll('.diff-btn').forEach(b => b.classList.remove('selected'));
            btn.classList.add('selected');
            selectedDifficulty = btn.dataset.diff;
        });
    });
    document.querySelector('.diff-btn[data-diff="medium"]').classList.add('selected');

    init();

    const mm = document.getElementById('minimap');
    mm.addEventListener('click', e => {
        if (!camera || !grid) return;
        const rect = mm.getBoundingClientRect();
        const px = (e.clientX - rect.left) / rect.width;
        const py = (e.clientY - rect.top) / rect.height;
        camera.x = px * GRID_SIZE * TILE_SIZE;
        camera.y = py * GRID_SIZE * TILE_SIZE;
    });
});
