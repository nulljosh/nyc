import Foundation

struct SaveSlot: Codable, Sendable {
    var slot: Int
    var saveName: String
    var timestamp: Date
    var dayCount: Int
    var colonistCount: Int
}

struct SaveData: Codable, Sendable {
    var colonists: [ColonistModel]
    var buildings: [BuildingModel]
    var resourceNodes: [ResourceModel]
    var resources: [ResourceType: Int]
    var currentTick: Int
    var flatGrid: [Int]
    var gridSize: Int
    var slot: SaveSlot
}

@MainActor
final class SaveManager {
    static let shared = SaveManager()

    private let saveDir: URL = {
        let dir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Documents/NYCSurvive")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    private func fileURL(for slot: Int) -> URL {
        saveDir.appendingPathComponent("save\(slot).json")
    }

    func save(slot: Int, gameState: GameState, grid: [[TileType]]) throws {
        let flatGrid = grid.flatMap { $0.map(\.rawValue) }
        let gridSize = grid.count

        let slotInfo = SaveSlot(
            slot: slot,
            saveName: "Slot \(slot)",
            timestamp: Date(),
            dayCount: gameState.currentTick / 24,
            colonistCount: gameState.colonists.filter { !$0.isDead }.count
        )

        let data = SaveData(
            colonists: gameState.colonists,
            buildings: gameState.buildings,
            resourceNodes: gameState.resourceNodes,
            resources: gameState.resources,
            currentTick: gameState.currentTick,
            flatGrid: flatGrid,
            gridSize: gridSize,
            slot: slotInfo
        )

        let encoded = try JSONEncoder().encode(data)
        try encoded.write(to: fileURL(for: slot))
    }

    func load(slot: Int) -> SaveData? {
        let url = fileURL(for: slot)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(SaveData.self, from: data)
    }

    func listSlots() -> [SaveSlot?] {
        (1...3).map { slot in
            guard let data = load(slot: slot) else { return nil }
            return data.slot
        }
    }

    func delete(slot: Int) {
        try? FileManager.default.removeItem(at: fileURL(for: slot))
    }

    func rebuildGrid(from saveData: SaveData) -> [[TileType]] {
        var grid: [[TileType]] = []
        let size = saveData.gridSize
        for row in 0..<size {
            var rowData: [TileType] = []
            for col in 0..<size {
                let idx = row * size + col
                let raw = idx < saveData.flatGrid.count ? saveData.flatGrid[idx] : 0
                rowData.append(TileType(rawValue: raw) ?? .empty)
            }
            grid.append(rowData)
        }
        return grid
    }
}
