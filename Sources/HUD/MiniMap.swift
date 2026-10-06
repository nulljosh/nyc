import SwiftUI

struct MiniMap: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: Theme.radius)
                .fill(.ultraThinMaterial)
                .frame(width: 150, height: 150)

            Text("MINIMAP")
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(Theme.text3)
                .padding(6)
        }
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radius)
                .stroke(Theme.border, lineWidth: 1)
        )
        .frame(width: 150, height: 150)
    }
}
