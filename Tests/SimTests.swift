import XCTest
@testable import NYCSurvive

@MainActor
final class SimTests: XCTestCase {

    func testWorldGeneratorProducesValidGrid() {
        let result = WorldGenerator.generate()
        XCTAssertEqual(result.grid.count, 128)
        XCTAssertEqual(result.grid[0].count, 128)

        var hasRoad = false
        var hasBuilding = false
        var hasSidewalk = false
        for row in result.grid {
            for tile in row {
                if tile == .road { hasRoad = true }
                if tile == .building { hasBuilding = true }
                if tile == .sidewalk { hasSidewalk = true }
            }
        }
        XCTAssertTrue(hasRoad)
        XCTAssertTrue(hasBuilding)
        XCTAssertTrue(hasSidewalk)
        XCTAssertFalse(result.resources.isEmpty)
    }

    func testPathfinderFindsPath() {
        let result = WorldGenerator.generate()
        let pf = Pathfinder(columns: 128, rows: 128)
        pf.buildGraph(grid: result.grid)

        var startCol = 0, startRow = 0
        var endCol = 0, endRow = 0
        var foundStart = false, foundEnd = false

        for row in 0..<128 {
            for col in 0..<128 {
                if result.grid[row][col].isWalkable {
                    if !foundStart {
                        startCol = col; startRow = row; foundStart = true
                    } else if abs(col - startCol) + abs(row - startRow) > 10 {
                        endCol = col; endRow = row; foundEnd = true
                        break
                    }
                }
            }
            if foundEnd { break }
        }

        let path = pf.findPath(fromCol: startCol, fromRow: startRow, toCol: endCol, toRow: endRow)
        XCTAssertFalse(path.isEmpty)
    }

    func testNeedsSystemDecay() {
        let gs = GameState()
        gs.colonists = [ColonistModel(id: UUID(), name: "Test", col: 0, row: 0)]
        gs.currentTick = 200  // past the 120-tick grace period
        let needs = NeedsSystem()

        let initialHunger = gs.colonists[0].hunger
        let initialOxygen = gs.colonists[0].oxygen

        for _ in 0..<10 {
            needs.tick(gameState: gs)
        }

        XCTAssertLessThan(gs.colonists[0].hunger, initialHunger)
        XCTAssertLessThan(gs.colonists[0].oxygen, initialOxygen)
        XCTAssertGreaterThan(gs.colonists[0].stress, 0)
    }

    func testNeedsSystemDeath() {
        let gs = GameState()
        gs.colonists = [ColonistModel(id: UUID(), name: "Doomed", col: 0, row: 0)]
        gs.colonists[0].hunger = 1
        gs.currentTick = 200  // past the 120-tick grace period
        let needs = NeedsSystem()
        for _ in 0..<500 where !gs.colonists[0].isDead {
            needs.tick(gameState: gs)
        }
        XCTAssertEqual(gs.colonists[0].state, .dead)
    }

    func testBuildSystemRejectsNonWalkable() {
        let grid = Array(repeating: Array(repeating: TileType.building, count: 10), count: 10)
        let tm = TileMap(grid: grid)
        let gs = GameState()
        gs.resources = [.materials: 100, .cash: 100, .power: 100]
        let bs = BuildSystem()

        XCTAssertFalse(bs.canPlace(type: .shelter, col: 0, row: 0, tileMap: tm, gameState: gs))
    }

    func testBuildSystemAcceptsWalkable() {
        var grid = Array(repeating: Array(repeating: TileType.sidewalk, count: 10), count: 10)
        let tm = TileMap(grid: grid)
        let gs = GameState()
        gs.resources = [.materials: 100, .cash: 100, .power: 100]
        let bs = BuildSystem()

        XCTAssertTrue(bs.canPlace(type: .foodStall, col: 2, row: 2, tileMap: tm, gameState: gs))
    }

