import SpriteKit
import GameplayKit

@MainActor
final class GameScene: SKScene {
    let gameState: GameState
    private var tileMap: TileMap!
    private var productionSystem = ProductionSystem()
    private var buildSystem = BuildSystem()
    private var pathfinder: Pathfinder!
    private var inputHandler = InputHandler()
    private var cameraController = CameraController()

    private var buildingNodes: [UUID: BuildingNode] = [:]

    private var lastUpdateTime: TimeInterval = 0

    // Drag selection
    private var selectionStart: CGPoint?
    private var selectionRect: SKShapeNode?

    // Tutorial highlight nodes
    private var tutorialHighlights: [SKNode] = []

    // For loading from save
    var savedData: SaveData?

    init(gameState: GameState) {
        self.gameState = gameState
        super.init(size: CGSize(width: 4096, height: 4096))
        self.scaleMode = .resizeFill
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func didMove(to view: SKView) {
        backgroundColor = NSColor(red: 0.04, green: 0.04, blue: 0.05, alpha: 1)
        view.showsFPS = true
        view.showsNodeCount = true

        let grid: [[TileType]]
        if let save = savedData {
            grid = SaveManager.shared.rebuildGrid(from: save)
            gameState.buildings = save.buildings
            gameState.globalInventory = save.globalInventory
            gameState.currentTick = save.currentTick
        } else {
            let result = WorldGenerator.generate()
            grid = result.grid
        }

        tileMap = TileMap(grid: grid)
        addChild(tileMap.node)

        pathfinder = Pathfinder(columns: WorldGenerator.gridSize, rows: WorldGenerator.gridSize)
        pathfinder.buildGraph(grid: grid)

        // Rebuild building nodes from game state
        for model in gameState.buildings {
            let node = BuildingNode(model: model, tileSize: TileMap.tileSize)
            node.position = CGPoint(x: CGFloat(model.col) * TileMap.tileSize, y: CGFloat(model.row) * TileMap.tileSize)
            addChild(node)
            buildingNodes[model.id] = node
        }

        let center = WorldGenerator.gridSize / 2
        camera = cameraController.cameraNode
        addChild(cameraController.cameraNode)
        cameraController.centerOn(position: tileMap.worldPosition(col: center, row: center))

        inputHandler.gameState = gameState
        inputHandler.cameraController = cameraController
        inputHandler.onSelectEntity = { [weak self] location in
            self?.selectEntity(at: location)
        }
        inputHandler.onPlaceBuilding = { [weak self] col, row in
            self?.placeBuilding(col: col, row: row)
        }
        inputHandler.onDemolish = { [weak self] location in
            self?.demolishAt(location: location)
        }
        inputHandler.onSave = { [weak self] in
            self?.performSave()
        }

        NotificationCenter.default.addObserver(
            forName: .performSaveToSlot,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            let slot = notification.userInfo?["slot"] as? Int
            Task { @MainActor in
                if let slot {
                    self?.performSave(slot: slot)
                }
            }
        }

        if savedData != nil {
            gameState.log("Game loaded")
        } else {
            gameState.log("Welcome to NYC Survive")
        }
    }

    override func update(_ currentTime: TimeInterval) {
        let dt = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        cameraController.update(deltaTime: dt)

        gameState.currentTick += 1

        productionSystem.tick(buildings: &gameState.buildings)

        // Auto-save every 60 ticks
        if gameState.autoSaveEnabled && gameState.currentTick > 0 && gameState.currentTick % 60 == 0 {
            if let slot = gameState.lastSaveSlot {
                performSave(slot: slot)
            }
        }

        for model in gameState.buildings {
            if let node = buildingNodes[model.id] {
                node.updateProgress(model.productionProgress)
            }
        }

        if gameState.inputMode == .build, let type = gameState.selectedBuildingType {
            let mouseLocation = NSEvent.mouseLocation
            if let view = self.view {
                let viewPoint = view.convert(mouseLocation, from: nil)
                let scenePoint = convertPoint(fromView: viewPoint)
                let tilePos = tileMap.tilePosition(worldX: scenePoint.x, worldY: scenePoint.y)
                buildSystem.updateGhost(col: tilePos.col, row: tilePos.row, type: type, parent: self)
            }
        } else {
            buildSystem.removeGhost()
        }
    }

    override func keyDown(with event: NSEvent) {
        inputHandler.handleKeyDown(event: event)
    }

    override func keyUp(with event: NSEvent) {
        inputHandler.handleKeyUp(event: event)
    }

    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        if gameState.inputMode == .normal && event.modifierFlags.contains(.shift) {
            selectionStart = location
            return
        }
        inputHandler.handleMouseDown(location: location, tileMap: tileMap)
    }

    override func mouseDragged(with event: NSEvent) {
        guard let start = selectionStart else { return }
        let current = event.location(in: self)
        updateSelectionRect(from: start, to: current)
    }

    override func mouseUp(with event: NSEvent) {
        if let start = selectionStart {
            let end = event.location(in: self)
            finalizeSelection(from: start, to: end)
            selectionStart = nil
            selectionRect?.removeFromParent()
            selectionRect = nil
            return
        }
    }

