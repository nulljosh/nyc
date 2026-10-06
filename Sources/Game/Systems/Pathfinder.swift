import Foundation
import GameplayKit

@MainActor
final class Pathfinder {
    private var graph: GKGridGraph<GKGridGraphNode>?
    private let columns: Int
    private let rows: Int

    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
    }

    func buildGraph(grid: [[TileType]]) {
        graph = GKGridGraph(
            fromGridStartingAt: vector_int2(0, 0),
            width: Int32(columns),
            height: Int32(rows),
            diagonalsAllowed: false
        )
        guard let graph else { return }

        var wallNodes: [GKGridGraphNode] = []
        for row in 0..<rows {
            for col in 0..<columns {
                if !grid[row][col].isWalkable {
                    if let node = graph.node(atGridPosition: vector_int2(Int32(col), Int32(row))) {
                        wallNodes.append(node)
                    }
                }
            }
        }
        graph.remove(wallNodes)
    }

    func removeNode(col: Int, row: Int) {
        guard let graph else { return }
        if let node = graph.node(atGridPosition: vector_int2(Int32(col), Int32(row))) {
            graph.remove([node])
        }
    }

    func addNode(col: Int, row: Int) {
        guard let graph else { return }
        let pos = vector_int2(Int32(col), Int32(row))
        if graph.node(atGridPosition: pos) == nil {
            let newNode = GKGridGraphNode(gridPosition: pos)
            graph.add([newNode])
            let neighbors = [
                vector_int2(pos.x - 1, pos.y),
                vector_int2(pos.x + 1, pos.y),
                vector_int2(pos.x, pos.y - 1),
                vector_int2(pos.x, pos.y + 1)
            ]
            for nPos in neighbors {
                if let neighbor = graph.node(atGridPosition: nPos) {
                    newNode.addConnections(to: [neighbor], bidirectional: true)
                }
            }
        }
    }

    func findPath(fromCol: Int, fromRow: Int, toCol: Int, toRow: Int) -> [(col: Int, row: Int)] {
        guard let graph else { return [] }
        guard let startNode = graph.node(atGridPosition: vector_int2(Int32(fromCol), Int32(fromRow))),
              let endNode = graph.node(atGridPosition: vector_int2(Int32(toCol), Int32(toRow))) else {
            return []
        }
        let path = graph.findPath(from: startNode, to: endNode)
        return path.compactMap { node -> (col: Int, row: Int)? in
            guard let gridNode = node as? GKGridGraphNode else { return nil }
            return (Int(gridNode.gridPosition.x), Int(gridNode.gridPosition.y))
        }
    }

    /// Path to the tile, or to a neighbour when the tile itself is blocked (nodes can sit on
    /// building tiles; harvesting works from one tile away).
    func findPathNear(fromCol: Int, fromRow: Int, toCol: Int, toRow: Int) -> [(col: Int, row: Int)] {
        for (dc, dr) in [(0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)] {
            let p = findPath(fromCol: fromCol, fromRow: fromRow, toCol: toCol + dc, toRow: toRow + dr)
            if !p.isEmpty { return p }
        }
        return []
    }
}