    func testResourceSystemConsumeFailsWhenEmpty() {
        let gs = GameState()
        gs.resources = [.food: 0]
        let rs = ResourceSystem()
        XCTAssertFalse(rs.consume(gameState: gs, type: .food, amount: 1))
    }

    func testResourceSystemConsumeSucceeds() {
        let gs = GameState()
        gs.resources = [.food: 10]
        let rs = ResourceSystem()
        XCTAssertTrue(rs.consume(gameState: gs, type: .food, amount: 5))
        XCTAssertEqual(gs.resources[.food], 5)
    }

    func testJobSystemAssignAndClear() {
        let gs = GameState()
        gs.colonists = [ColonistModel(id: UUID(), name: "Worker", col: 0, row: 0)]
        let result = WorldGenerator.generate()
        let pf = Pathfinder(columns: 128, rows: 128)
        pf.buildGraph(grid: result.grid)

        let js = JobSystem()
        js.assignJob(colonistIndex: 0, job: .gather, destCol: 5, destRow: 5, gameState: gs, pathfinder: pf)
        XCTAssertEqual(gs.colonists[0].job, .gather)

        js.clearJob(colonistIndex: 0, gameState: gs)
        XCTAssertEqual(gs.colonists[0].job, .idle)
        XCTAssertTrue(gs.colonists[0].pathCols.isEmpty)
    }

    // MARK: - No autoplay (regression: colonists must never self-assign)

    func testIdleColonistsStayIdle() {
        let gs = GameState()
        gs.colonists = [ColonistModel(id: UUID(), name: "Idler", col: 5, row: 5)]
        gs.resourceNodes = [ResourceModel(id: UUID(), type: .food, col: 6, row: 6, remaining: 100, maxAmount: 100, respawnTicks: 10)]
        let result = WorldGenerator.generate()
        let pf = Pathfinder(columns: 128, rows: 128)
        pf.buildGraph(grid: result.grid)
        let js = JobSystem()
        js.pathfinder = pf

        for _ in 0..<50 {
            js.tick(gameState: gs)
        }
        XCTAssertEqual(gs.colonists[0].job, .idle)
        XCTAssertFalse(gs.colonists[0].hasPath)
        XCTAssertEqual(gs.colonists[0].col, 5)
        XCTAssertEqual(gs.colonists[0].row, 5)
    }

    func testCommandMoveSetsPath() {
        let result = WorldGenerator.generate()
        let pf = Pathfinder(columns: 128, rows: 128)
        pf.buildGraph(grid: result.grid)

        var startCol = 0, startRow = 0, endCol = 0, endRow = 0
        var foundStart = false, foundEnd = false
        for row in 0..<128 {
            for col in 0..<128 where result.grid[row][col].isWalkable {
                if !foundStart {
                    startCol = col; startRow = row; foundStart = true
                } else if abs(col - startCol) + abs(row - startRow) > 5 {
                    endCol = col; endRow = row; foundEnd = true; break
                }
            }
            if foundEnd { break }
        }

        let gs = GameState()
        let id = UUID()
        gs.colonists = [ColonistModel(id: id, name: "Mover", col: startCol, row: startRow)]
        let js = JobSystem()
        js.commandMove(colonistId: id, destCol: endCol, destRow: endRow, gameState: gs, pathfinder: pf)

        XCTAssertTrue(gs.colonists[0].hasPath)
        XCTAssertEqual(gs.colonists[0].job, .idle)

        js.pathfinder = pf
        for _ in 0..<500 where gs.colonists[0].hasPath {
            js.tick(gameState: gs)
        }
        XCTAssertEqual(gs.colonists[0].col, endCol)
        XCTAssertEqual(gs.colonists[0].row, endRow)
    }

