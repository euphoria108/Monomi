import MonomiKit
import SwiftUI

struct DiskDetailView: View {
    let store: MetricStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("ディスク")
                    .font(.headline)
                Spacer()
                if let disk = store.disk {
                    Text("R \(ByteFormat.rate(disk.readBytesPerSecond))  W \(ByteFormat.rate(disk.writeBytesPerSecond))")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }

            if let disk = store.disk {
                ForEach(disk.volumes) { volume in
                    VStack(alignment: .leading, spacing: 3) {
                        HStack {
                            Text(volume.name)
                                .font(.caption.weight(.medium))
                            Spacer()
                            Text("\(ByteFormat.bytes(volume.available)) 空き / \(ByteFormat.bytes(volume.total))")
                                .font(.caption2.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }
                        GeometryReader { proxy in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(.secondary.opacity(0.2))
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(volume.usedFraction > 0.9 ? Color.red : Color.blue)
                                    .frame(width: proxy.size.width * volume.usedFraction)
                            }
                        }
                        .frame(height: 6)
                    }
                }
            } else {
                Text("読み込み中…")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(width: 280)
    }
}
