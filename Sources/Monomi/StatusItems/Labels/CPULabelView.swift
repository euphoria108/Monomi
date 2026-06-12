import MonomiKit
import SwiftUI

struct CPULabelView: View {
    let store: MetricStore

    private var usage: Double { store.cpu?.totalUsage ?? 0 }

    private var graphColor: Color {
        switch usage {
        case ..<0.5: .green
        case ..<0.8: .orange
        default: .red
        }
    }

    var body: some View {
        HStack(spacing: 3) {
            SparklineChart(
                values: store.cpuHistory.elements.suffix(40).map(\.totalUsage),
                color: graphColor
            )
            .frame(width: 36)
            Text(ByteFormat.percent(usage))
                .font(.system(size: 9, weight: .medium).monospacedDigit())
                .frame(width: 28, alignment: .trailing)
        }
        .padding(.vertical, 3)
        .padding(.horizontal, 2)
    }
}
