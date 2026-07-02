import Foundation

enum InputMode: String, Sendable {
    case normal, build, demolish
}

@Observable
@MainActor
final class GameState {
    var resources: [ResourceType: Int] = [
        .food: 20,
        .power: 10,
        .materials: 30,
        .oxygen: 50,
        .cash: 25
    ]
    var colonists: [ColonistModel] = []
    var buildings: [BuildingModel] = []
    var resourceNodes: [ResourceModel] = []
    var selectedColonistId: UUID?
    var isPaused: Bool = false
    var currentTick: Int = 0
    var currentHour: Int = 0
    var isNight: Bool = false
    var inputMode: InputMode = .normal
    var selectedBuildingType: BuildingType?
    var gameLog: [String] = []
    var showBuildMenu: Bool = false
    var showSettings: Bool = false

    // Multi-select
    var selectedColonistIds: Set<UUID> = []

    // Tutorial
    var tutorialStep: Int? = nil  // nil = done/skipped, 0-7 = active

    // Save system
    var lastSaveSlot: Int? = nil
    var autoSaveEnabled: Bool = true
    var showSaveIndicator: Bool = false

    // Audio
    var soundEnabled: Bool {
        get { AudioManager.shared.soundEnabled }
        set { AudioManager.shared.soundEnabled = newValue }
    }

    var selectedColonist: ColonistModel? {
        guard let id = selectedColonistId else { return nil }
        return colonists.first { $0.id == id }
    }

    func log(_ message: String) {
        gameLog.append(message)
        if gameLog.count > 50 {
            gameLog.removeFirst()
        }
    }
}
