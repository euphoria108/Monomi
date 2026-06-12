import MonomiKit
import SwiftUI

struct DiskLabelView: View {
    let store: MetricStore

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            row(prefix: "R", rate: store.disk?.readBytesPerSecond ?? 0, active: .green)
            row(prefix: "W", rate: store.disk?.writeBytesPerSecond ?? 0, active: .orange)
        }
        .padding(.horizontal, 2)
    }

    private func row(prefix: String, rate: Double, active: Color) -> some View {
        HStack(spacing: 2) {
            Text(prefix)
                .font(.system(size: 7, weight: .bold))
                .foregroundStyle(rate > 1024 ? active : .secondary)
            Text(ByteFormat.rate(rate))
                .font(.system(size: 8, weight: .medium).monospacedDigit())
        }
    }
}
