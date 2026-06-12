import Foundation
import IOKit

@MetricsActor
public final class DiskCollector {
    private var previous: (read: UInt64, written: UInt64, time: ContinuousClock.Instant)?

    public init() {}

    public func sample() -> DiskSnapshot {
        let volumes = Self.readVolumes()
        let (read, written) = Self.readIOTotals()
        let now = ContinuousClock.now
        defer { previous = (read, written, now) }

        var readRate = 0.0
        var writeRate = 0.0
        if let previous {
            let duration = previous.time.duration(to: now)
            let seconds = Double(duration.components.seconds)
                + Double(duration.components.attoseconds) / 1e18
            readRate = NetworkCollector.rate(previous: previous.read, current: read, seconds: seconds)
            writeRate = NetworkCollector.rate(previous: previous.written, current: written, seconds: seconds)
        }

        return DiskSnapshot(
            timestamp: Date(),
            volumes: volumes,
            readBytesPerSecond: readRate,
            writeBytesPerSecond: writeRate
        )
    }

    private static func readVolumes() -> [DiskSnapshot.Volume] {
        let keys: [URLResourceKey] = [
            .volumeNameKey, .volumeTotalCapacityKey,
            .volumeAvailableCapacityForImportantUsageKey, .volumeIsBrowsableKey,
        ]
        let urls = FileManager.default.mountedVolumeURLs(
            includingResourceValuesForKeys: keys, options: [.skipHiddenVolumes]
        ) ?? []

        return urls.compactMap { url in
            guard let values = try? url.resourceValues(forKeys: Set(keys)),
                  values.volumeIsBrowsable == true,
                  let total = values.volumeTotalCapacity, total > 0 else { return nil }
            return DiskSnapshot.Volume(
                path: url.path,
                name: values.volumeName ?? url.lastPathComponent,
                total: UInt64(total),
                available: UInt64(max(values.volumeAvailableCapacityForImportantUsage ?? 0, 0))
            )
        }
    }

    /// IOBlockStorageDriver の Statistics を全ドライバ分合算する
    private static func readIOTotals() -> (read: UInt64, written: UInt64) {
        var iterator = io_iterator_t()
        guard IOServiceGetMatchingServices(
            kIOMainPortDefault,
            IOServiceMatching("IOBlockStorageDriver"),
            &iterator
        ) == KERN_SUCCESS else { return (0, 0) }
        defer { IOObjectRelease(iterator) }

        var read: UInt64 = 0
        var written: UInt64 = 0
        while case let service = IOIteratorNext(iterator), service != 0 {
            defer { IOObjectRelease(service) }
            guard let property = IORegistryEntryCreateCFProperty(
                service, "Statistics" as CFString, kCFAllocatorDefault, 0
            )?.takeRetainedValue(), let stats = property as? [String: Any] else { continue }

            read &+= (stats["Bytes (Read)"] as? NSNumber)?.uint64Value ?? 0
            written &+= (stats["Bytes (Write)"] as? NSNumber)?.uint64Value ?? 0
        }
        return (read, written)
    }
}
