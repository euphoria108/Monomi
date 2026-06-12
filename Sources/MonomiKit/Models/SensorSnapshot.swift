import Foundation

public struct SensorSnapshot: Sendable {
    public struct Fan: Sendable, Identifiable {
        public let id: Int
        public let rpm: Double
        public let minRPM: Double?
        public let maxRPM: Double?

        public init(id: Int, rpm: Double, minRPM: Double?, maxRPM: Double?) {
            self.id = id
            self.rpm = rpm
            self.minRPM = minRPM
            self.maxRPM = maxRPM
        }
    }

    public let timestamp: Date
    /// ℃
    public let cpuTemperature: Double?
    public let gpuTemperature: Double?
    public let fans: [Fan]

    public init(
        timestamp: Date,
        cpuTemperature: Double?,
        gpuTemperature: Double?,
        fans: [Fan]
    ) {
        self.timestamp = timestamp
        self.cpuTemperature = cpuTemperature
        self.gpuTemperature = gpuTemperature
        self.fans = fans
    }
}
