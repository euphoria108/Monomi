import MonomiKit
import SwiftUI

struct SensorDetailView: View {
    let store: MetricStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("センサー")
                .font(.headline)

            if let sensors = store.sensors {
                Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 4) {
                    if let cpu = sensors.cpuTemperature {
                        temperatureRow("CPU 温度", cpu)
                    }
                    if let gpu = sensors.gpuTemperature {
                        temperatureRow("GPU 温度", gpu)
                    }
                }
                .font(.caption)

                if !sensors.fans.isEmpty {
                    Divider()
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ファン")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        ForEach(sensors.fans) { fan in
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text("ファン \(fan.id + 1)")
                                        .font(.caption)
                                    Spacer()
                                    Text(String(format: "%.0f RPM", fan.rpm))
                                        .font(.caption.monospacedDigit())
                                }
                                if let lower = fan.minRPM, let upper = fan.maxRPM, upper > lower {
                                    let fraction = min(max((fan.rpm - lower) / (upper - lower), 0), 1)
                                    GeometryReader { proxy in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(.secondary.opacity(0.2))
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(Color.teal)
                                                .frame(width: proxy.size.width * fraction)
                                        }
                                    }
                                    .frame(height: 4)
                                }
                            }
                        }
                    }
                }
            } else {
                Text("センサー情報を取得できません")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(width: 260)
    }

    private func temperatureRow(_ label: String, _ value: Double) -> some View {
        GridRow {
            Text(label)
                .foregroundStyle(.secondary)
            Text(String(format: "%.1f ℃", value))
                .monospacedDigit()
                .foregroundStyle(value > 90 ? .red : .primary)
                .gridColumnAlignment(.trailing)
        }
    }
}
