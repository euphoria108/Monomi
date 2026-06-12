import MonomiKit
import SwiftUI

struct SensorLabelView: View {
    let store: MetricStore

    private var temperature: Double? { store.sensors?.cpuTemperature }

    private var color: Color {
        guard let temperature else { return .secondary }
        switch temperature {
        case ..<70: return .primary
        case ..<90: return .orange
        default: return .red
        }
    }

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "thermometer.medium")
                .font(.system(size: 10))
                .foregroundStyle(color)
            Text(temperature.map { String(format: "%.0f°", $0) } ?? "–")
                .font(.system(size: 9, weight: .medium).monospacedDigit())
        }
        .padding(.horizontal, 2)
    }
}
