import Foundation

@MainActor
final class JobSystem {
    weak var pathfinder: Pathfinder?

    func assignJob(colonistIndex: Int, job: ColonistJob, destCol: Int, destRow: Int, gameState: GameState, pathfinder: Pathfinder) {
        guard colonistIndex < gameState.colonists.count else { return }
        gameState.colonists[colonistIndex].job = job
        let path = pathfinder.findPath(
            fromCol: gameState.colonists[colonistIndex].col,
            fromRow: gameState.colonists[colonistIndex].row,
            toCol: destCol,
            toRow: destRow
        )
        gameState.colonists[colonistIndex].pathCols = path.map(\.col)
        gameState.colonists[colonistIndex].pathRows = path.map(\.row)
        gameState.colonists[colonistIndex].pathIndex = 0
    }

    /// Player-issued move order.
    func commandMove(colonistId: UUID, destCol: Int, destRow: Int, gameState: GameState, pathfinder: Pathfinder) {
        guard let i = gameState.colonists.firstIndex(where: { $0.id == colonistId }),
              !gameState.colonists[i].isDead else { return }
        let path = pathfinder.findPath(
            fromCol: gameState.colonists[i].col,
            fromRow: gameState.colonists[i].row,
            toCol: destCol,
            toRow: destRow
        )
        guard !path.isEmpty else { return }
        gameState.colonists[i].job = .idle
        gameState.colonists[i].pathCols = path.map(\.col)
        gameState.colonists[i].pathRows = path.map(\.row)
        gameState.colonists[i].pathIndex = 0
        gameState.log("\(gameState.colonists[i].name) moving to (\(destCol), \(destRow))")
    }

    func clearJob(colonistIndex: Int, gameState: GameState) {
        guard colonistIndex < gameState.colonists.count else { return }
        gameState.colonists[colonistIndex].job = .idle
        gameState.colonists[colonistIndex].pathCols = []
        gameState.colonists[colonistIndex].pathRows = []
        gameState.colonists[colonistIndex].pathIndex = 0
    }

    func tick(gameState: GameState) {
        for i in gameState.colonists.indices {
            guard !gameState.colonists[i].isDead else { continue }

            // Combat tick
            if gameState.colonists[i].job == .attack {
                tickCombat(colonistIndex: i, gameState: gameState)
            }

            guard gameState.colonists[i].hasPath else {
                if gameState.colonists[i].job == .gather {
                    gameState.colonists[i].grantXP(5)
                    gameState.colonists[i].job = .idle
                } else if gameState.colonists[i].job == .patrol {
                    gameState.colonists[i].job = .idle
                }
                continue
            }

            let speed = gameState.colonists[i].movementSpeed
            let steps = max(1, Int(speed))
            for _ in 0..<steps {
                guard gameState.colonists[i].hasPath else { break }
                gameState.colonists[i].advancePath()
                if let pos = gameState.colonists[i].currentPathPosition {
                    gameState.colonists[i].col = pos.col
                    gameState.colonists[i].row = pos.row
                }
            }
        }
    }

    func grantJobXP(colonistIndex: Int, job: ColonistJob, gameState: GameState) {
        guard colonistIndex < gameState.colonists.count else { return }
        let xp: Int
        switch job {
        case .gather: xp = 5
        case .build: xp = 10
        case .patrol: xp = 3
        case .attack: xp = 8
        case .idle: xp = 0
        }
        if xp > 0 {
            gameState.colonists[colonistIndex].grantXP(xp)
        }
    }

    // MARK: - Combat

    private func tickCombat(colonistIndex: Int, gameState: GameState) {
        let attacker = gameState.colonists[colonistIndex]
        guard let targetId = attacker.attackTargetId,
              let targetIdx = gameState.colonists.firstIndex(where: { $0.id == targetId }) else {
            // No valid target, go idle
            gameState.colonists[colonistIndex].job = .idle
            gameState.colonists[colonistIndex].attackTargetId = nil
            return
        }

        let target = gameState.colonists[targetIdx]
        guard !target.isDead else {
            gameState.colonists[colonistIndex].job = .idle
            gameState.colonists[colonistIndex].attackTargetId = nil
            gameState.colonists[colonistIndex].grantXP(15)
            AudioManager.shared.colonistDied()
            gameState.log("\(attacker.name) killed \(target.name)")
            return
        }

        let dist = abs(attacker.col - target.col) + abs(attacker.row - target.row)
        if dist <= attacker.weapon.range {
            // In range -- deal damage
            let dmg = attacker.weapon.damage * (1.0 + Double(attacker.stats.str) * 0.1)
            gameState.colonists[targetIdx].takeDamage(dmg)
            AudioManager.shared.combatHit()
            gameState.colonists[colonistIndex].grantXP(2)
        } else if !attacker.hasPath {
            // Move toward target
            if let pathfinder {
                let path = pathfinder.findPath(fromCol: attacker.col, fromRow: attacker.row, toCol: target.col, toRow: target.row)
                if !path.isEmpty {
                    gameState.colonists[colonistIndex].pathCols = path.map(\.col)
                    gameState.colonists[colonistIndex].pathRows = path.map(\.row)
                    gameState.colonists[colonistIndex].pathIndex = 0
                }
            }
        }
    }
}
