import SwiftUI

struct HUDView: View {
    @Bindable var gameState: GameState

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.clear.allowsHitTesting(false)

            // Resource bar
            VStack(spacing: 0) {
                ResourceBar(gameState: gameState)
                    .padding(8)
                Spacer()
            }

            // Build menu
            if gameState.showBuildMenu {
                HStack {
                    BuildMenu(gameState: gameState)
                        .padding(8)
                        .allowsHitTesting(true)
                    Spacer()
                }
                .padding(.top, 50)
            }

            // Colonist panel
            if gameState.selectedColonist != nil {
                HStack {
                    Spacer()
                    ColonistPanel(gameState: gameState)
                        .padding(8)
                        .allowsHitTesting(true)
                }
                .padding(.top, 50)
            }

            // Game log + minimap row
            VStack {
                Spacer()
                HStack(alignment: .bottom) {
                    gameLogView
                        .padding(8)
                    Spacer()
                    MiniMap()
                        .padding(8)
                }
                .padding(.bottom, 110)
            }

            // Pause overlay
            if gameState.isPaused && !gameState.showSettings {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                VStack(spacing: 12) {
                    Text("PAUSED")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(Theme.text1)
                    GlassButton(label: "RESUME", isPrimary: true) { gameState.isPaused = false }
                    GlassButton(label: "SETTINGS") {
                        gameState.showSettings = true
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .allowsHitTesting(true)
            }

            // Time display
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("Tick \(gameState.currentTick) | \(gameState.currentHour):00 | \(gameState.isNight ? "NIGHT" : "DAY")")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(Theme.text3)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(RoundedRectangle(cornerRadius: 6).fill(Theme.glass))
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Theme.border, lineWidth: 0.5))
                        .padding(8)
                }
                .padding(.bottom, 110)
            }

            // Save indicator
            if gameState.showSaveIndicator {
                VStack {
                    HStack {
                        Spacer()
                        Text("SAVED")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundStyle(Theme.green)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(Theme.glass))
                            .overlay(Capsule().stroke(Theme.green.opacity(0.4), lineWidth: 1))
                            .padding(8)
                    }
                    Spacer()
                }
            }

            // Auto-save dot
            if gameState.autoSaveEnabled && gameState.lastSaveSlot != nil {
                VStack {
                    HStack {
                        Spacer()
                        Circle()
                            .fill(Theme.green)
                            .frame(width: 6, height: 6)
                            .padding(.trailing, 12)
                            .padding(.top, gameState.showSaveIndicator ? 44 : 12)
                    }
                    Spacer()
                }
            }

            // Bottom toolbar
            VStack {
                Spacer()

                // Main toolbar
                HStack(spacing: 8) {
                    toolbarPill(label: gameState.isPaused ? "PLAY" : "PAUSE") {
                        gameState.isPaused.toggle()
                    }
                    toolbarPill(label: "BUILD", isActive: gameState.showBuildMenu) {
                        gameState.showBuildMenu.toggle()
                        if !gameState.showBuildMenu {
                            gameState.inputMode = .normal
                            gameState.selectedBuildingType = nil
                        }
                        TutorialView.checkAdvance(gameState: gameState, event: .buildMenuOpened)
                    }
                    toolbarPill(label: "SETTINGS", isActive: gameState.showSettings) {
                        gameState.showSettings.toggle()
                        if gameState.showSettings { gameState.isPaused = true }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .liquidGlass(in: Rectangle(), fallback: .ultraThinMaterial)
                .overlay(alignment: .top) { Theme.border.frame(height: 1) }
                .allowsHitTesting(true)
            }

            // Settings overlay
            if gameState.showSettings {
                SettingsView(gameState: gameState).allowsHitTesting(true)
            }

            // Tutorial overlay
            if gameState.tutorialStep != nil {
                TutorialView(gameState: gameState).allowsHitTesting(true)
            }
        }
    }

    private var gameLogView: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(Array(gameState.gameLog.suffix(3).enumerated()), id: \.offset) { _, msg in
                Text(msg)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(Theme.text2)
            }
        }
        .padding(8)
        .frame(maxWidth: 280, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: Theme.radius).fill(Theme.glass))
        .overlay(RoundedRectangle(cornerRadius: Theme.radius).stroke(Theme.border, lineWidth: 0.5))
    }

    private func toolbarPill(label: String, isActive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(isActive ? .white : Theme.text2)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(minHeight: 36)
                .background(
                    Capsule()
                        .fill(isActive ? Theme.accent.opacity(0.35) : Theme.glass)
                        .overlay(Capsule().stroke(isActive ? Theme.accent : Theme.border, lineWidth: 1))
                )
        }
        .buttonStyle(.plain)
    }
}

