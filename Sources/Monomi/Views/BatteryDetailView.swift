import MonomiKit
import SwiftUI

struct BatteryDetailView: View {
    let store: MetricStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("バッテリー")
                    .font(.headline)
                Spacer()
                if let battery = store.battery {
                    Text(ByteFormat.percent(battery.level))
                        .font(.title3.monospacedDigit())
                }
            }

            if let battery = store.battery {
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.secondary.opacity(0.2))
                        RoundedRectangle(cornerRadius: 4)
                            .fill(battery.level < 0.2 ? Color.red : Color.green)
                            .frame(width: proxy.size.width * battery.level)
                    }
                }
                .frame(height: 10)

                Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 4) {
                    GridRow {
                        Text("電源")
                            .foregroundStyle(.secondary)
                        Text(battery.isPluggedIn ? "AC 電源" : "バッテリー")
                            .gridColumnAlignment(.trailing)
                    }
                    GridRow {
                        Text("状態")
                            .foregroundStyle(.secondary)
                        Text(battery.isCharging ? "充電中" : battery.isPluggedIn ? "充電済み" : "放電中")
                            .gridColumnAlignment(.trailing)
                    }
                    if let minutes = battery.minutesRemaining {
                        GridRow {
                            Text(battery.isCharging ? "充電完了まで" : "残り時間")
                                .foregroundStyle(.secondary)
                            Text(String(format: "%d:%02d", minutes / 60, minutes % 60))
                                .monospacedDigit()
                                .gridColumnAlignment(.trailing)
                        }
                    }
                }
                .font(.caption)
            } else {
                Text("バッテリー情報なし")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(width: 260)
    }
}
