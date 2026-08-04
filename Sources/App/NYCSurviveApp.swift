import SwiftUI
import SpriteKit

@main
struct NYCSurviveApp: App {
    @State private var gameState = GameState()
    @State private var showMenu = true
    @State private var loadSlot: Int? = nil

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showMenu {
                    MenuSceneView(
                        onNewGame: {
                            gameState = GameState()
                            gameState.tutorialStep = 0
                            loadSlot = nil
                            showMenu = false
                        },
                        onLoadGame: { slot in
                            loadSlot = slot
                            gameState = GameState()
                            gameState.tutorialStep = nil
                            if SaveManager.shared.load(slot: slot) != nil {
                                gameState.lastSaveSlot = slot
                            }
                            showMenu = false
                        }
                    )
                } else {
                    GameView(gameState: gameState, loadSlot: loadSlot)
                }
            }
            .frame(minWidth: 1280, minHeight: 800)
            .preferredColorScheme(.dark)
        }
        .defaultSize(width: 1280, height: 800)
    }
}

struct MenuSceneView: NSViewRepresentable {
    var onNewGame: () -> Void
    var onLoadGame: (Int) -> Void

    func makeNSView(context: Context) -> SKView {
        let view = SKView()
        let scene = MenuScene(size: CGSize(width: 1280, height: 800))
        scene.scaleMode = .aspectFill
        scene.onNewGame = onNewGame
        scene.onLoadGame = onLoadGame
        view.presentScene(scene)
        return view
    }

    func updateNSView(_ nsView: SKView, context: Context) {}
}

struct GameView: View {
    @Bindable var gameState: GameState
    var loadSlot: Int?

    var body: some View {
        ZStack {
            GameSceneView(gameState: gameState, loadSlot: loadSlot)
            HUDView(gameState: gameState)
        }
    }
}

/// SKView subclass that grabs and holds first responder so keyboard/scroll
/// events reach the SpriteKit scene instead of being eaten by SwiftUI.
class FocusableSKView: SKView {
    override var acceptsFirstResponder: Bool { true }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        DispatchQueue.main.async { [weak self] in
            self?.window?.makeFirstResponder(self)
        }
    }

    override func scrollWheel(with event: NSEvent) {
        scene?.scrollWheel(with: event)
    }
}

struct GameSceneView: NSViewRepresentable {
    let gameState: GameState
    var loadSlot: Int?

    func makeNSView(context: Context) -> FocusableSKView {
        let view = FocusableSKView()
        #if DEBUG
        view.showsFPS = true
        view.showsNodeCount = true
        #endif
        view.ignoresSiblingOrder = true
        let scene = GameScene(gameState: gameState)
        if let slot = loadSlot {
            scene.savedData = SaveManager.shared.load(slot: slot)
        }
        view.presentScene(scene)
        return view
    }

    func updateNSView(_ nsView: FocusableSKView, context: Context) {}
}