    func testCommandMoveIgnoresDeadColonist() {
        let gs = GameState()
        let id = UUID()
        var c = ColonistModel(id: id, name: "Ghost", col: 0, row: 0)
        c.state = .dead
        gs.colonists = [c]
        let pf = Pathfinder(columns: 10, rows: 10)
        pf.buildGraph(grid: Array(repeating: Array(repeating: TileType.sidewalk, count: 10), count: 10))
        let js = JobSystem()
        js.commandMove(colonistId: id, destCol: 5, destRow: 5, gameState: gs, pathfinder: pf)
        XCTAssertFalse(gs.colonists[0].hasPath)
    }

    // MARK: - Save/load

    func testSaveLoadRoundTrip() throws {
        let gs = GameState()
        gs.colonists = [ColonistModel(id: UUID(), name: "Saved", col: 3, row: 4)]
        gs.resources = [.food: 42]
        gs.currentTick = 99
        let grid = Array(repeating: Array(repeating: TileType.sidewalk, count: 8), count: 8)

        try SaveManager.shared.save(slot: 3, gameState: gs, grid: grid)
        defer { SaveManager.shared.delete(slot: 3) }

        let loaded = SaveManager.shared.load(slot: 3)
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.colonists.first?.name, "Saved")
        XCTAssertEqual(loaded?.resources[.food], 42)
        XCTAssertEqual(loaded?.currentTick, 99)
        let rebuilt = SaveManager.shared.rebuildGrid(from: loaded!)
        XCTAssertEqual(rebuilt.count, 8)
        XCTAssertEqual(rebuilt[0][0], .sidewalk)
    }

    func testLoadMissingSlotReturnsNil() {
        SaveManager.shared.delete(slot: 3)
        XCTAssertNil(SaveManager.shared.load(slot: 3))
    }

    func testLegacySaveWithRemovedFieldsDecodes() throws {
        // Saves written before v1.2.0 contain jobOverride/currentDirective keys.
        let json = """
        {"id":"\(UUID().uuidString)","name":"Legacy","col":1,"row":2,"jobOverride":true}
        """
        var dict = try JSONSerialization.jsonObject(with: JSONEncoder().encode(
            ColonistModel(id: UUID(), name: "T", col: 0, row: 0))) as! [String: Any]
        dict["jobOverride"] = true
        let data = try JSONSerialization.data(withJSONObject: dict)
        let decoded = try JSONDecoder().decode(ColonistModel.self, from: data)
        XCTAssertEqual(decoded.name, "T")
        _ = json
    }

    func testRebuildGridHandlesCorruptSize() {
        let sd = SaveData(colonists: [], buildings: [], resourceNodes: [], resources: [:],
                          currentTick: 0, flatGrid: [], gridSize: 0,
                          slot: SaveSlot(slot: 1, saveName: "x", timestamp: Date(), dayCount: 0, colonistCount: 0))
        XCTAssertTrue(SaveManager.shared.rebuildGrid(from: sd).isEmpty)
    }

    // MARK: - Tutorial

    func testTutorialAdvancesOnEvents() {
        let gs = GameState()
        gs.tutorialStep = 2
        TutorialView.checkAdvance(gameState: gs, event: .colonistSelected)
        XCTAssertEqual(gs.tutorialStep, 3)
        TutorialView.checkAdvance(gameState: gs, event: .cameraPanned)
        XCTAssertEqual(gs.tutorialStep, 4)
        TutorialView.checkAdvance(gameState: gs, event: .buildMenuOpened)
        XCTAssertEqual(gs.tutorialStep, 5)
        TutorialView.checkAdvance(gameState: gs, event: .shelterPlaced)
        XCTAssertEqual(gs.tutorialStep, 6)
    }

    func testTutorialIgnoresWrongEvent() {
        let gs = GameState()
        gs.tutorialStep = 2
        TutorialView.checkAdvance(gameState: gs, event: .shelterPlaced)
        XCTAssertEqual(gs.tutorialStep, 2)
    }

    func testTutorialInactiveWhenDismissed() {
        let gs = GameState()
        gs.tutorialStep = nil
        TutorialView.checkAdvance(gameState: gs, event: .colonistSelected)
        XCTAssertNil(gs.tutorialStep)
    }
}