    override func scrollWheel(with event: NSEvent) {
        inputHandler.handleScrollWheel(deltaY: event.deltaY)
    }

    private func updateSelectionRect(from start: CGPoint, to end: CGPoint) {
        selectionRect?.removeFromParent()
        let rect = CGRect(
            x: min(start.x, end.x),
            y: min(start.y, end.y),
            width: abs(end.x - start.x),
            height: abs(end.y - start.y)
        )
        let node = SKShapeNode(rect: rect)
        node.strokeColor = NSColor(red: 0.39, green: 0.82, blue: 1.0, alpha: 0.8)
        node.fillColor = NSColor(red: 0.39, green: 0.82, blue: 1.0, alpha: 0.15)
        node.lineWidth = 2
        node.zPosition = 100
        addChild(node)
        selectionRect = node
    }

    private func finalizeSelection(from start: CGPoint, to end: CGPoint) {
        let rect = CGRect(
            x: min(start.x, end.x),
            y: min(start.y, end.y),
            width: abs(end.x - start.x),
            height: abs(end.y - start.y)
        )
        gameState.selectedColonistIds.removeAll()
        gameState.selectedColonistId = nil
        for (id, node) in colonistNodes {
            if rect.contains(node.position) {
                gameState.selectedColonistIds.insert(id)
            }
        }
        if gameState.selectedColonistIds.count == 1 {
            gameState.selectedColonistId = gameState.selectedColonistIds.first
        }
        if !gameState.selectedColonistIds.isEmpty {
            gameState.log("Selected \(gameState.selectedColonistIds.count) colonists")
        }
    }

    private func selectEntity(at location: CGPoint) {
        gameState.selectedColonistId = nil
        for (id, node) in colonistNodes {
            let expandedFrame = node.frame.insetBy(dx: -10, dy: -10)
            if expandedFrame.contains(location) {
                gameState.selectedColonistId = id
                gameState.log("Selected \(gameState.colonists.first { $0.id == id }?.name ?? "colonist")")
                TutorialView.checkAdvance(gameState: gameState, event: .colonistSelected)
                return
            }
        }
    }

    private func placeBuilding(col: Int, row: Int) {
        guard let type = gameState.selectedBuildingType else { return }
        if let model = buildSystem.place(type: type, col: col, row: row, tileMap: tileMap, gameState: gameState, pathfinder: pathfinder) {
            let node = BuildingNode(model: model, tileSize: TileMap.tileSize)
            node.position = CGPoint(x: CGFloat(col) * TileMap.tileSize, y: CGFloat(row) * TileMap.tileSize)
            addChild(node)
            node.playPlaceAnimation()
            buildingNodes[model.id] = node
            AudioManager.shared.buildingPlaced()

            if type == .shelter {
                TutorialView.checkAdvance(gameState: gameState, event: .shelterPlaced)
            }

            // Grant build XP to nearby colonists
            for i in gameState.colonists.indices {
                if gameState.colonists[i].job == .build && !gameState.colonists[i].isDead {
                    let dist = abs(gameState.colonists[i].col - col) + abs(gameState.colonists[i].row - row)
                    if dist <= 5 {
                        gameState.colonists[i].grantXP(10)
                    }
                }
            }
        }
    }

    private func demolishAt(location: CGPoint) {
        for (id, node) in buildingNodes {
            if node.frame.contains(location) {
                buildSystem.demolish(id: id, tileMap: tileMap, gameState: gameState, pathfinder: pathfinder)
                node.removeFromParent()
                buildingNodes.removeValue(forKey: id)
                return
            }
        }
    }

    private func updateTutorialHighlights() {
        // Remove old highlights
        for node in tutorialHighlights { node.removeFromParent() }
        tutorialHighlights.removeAll()

        guard let step = gameState.tutorialStep else { return }

        switch step {
        case 2:
            // Pulse circles around colonists
            for (_, node) in colonistNodes {
                let pulse = SKShapeNode(circleOfRadius: 20)
                pulse.strokeColor = NSColor(red: 1.0, green: 0.84, blue: 0.04, alpha: 0.9)
                pulse.fillColor = .clear
                pulse.lineWidth = 2
                pulse.position = node.position
                pulse.zPosition = 50
                let grow = SKAction.scale(to: 1.5, duration: 0.6)
                let shrink = SKAction.scale(to: 1.0, duration: 0.6)
                let fade = SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.3, duration: 0.6),
                    SKAction.fadeAlpha(to: 1.0, duration: 0.6)
                ])
                pulse.run(SKAction.repeatForever(SKAction.group([SKAction.sequence([grow, shrink]), fade])))
                addChild(pulse)
                tutorialHighlights.append(pulse)
            }
        default:
            break
        }
    }

    private func performSave(slot: Int? = nil) {
        let targetSlot = slot ?? gameState.lastSaveSlot ?? 1
        do {
            try SaveManager.shared.save(slot: targetSlot, gameState: gameState, grid: tileMap.grid)
            gameState.lastSaveSlot = targetSlot
            gameState.showSaveIndicator = true
            gameState.log("Game saved to slot \(targetSlot)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.gameState.showSaveIndicator = false
            }
        } catch {
            gameState.log("Save failed: \(error.localizedDescription)")
        }
    }
}
