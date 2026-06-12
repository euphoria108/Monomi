import MonomiKit
import SwiftUI

struct BatteryLabelView: View {
    let store: MetricStore

    private var level: Double { store.battery?.level ?? 0 }

    private var symbolName: String {
        guard let battery = store.battery else { return "battery.0percent" }
        if battery.isCharging { return "battery.100percent.bolt" }
        switch battery.level {
        case ..<0.25: return "battery.25percent"
        case ..<0.5: return "battery.50percent"
        case ..<0.75: return "battery.75percent"
        default: return "battery.100percent"
        }
    }

    private var color: Color {
        guard let battery = store.battery else { return .secondary }
        if battery.isCharging { return .green }
        return battery.level < 0.2 ? .red : .primary
    }

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: symbolName)
                .font(.system(size: 11))
                .foregroundStyle(color)
            Text(ByteFormat.percent(level))
                .font(.system(size: 9, weight: .medium).monospacedDigit())
        }
        .padding(.horizontal, 2)
    }
}
