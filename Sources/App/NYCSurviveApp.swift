import SwiftUI
import SpriteKit

@main
struct NYCSurviveApp: App {
    /// ponytail: App Store screenshot hook. `-shot N` skips the menu straight into a
    /// fresh game and preselects a panel, so captures show the app in use instead of
    /// the title screen (Guideline 2.3.3). Nothing else reads it; ignore in normal runs.
    static let shotVariant: Int? = {
        let args = ProcessInfo.processInfo.arguments
        guard let i = args.firstIndex(of: "-shot"), i + 1 < args.count else { return nil }
        return Int(args[i + 1])
    }()

    @State private var themeChoice = Theme.choice
    @State private var gameState = GameState()
    @State private var showMenu = NYCSurviveApp.shotVariant == nil
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
            .preferredColorScheme(themeChoice.colorScheme)
            .onReceive(NotificationCenter.default.publisher(for: .themeDidChange)) { _ in
                themeChoice = Theme.choice
            }
            .shareApp("https://nyc.heyitsmejosh.com")
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
        .task {
            // ponytail: colonists are spawned by GameScene, so the shot preset has to
            // run after the scene has ticked at least once.
            guard let shot = NYCSurviveApp.shotVariant else { return }
            gameState.tutorialStep = nil
            try? await Task.sleep(for: .seconds(2))
            switch shot {
            case 2: gameState.selectedColonistId = gameState.colonists.first?.id
            case 3: gameState.selectedBuildingType = BuildingType.allCases.first
            default: gameState.selectedBuildingType = nil
            }
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

// MARK: - Share

// ponytail: one overlay rather than a per-screen toolbar button — these root views share no
// navigation container to hang a .toolbar on. Move it into a toolbar per screen if this ever
// covers something that matters.
private struct AppShareOverlay: ViewModifier {
    let link: String

    func body(content: Content) -> some View {
        content.overlay(alignment: .bottomTrailing) {
            if let url = URL(string: link) {
                ShareLink(item: url) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 15, weight: .medium))
                        .padding(10)
                        .background(.regularMaterial, in: Circle())
                }
                .buttonStyle(.plain)
                .padding(16)
            }
        }
    }
}

private extension View {
    func shareApp(_ link: String) -> some View { modifier(AppShareOverlay(link: link)) }
}
