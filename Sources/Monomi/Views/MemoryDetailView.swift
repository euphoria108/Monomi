import Charts
import MonomiKit
import SwiftUI

struct MemoryDetailView: View {
    let store: MetricStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("メモリ")
                    .font(.headline)
                Spacer()
                if let memory = store.memory {
                    Text("\(ByteFormat.bytes(memory.used)) / \(ByteFormat.bytes(memory.total))")
                        .font(.callout.monospacedDigit())
                }
            }

            Chart(Array(store.memoryHistory.elements.enumerated()), id: \.offset) { index, snapshot in
                AreaMark(
                    x: .value("Sample", index),
                    y: .value("Used", snapshot.usedFraction * 100)
                )
                .foregroundStyle(Color.blue.opacity(0.6))
            }
            .chartYScale(domain: 0...100)
            .chartXAxis(.hidden)
            .frame(height: 70)

            if let memory = store.memory {
                Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 4) {
                    row("アプリメモリ", memory.app)
                    row("確保済み (Wired)", memory.wired)
                    row("圧縮", memory.compressed)
                    GridRow {
                        Text("スワップ")
                            .foregroundStyle(.secondary)
                        Text("\(ByteFormat.bytes(memory.swapUsed)) / \(ByteFormat.bytes(memory.swapTotal))")
                            .monospacedDigit()
                            .gridColumnAlignment(.trailing)
                    }
                    GridRow {
                        Text("メモリプレッシャー")
                            .foregroundStyle(.secondary)
                        Text(pressureLabel(memory.pressure))
                            .foregroundStyle(pressureColor(memory.pressure))
                            .gridColumnAlignment(.trailing)
                    }
                }
                .font(.caption)
            }
        }
        .padding(14)
        .frame(width: 280)
    }

    private func row(_ label: String, _ value: UInt64) -> some View {
        GridRow {
            Text(label)
                .foregroundStyle(.secondary)
            Text(ByteFormat.bytes(value))
                .monospacedDigit()
                .gridColumnAlignment(.trailing)
        }
    }

    private func pressureLabel(_ level: MemorySnapshot.PressureLevel) -> String {
        switch level {
        case .normal: "正常"
        case .warning: "注意"
        case .critical: "逼迫"
        }
    }

    private func pressureColor(_ level: MemorySnapshot.PressureLevel) -> Color {
        switch level {
        case .normal: .green
        case .warning: .orange
        case .critical: .red
        }
    }
}
