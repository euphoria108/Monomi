import Foundation

public struct ProcessSample: Sendable, Identifiable {
    public var id: Int32 { pid }
    public let pid: Int32
    public let name: String
    /// CPU 使用率（1 コア占有 = 1.0。Activity Monitor の % CPU / 100 相当）
    public let cpuFraction: Double

    public init(pid: Int32, name: String, cpuFraction: Double) {
        self.pid = pid
        self.name = name
        self.cpuFraction = cpuFraction
    }
}
