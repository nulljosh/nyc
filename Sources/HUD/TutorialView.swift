import SwiftUI

struct TutorialView: View {
    @Bindable var gameState: GameState

    private var step: Int { gameState.tutorialStep ?? 0 }

    private var stepData: (title: String, body: String, hint: String) {
        switch step {
        case 0: ("WELCOME",    "Welcome to NYC Survive. You control a group of survivors.",                           "Tap to continue")
        case 1: ("NEEDS",      "Colonists have NEEDS — hunger, oxygen, stress, sleep, health. Keep them alive.",      "Tap to continue")
        case 2: ("STATS",      "Each colonist has RPG STATS — STR, INT, AGI, END, CHA. Tap a figure.",               "Tap a colonist")
        case 3: ("CAMERA",     "Drag to pan the camera. Pinch to zoom.",                                               "Tap to continue")
        case 4: ("BUILD",      "Tap BUILD to open the build menu. Buildings keep your colony running.",               "Tap BUILD")
        case 5: ("SHELTER",    "Place a SHELTER to reduce stress and let colonists sleep.",                            "Place a shelter")
        case 6: ("COMMAND",    "You are in control. Select a colonist, then tap a tile to move them. Assign jobs from the colonist panel.", "Tap a colonist")
        case 7: ("COMBAT",     "Colonists carry weapons. Assign ATTACK jobs to fight enemies. STR boosts damage.",    "Tap to continue")
        case 8: ("GOOD LUCK",  "Tap PAUSE to pause. Tap SAVE to save. Good luck.",                                   "Tap to dismiss")
        default: ("", "", "")
        }
    }

    private var isInteractiveStep: Bool { step == 2 || step == 4 || step == 5 }

    var body: some View {
        ZStack {
            Color.black.opacity(isInteractiveStep ? 0.3 : 0.55)
                .ignoresSafeArea()
                .allowsHitTesting(!isInteractiveStep)
                .onTapGesture { advance() }

            VStack(spacing: 14) {
                HStack {
                    Text("TUTORIAL \(step + 1)/9")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(Theme.text3)
                    Spacer()
                    Button(action: skip) {
                        Text("SKIP")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundStyle(Theme.red)
                    }
                    .buttonStyle(.plain)
                }

                Text(stepData.title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Theme.cyan)

                Text(stepData.body)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.text1)
                    .multilineTextAlignment(.center)

                Text(stepData.hint)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(Theme.yellow)
                    .opacity(hintPulse ? 1.0 : 0.4)
                    .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: hintPulse)
                    .onAppear { hintPulse = true; startTimer() }
                    .onChange(of: step) { startTimer() }

                HStack(spacing: 6) {
                    ForEach(0..<9, id: \.self) { i in
                        Circle()
                            .fill(i <= step ? Theme.accent : Theme.glass)
                            .frame(width: 7, height: 7)
                    }
                }
                .padding(.top, 4)
            }
            .padding(24)
            .frame(maxWidth: 420)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Theme.radiusLg))
            .overlay(RoundedRectangle(cornerRadius: Theme.radiusLg).stroke(Theme.border, lineWidth: 1))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: isInteractiveStep ? .top : .center)
            .padding(.top, isInteractiveStep ? 60 : 0)
        }
    }

    @State private var hintPulse = false
    @State private var timerTask: Task<Void, Never>?

    private func startTimer() {
        timerTask?.cancel()
        timerTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 30_000_000_000)
            guard !Task.isCancelled, gameState.tutorialStep != nil else { return }
            advance()
        }
    }

    private func advance() {
        gameState.tutorialStep = step >= 8 ? nil : step + 1
    }

    private func skip() {
        gameState.tutorialStep = nil
    }

    static func checkAdvance(gameState: GameState, event: TutorialEvent) {
        guard let step = gameState.tutorialStep else { return }
        switch (step, event) {
        case (2, .colonistSelected): gameState.tutorialStep = 3
        case (3, .cameraPanned):     gameState.tutorialStep = 4
        case (4, .buildMenuOpened):  gameState.tutorialStep = 5
        case (5, .shelterPlaced):    gameState.tutorialStep = 6
        case (6, .colonistSelected): gameState.tutorialStep = 7
        default: break
        }
    }
}

enum TutorialEvent {
    case colonistSelected
    case cameraPanned
    case buildMenuOpened
    case shelterPlaced
    case wasdPressed
}
