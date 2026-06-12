import Foundation

public struct CPUSnapshot: Sendable {
    public struct CoreUsage: Sendable {
        /// 各値は 0...1 の割合
        public let user: Double
        public let system: Double
        public let nice: Double
        public let idle: Double

        public var total: Double { min(max(user + system + nice, 0), 1) }

        public init(user: Double, system: Double, nice: Double, idle: Double) {
            self.user = user
            self.system = system
            self.nice = nice
            self.idle = idle
        }
    }

    public let timestamp: Date
    public let cores: [CoreUsage]
    /// 1 分・5 分・15 分のロードアベレージ
    public let loadAverage: [Double]

    public var totalUsage: Double {
        guard !cores.isEmpty else { return 0 }
        return cores.reduce(0) { $0 + $1.total } / Double(cores.count)
    }

    public var userUsage: Double {
        guard !cores.isEmpty else { return 0 }
        return cores.reduce(0) { $0 + $1.user + $1.nice } / Double(cores.count)
    }

    public var systemUsage: Double {
        guard !cores.isEmpty else { return 0 }
        return cores.reduce(0) { $0 + $1.system } / Double(cores.count)
    }

    public init(timestamp: Date, cores: [CoreUsage], loadAverage: [Double]) {
        self.timestamp = timestamp
        self.cores = cores
        self.loadAverage = loadAverage
    }
}
