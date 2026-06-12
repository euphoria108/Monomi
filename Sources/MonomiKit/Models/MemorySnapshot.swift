import Foundation

public struct MemorySnapshot: Sendable {
    public enum PressureLevel: Int, Sendable {
        case normal = 1
        case warning = 2
        case critical = 4
    }

    public let timestamp: Date
    /// 物理メモリ総量（バイト）
    public let total: UInt64
    /// アプリメモリ（anonymous - purgeable）
    public let app: UInt64
    public let wired: UInt64
    public let compressed: UInt64
    public let swapUsed: UInt64
    public let swapTotal: UInt64
    public let pressure: PressureLevel

    /// Activity Monitor の「使用済みメモリ」相当
    public var used: UInt64 { app + wired + compressed }
    public var usedFraction: Double {
        guard total > 0 else { return 0 }
        return Double(used) / Double(total)
    }

    public init(
        timestamp: Date,
        total: UInt64,
        app: UInt64,
        wired: UInt64,
        compressed: UInt64,
        swapUsed: UInt64,
        swapTotal: UInt64,
        pressure: PressureLevel
    ) {
        self.timestamp = timestamp
        self.total = total
        self.app = app
        self.wired = wired
        self.compressed = compressed
        self.swapUsed = swapUsed
        self.swapTotal = swapTotal
        self.pressure = pressure
    }
}
