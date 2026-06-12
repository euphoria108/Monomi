import MonomiKit
import SwiftUI

struct NetworkLabelView: View {
    let store: MetricStore

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            row(symbol: "arrow.down", rate: store.network?.downloadBytesPerSecond ?? 0, active: .blue)
            row(symbol: "arrow.up", rate: store.network?.uploadBytesPerSecond ?? 0, active: .red)
        }
        .padding(.horizontal, 2)
    }

    private func row(symbol: String, rate: Double, active: Color) -> some View {
        HStack(spacing: 2) {
            Image(systemName: symbol)
                .font(.system(size: 6, weight: .bold))
                .foregroundStyle(rate > 1024 ? active : .secondary)
            Text(ByteFormat.rate(rate))
                .font(.system(size: 8, weight: .medium).monospacedDigit())
        }
    }
}
