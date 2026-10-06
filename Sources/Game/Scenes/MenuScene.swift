import SpriteKit
#if os(macOS)
import AppKit
#else
import UIKit
#endif

@MainActor
final class MenuScene: SKScene {
    var onNewGame: (() -> Void)?
    var onLoadGame: ((Int) -> Void)?

    /// Soft rounded system face, falls back to Helvetica if the design is unavailable.
    private func chill(_ weight: ChillWeight = .semibold) -> String {
        #if os(macOS)
        let base = NSFont.systemFont(ofSize: 24, weight: weight == .bold ? .bold : weight == .regular ? .regular : .semibold)
        if let d = base.fontDescriptor.withDesign(.rounded), let f = NSFont(descriptor: d, size: 24) { return f.fontName }
        #else
        let base = UIFont.systemFont(ofSize: 24, weight: weight == .bold ? .bold : weight == .regular ? .regular : .semibold)
        if let d = base.fontDescriptor.withDesign(.rounded) { return UIFont(descriptor: d, size: 24).fontName }
        #endif
        return "HelveticaNeue-Medium"
    }
    private enum ChillWeight { case regular, semibold, bold }

    private var showingSettings = false
    private var showingLoadMenu = false
    private var loadMenuNodes: [SKNode] = []

    override func didMove(to view: SKView) {
        backgroundColor = ScenePalette.background

        let title = SKLabelNode(fontNamed: chill(.bold))
        // Must match the App Store name — a title screen that says something else
        // reads as the wrong app to a reviewer (see wiki: app-renaming).
        title.text = "NYC Survive"
        title.fontSize = 48
        title.fontColor = ScenePalette.title
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.65)
        title.horizontalAlignmentMode = .center
        addChild(title)

        let subtitle = SKLabelNode(fontNamed: chill(.regular))
        subtitle.text = "Survival Simulator"
        subtitle.fontSize = 20
        subtitle.fontColor = ScenePalette.accentHot
        subtitle.position = CGPoint(x: size.width / 2, y: size.height * 0.55)
        subtitle.horizontalAlignmentMode = .center
        addChild(subtitle)

        let newGame = SKLabelNode(fontNamed: chill(.bold))
        newGame.text = "New Game"
        newGame.fontSize = 24
        newGame.fontColor = ScenePalette.accentWarm
        newGame.position = CGPoint(x: size.width / 2, y: size.height * 0.38)
        newGame.horizontalAlignmentMode = .center
        newGame.name = "newGame"
        addChild(newGame)

        let loadGame = SKLabelNode(fontNamed: chill(.bold))
        loadGame.text = "Load Game"
        loadGame.fontSize = 24
        loadGame.fontColor = ScenePalette.title
        loadGame.position = CGPoint(x: size.width / 2, y: size.height * 0.30)
        loadGame.horizontalAlignmentMode = .center
        loadGame.name = "loadGame"
        addChild(loadGame)

        let settings = SKLabelNode(fontNamed: chill(.bold))
        settings.text = "Settings"
        settings.fontSize = 24
        settings.fontColor = ScenePalette.title
        settings.position = CGPoint(x: size.width / 2, y: size.height * 0.22)
        settings.horizontalAlignmentMode = .center
        settings.name = "settings"
        addChild(settings)

