import Charts
import MonomiKit
import SwiftUI

struct CPUDetailView: View {
    let store: MetricStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("CPU")
                    .font(.headline)
                Spacer()
                if let cpu = store.cpu {
                    Text(ByteFormat.percent(cpu.totalUsage))
                        .font(.title3.monospacedDigit())
                }
            }

            Chart(Array(store.cpuHistory.elements.enumerated()), id: \.offset) { index, snapshot in
                AreaMark(
                    x: .value("Sample", index),
                    y: .value("System", snapshot.systemUsage * 100),
                    stacking: .standard
                )
                .foregroundStyle(by: .value("Kind", "System"))
                AreaMark(
                    x: .value("Sample", index),
                    y: .value("User", snapshot.userUsage * 100),
                    stacking: .standard
                )
                .foregroundStyle(by: .value("Kind", "User"))
            }
            .chartForegroundStyleScale(["User": Color.green, "System": Color.red])
            .chartYScale(domain: 0...100)
            .chartXAxis(.hidden)
            .frame(height: 90)

            if let cpu = store.cpu {
                VStack(alignment: .leading, spacing: 4) {
                    Text("コア別")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(alignment: .bottom, spacing: 2) {
                        ForEach(Array(cpu.cores.enumerated()), id: \.offset) { _, core in
                            ZStack(alignment: .bottom) {
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(.secondary.opacity(0.2))
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(core.total > 0.8 ? Color.red : Color.green)
                                    .frame(height: max(28 * core.total, 1))
                            }
                            .frame(height: 28)
                        }
                    }
                }

                HStack {
                    Text("Load Average")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(cpu.loadAverage.map { String(format: "%.2f", $0) }.joined(separator: "  "))
                        .font(.caption.monospacedDigit())
                }
            }

            if !store.topProcesses.isEmpty {
                Divider()
                VStack(alignment: .leading, spacing: 4) {
                    Text("上位プロセス")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ForEach(store.topProcesses) { process in
                        HStack {
                            Text(process.name)
                                .lineLimit(1)
                            Spacer()
                            Text(String(format: "%.1f%%", process.cpuFraction * 100))
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                        }
                        .font(.caption)
                    }
                }
            }
        }
        .padding(14)
        .frame(width: 280)
    }
}
