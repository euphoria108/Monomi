import Charts
import MonomiKit
import SwiftUI

struct NetworkDetailView: View {
    let store: MetricStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("ネットワーク")
                    .font(.headline)
                Spacer()
                if let interface = store.network?.primaryInterface {
                    Text(interface)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Chart(Array(store.networkHistory.elements.enumerated()), id: \.offset) { index, snapshot in
                LineMark(
                    x: .value("Sample", index),
                    y: .value("Down", snapshot.downloadBytesPerSecond / 1024),
                    series: .value("Kind", "Down")
                )
                .foregroundStyle(.blue)
                LineMark(
                    x: .value("Sample", index),
                    y: .value("Up", snapshot.uploadBytesPerSecond / 1024),
                    series: .value("Kind", "Up")
                )
                .foregroundStyle(.red)
            }
            .chartXAxis(.hidden)
            .chartYAxisLabel("KB/s")
            .frame(height: 80)

            if let network = store.network {
                Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 4) {
                    GridRow {
                        Label("ダウンロード", systemImage: "arrow.down")
                            .foregroundStyle(.blue)
                        Text(ByteFormat.rate(network.downloadBytesPerSecond))
                            .monospacedDigit()
                            .gridColumnAlignment(.trailing)
                    }
                    GridRow {
                        Label("アップロード", systemImage: "arrow.up")
                            .foregroundStyle(.red)
                        Text(ByteFormat.rate(network.uploadBytesPerSecond))
                            .monospacedDigit()
                            .gridColumnAlignment(.trailing)
                    }
                    Divider()
                    GridRow {
                        Text("セッション累計 (受信)")
                            .foregroundStyle(.secondary)
                        Text(ByteFormat.bytes(network.sessionReceived))
                            .monospacedDigit()
                            .gridColumnAlignment(.trailing)
                    }
                    GridRow {
                        Text("セッション累計 (送信)")
                            .foregroundStyle(.secondary)
                        Text(ByteFormat.bytes(network.sessionSent))
                            .monospacedDigit()
                            .gridColumnAlignment(.trailing)
                    }
                    if let ip = network.ipv4Address {
                        GridRow {
                            Text("IP アドレス")
                                .foregroundStyle(.secondary)
                            Text(ip)
                                .monospacedDigit()
                                .gridColumnAlignment(.trailing)
                        }
                    }
                }
                .font(.caption)
            }
        }
        .padding(14)
        .frame(width: 280)
    }
}
