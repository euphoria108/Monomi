import Foundation

public struct DiskSnapshot: Sendable {
    public struct Volume: Sendable, Identifiable {
        public var id: String { path }
        public let path: String
        public let name: String
        public let total: UInt64
        public let available: UInt64

        public var usedFraction: Double {
            guard total > 0 else { return 0 }
            return Double(total - min(available, total)) / Double(total)
        }

        public init(path: String, name: String, total: UInt64, available: UInt64) {
            self.path = path
            self.name = name
            self.total = total
            self.available = available
        }
    }

    public let timestamp: Date
    public let volumes: [Volume]
    public let readBytesPerSecond: Double
    public let writeBytesPerSecond: Double

    public init(
        timestamp: Date,
        volumes: [Volume],
        readBytesPerSecond: Double,
        writeBytesPerSecond: Double
    ) {
        self.timestamp = timestamp
        self.volumes = volumes
        self.readBytesPerSecond = readBytesPerSecond
        self.writeBytesPerSecond = writeBytesPerSecond
    }
}
