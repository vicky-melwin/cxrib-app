import SwiftUI

struct IOSBackButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))

                Text(title)
                    .font(.system(size: 17, weight: .regular))
            }
            .foregroundColor(.white)
        }
        .buttonStyle(.plain)
    }
}

