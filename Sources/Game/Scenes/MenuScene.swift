import SpriteKit
#if os(macOS)
import AppKit
typealias PlatformFont = NSFont
#else
import UIKit
typealias PlatformFont = UIFont
#endif

@MainActor
final class MenuScene: SKScene {
    var onNewGame: (() -> Void)?
    var onLoadGame: ((Int) -> Void)?

    private var showingLoadMenu = false
    private var loadMenuNodes: [SKNode] = []

    override func didMove(to view: SKView) {
        backgroundColor = ScenePalette.background

        let title = SKLabelNode(fontNamed: PlatformFont.systemFont(ofSize: 14, weight: .bold).fontName)
        // Must match the App Store name — a title screen that says something else
        // reads as the wrong app to a reviewer (see wiki: app-renaming).
        title.text = "NYC SURVIVE"
        title.fontSize = 48
        title.fontColor = ScenePalette.title
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.65)
        title.horizontalAlignmentMode = .center
        addChild(title)

        let subtitle = SKLabelNode(fontNamed: PlatformFont.systemFont(ofSize: 14).fontName)
        subtitle.text = "SURVIVAL SIMULATOR"
        subtitle.fontSize = 20
        subtitle.fontColor = ScenePalette.accentHot
        subtitle.position = CGPoint(x: size.width / 2, y: size.height * 0.55)
        subtitle.horizontalAlignmentMode = .center
        addChild(subtitle)

        let newGame = SKLabelNode(fontNamed: PlatformFont.systemFont(ofSize: 14, weight: .bold).fontName)
        newGame.text = "> NEW GAME"
        newGame.fontSize = 24
        newGame.fontColor = ScenePalette.accentWarm
        newGame.position = CGPoint(x: size.width / 2, y: size.height * 0.38)
        newGame.horizontalAlignmentMode = .center
        newGame.name = "newGame"
        addChild(newGame)

        let loadGame = SKLabelNode(fontNamed: PlatformFont.systemFont(ofSize: 14, weight: .bold).fontName)
        loadGame.text = "> LOAD GAME"
        loadGame.fontSize = 24
        loadGame.fontColor = ScenePalette.title
        loadGame.position = CGPoint(x: size.width / 2, y: size.height * 0.30)
        loadGame.horizontalAlignmentMode = .center
        loadGame.name = "loadGame"
        addChild(loadGame)

        #if os(macOS)
        let quit = SKLabelNode(fontNamed: PlatformFont.systemFont(ofSize: 14, weight: .bold).fontName)
        quit.text = "> QUIT"
        quit.fontSize = 24
        quit.fontColor = ScenePalette.muted
        quit.position = CGPoint(x: size.width / 2, y: size.height * 0.22)
        quit.horizontalAlignmentMode = .center
        quit.name = "quit"
        addChild(quit)
        #endif

        let blink = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.5),
            SKAction.fadeAlpha(to: 1.0, duration: 0.5)
        ])
        newGame.run(SKAction.repeatForever(blink))
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

        let header = SKLabelNode(fontNamed: PlatformFont.systemFont(ofSize: 14, weight: .bold).fontName)
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

            let label = SKLabelNode(fontNamed: PlatformFont.systemFont(ofSize: 14, weight: .bold).fontName)
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

        let back = SKLabelNode(fontNamed: PlatformFont.systemFont(ofSize: 14, weight: .bold).fontName)
        back.text = "[ ESC TO GO BACK ]"
        back.fontSize = 14
        back.fontColor = ScenePalette.muted
        back.position = CGPoint(x: size.width / 2, y: size.height * 0.18)
        back.horizontalAlignmentMode = .center
        back.zPosition = 11
        addChild(back)
        loadMenuNodes.append(back)
    }

    private func hideLoadMenu() {
        for node in loadMenuNodes {
            node.removeFromParent()
        }
        loadMenuNodes.removeAll()
        showingLoadMenu = false
    }

    private func handleTap(at location: CGPoint) {
        let nodes = self.nodes(at: location)

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
        if event.keyCode == 53 && showingLoadMenu {
            hideLoadMenu()
        }
    }
    #endif
}
