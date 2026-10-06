import Foundation

@MainActor
final class NeedsSystem {
    private let gracePeriodTicks = 120

    /// Machines run on their own, once per building per tick, whether or not anyone is standing nearby.
    func tickBuildings(gameState: GameState) {
        for building in gameState.buildings where building.isActive {
            switch building.type {
            case .generator: gameState.resources[.power, default: 0] += 1
            case .billboard: gameState.resources[.cash, default: 0] += 1
            default: break
            }
        }
    }

    func tick(gameState: GameState) {
        tickBuildings(gameState: gameState)
        let inGracePeriod = gameState.currentTick < gracePeriodTicks

        for i in gameState.colonists.indices {
            guard !gameState.colonists[i].isDead else { continue }

            if !inGracePeriod {
                let endMult = gameState.colonists[i].hungerDecayMultiplier
                let traitSleepMult: Double = gameState.colonists[i].trait == .insomniac ? 0.7 : 1.0
                let traitO2Mult: Double = gameState.colonists[i].trait == .ironlung ? 0.7 : 1.0
                let traitStressMult: Double = gameState.colonists[i].trait == .anxious ? 2.0 : 1.0

                gameState.colonists[i].hunger = max(0, gameState.colonists[i].hunger - 0.25 * endMult)
                gameState.colonists[i].oxygen = max(0, gameState.colonists[i].oxygen - 0.1 * traitO2Mult)
                gameState.colonists[i].stress = min(100, gameState.colonists[i].stress + 0.15 * traitStressMult)
                gameState.colonists[i].sleep = max(0, gameState.colonists[i].sleep - 0.15 * traitSleepMult)
            }

            let col = gameState.colonists[i].col
            let row = gameState.colonists[i].row

            // CHA-based stress reduction from nearby colonists
            let cha = gameState.colonists[i].stats.cha
            for j in gameState.colonists.indices where j != i && !gameState.colonists[j].isDead {
                let dist = abs(gameState.colonists[j].col - col) + abs(gameState.colonists[j].row - row)
                if dist <= 3 {
                    gameState.colonists[i].stress = max(0, gameState.colonists[i].stress - Double(cha) * 0.02)
                }
            }

            for building in gameState.buildings where building.isActive {
                let dist = abs(building.col - col) + abs(building.row - row)
                guard dist <= 3 else { continue }

                switch building.type {
                case .shelter:
                    gameState.colonists[i].stress = max(0, gameState.colonists[i].stress - 0.5)
                    gameState.colonists[i].sleep = min(100, gameState.colonists[i].sleep + 0.4)
                case .foodStall:
                    if (gameState.resources[.food] ?? 0) > 0 {
                        gameState.colonists[i].hunger = min(100, gameState.colonists[i].hunger + 2.0)
                        gameState.resources[.food, default: 0] -= 1
                    }
                case .filterStation:
                    if (gameState.resources[.power] ?? 0) > 0 {
                        gameState.colonists[i].oxygen = min(100, gameState.colonists[i].oxygen + 1.0)
                    }
                default:
                    break
                }
            }

            gameState.colonists[i].updateState()

            if gameState.colonists[i].isDead {
                AudioManager.shared.colonistDied()
                gameState.log("\(gameState.colonists[i].name) has died")
            }
        }
    }
}
