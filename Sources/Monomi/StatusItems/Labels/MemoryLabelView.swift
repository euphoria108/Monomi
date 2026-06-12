import MonomiKit
import SwiftUI

struct MemoryLabelView: View {
    let store: MetricStore

    private var fraction: Double { store.memory?.usedFraction ?? 0 }

    private var gaugeColor: Color {
        guard let memory = store.memory else { return .secondary }
        switch memory.pressure {
        case .normal: return .blue
        case .warning: return .orange
        case .critical: return .red
        }
    }

    var body: some View {
        HStack(spacing: 3) {
            GeometryReader { proxy in
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.secondary.opacity(0.25))
                    RoundedRectangle(cornerRadius: 2)
                        .fill(gaugeColor)
                        .frame(height: proxy.size.height * fraction)
                }
            }
            .frame(width: 8)
            Text(ByteFormat.percent(fraction))
                .font(.system(size: 9, weight: .medium).monospacedDigit())
                .frame(width: 28, alignment: .trailing)
        }
        .padding(.vertical, 3)
        .padding(.horizontal, 2)
    }
}