        #if os(macOS)
        let quit = SKLabelNode(fontNamed: chill(.bold))
        quit.text = "Quit"
        quit.fontSize = 24
        quit.fontColor = ScenePalette.muted
        quit.position = CGPoint(x: size.width / 2, y: size.height * 0.14)
        quit.horizontalAlignmentMode = .center
        quit.name = "quit"
        addChild(quit)
        #endif
    }

    private func showLoadMenu() {
        guard !showingLoadMenu else { return }
        showingLoadMenu = true

        // Dim overlay
        let overlay = SKShapeNode(rect: CGRect(origin: .zero, size: size))
        overlay.fillColor = ScenePalette.overlayScrim
        overlay.strokeColor = .clear
        overlay.name = "loadOverlay"
        overlay.zPosition = 10
        addChild(overlay)
        loadMenuNodes.append(overlay)

        let header = SKLabelNode(fontNamed: chill(.bold))
        header.text = "LOAD GAME"
        header.fontSize = 28
        header.fontColor = ScenePalette.title
        header.position = CGPoint(x: size.width / 2, y: size.height * 0.72)
        header.horizontalAlignmentMode = .center
        header.zPosition = 11
        addChild(header)
        loadMenuNodes.append(header)

        let slots = SaveManager.shared.listSlots()

        for i in 0..<3 {
            let slotY = size.height * (0.58 - CGFloat(i) * 0.14)
            let slotData = slots[i]

            let bg = SKShapeNode(rect: CGRect(x: size.width / 2 - 200, y: slotY - 20, width: 400, height: 50), cornerRadius: 0)
            bg.fillColor = ScenePalette.panelFill
            bg.strokeColor = ScenePalette.title.withAlphaComponent(0.3)
            bg.lineWidth = 1
            bg.name = "loadSlot\(i + 1)"
            bg.zPosition = 11
            addChild(bg)
            loadMenuNodes.append(bg)

            let label = SKLabelNode(fontNamed: chill(.bold))
            label.fontSize = 16
            label.horizontalAlignmentMode = .center
            label.verticalAlignmentMode = .center
            label.position = CGPoint(x: size.width / 2, y: slotY + 5)
            label.zPosition = 12
            label.name = "loadSlot\(i + 1)"

            if let slot = slotData {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d, HH:mm"
                let dateStr = formatter.string(from: slot.timestamp)
                label.text = "SLOT \(i + 1) -- Day \(slot.dayCount) | \(slot.colonistCount) alive | \(dateStr)"
                label.fontColor = ScenePalette.accentWarm
            } else {
                label.text = "SLOT \(i + 1) -- EMPTY --"
                label.fontColor = ScenePalette.disabled
            }

            addChild(label)
            loadMenuNodes.append(label)
        }

        let back = SKLabelNode(fontNamed: chill(.bold))
        back.text = "[ ESC TO GO BACK ]"
        back.fontSize = 14
        back.fontColor = ScenePalette.muted
        back.position = CGPoint(x: size.width / 2, y: size.height * 0.18)
        back.horizontalAlignmentMode = .center
        back.zPosition = 11
        addChild(back)
        loadMenuNodes.append(back)
    }

    private func showSettings() {
        guard !showingSettings else { return }
        showingSettings = true
        let overlay = SKShapeNode(rect: CGRect(origin: .zero, size: size))
        overlay.fillColor = ScenePalette.overlayScrim
        overlay.strokeColor = .clear
        overlay.name = "settingsOverlay"
        overlay.zPosition = 10
        addChild(overlay)
        loadMenuNodes.append(overlay)
        let lines = [
            ("How to play", true),
            ("Click a survivor, or drag a box around a few", false),
            ("Click the ground to send them there", false),
            ("Click a resource to gather it", false),
            ("B opens build, 1-6 picks a building", false),
            ("WASD pans, scroll zooms, Esc deselects", false),
            ("Keep food, air, sleep and stress up. Build before night.", false),
            ("Tap anywhere to go back", false),
        ]
        for (i, line) in lines.enumerated() {
            let l = SKLabelNode(fontNamed: chill(line.1 ? .bold : .regular))
            l.text = line.0
            l.fontSize = line.1 ? 28 : 18
            l.fontColor = line.1 ? ScenePalette.title : ScenePalette.muted
            l.position = CGPoint(x: size.width / 2, y: size.height * 0.74 - CGFloat(i) * 34)
            l.horizontalAlignmentMode = .center
            l.zPosition = 11
            addChild(l)
            loadMenuNodes.append(l)
        }
    }

    private func hideLoadMenu() {
        for node in loadMenuNodes {
            node.removeFromParent()
        }
        loadMenuNodes.removeAll()
        showingLoadMenu = false
        showingSettings = false
    }

    private func handleTap(at location: CGPoint) {
        let nodes = self.nodes(at: location)

        if showingSettings {
            hideLoadMenu()
            return
        }
        if showingLoadMenu {
            let slots = SaveManager.shared.listSlots()
            for node in nodes {
                guard let name = node.name else { continue }
                for i in 1...3 {
                    if name == "loadSlot\(i)" && slots[i - 1] != nil {
                        onLoadGame?(i)
                        return
                    }
                }
            }
            return
        }

        for node in nodes {
            if node.name == "newGame" {
                onNewGame?()
            } else if node.name == "loadGame" {
                showLoadMenu()
            } else if node.name == "settings" {
                showSettings()
            } else if node.name == "quit" {
                #if os(macOS)
                NSApplication.shared.terminate(nil)
                #endif
            }
        }
    }

    #if os(macOS)
    override func mouseDown(with event: NSEvent) {
        handleTap(at: event.location(in: self))
    }
    #else
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        handleTap(at: touch.location(in: self))
    }
    #endif

    #if os(macOS)
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 && (showingLoadMenu || showingSettings) {
            hideLoadMenu()
        }
    }
    #endif
}
