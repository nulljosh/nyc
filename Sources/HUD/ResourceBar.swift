import SwiftUI

struct ResourceBar: View {
    let gameState: GameState

    var body: some View {
        HStack(spacing: 4) {
            ForEach([ResourceType.food, .power, .materials, .oxygen, .cash], id: \.self) { type in
                resourcePill(type: type)
            }
            Spacer()
            Text("\(gameState.colonists.filter { !$0.isDead }.count) alive")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Theme.text2)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .liquidGlass(in: RoundedRectangle(cornerRadius: Theme.radiusLg), fallback: .ultraThinMaterial)
        .overlay(RoundedRectangle(cornerRadius: Theme.radiusLg).stroke(Theme.border, lineWidth: 1))
    }

    private func resourcePill(type: ResourceType) -> some View {
        let meta = resourceMeta[type]
        let color = meta?.color ?? Theme.text2
        let label = meta?.label ?? type.rawValue.uppercased()
        let iconName = meta?.icon ?? "circle"

        return HStack(spacing: 4) {
            Image(systemName: iconName)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(color)
            Text("\(gameState.resources[type, default: 0])")
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(Theme.text1)
            Text(label)
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundStyle(Theme.text3)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(Capsule().fill(Theme.glass).overlay(Capsule().stroke(Theme.border, lineWidth: 0.5)))
    }
}
