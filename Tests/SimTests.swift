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
        let needs = NeedsSystem()
        for _ in 0..<10 {
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
}
