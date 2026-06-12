import Foundation

public struct NetworkSnapshot: Sendable {
    public let timestamp: Date
    public let downloadBytesPerSecond: Double
    public let uploadBytesPerSecond: Double
    /// アプリ起動以降の累計
    public let sessionReceived: UInt64
    public let sessionSent: UInt64
    public let primaryInterface: String?
    public let ipv4Address: String?

    public init(
        timestamp: Date,
        downloadBytesPerSecond: Double,
        uploadBytesPerSecond: Double,
        sessionReceived: UInt64,
        sessionSent: UInt64,
        primaryInterface: String?,
        ipv4Address: String?
    ) {
        self.timestamp = timestamp
        self.downloadBytesPerSecond = downloadBytesPerSecond
        self.uploadBytesPerSecond = uploadBytesPerSecond
        self.sessionReceived = sessionReceived
        self.sessionSent = sessionSent
        self.primaryInterface = primaryInterface
        self.ipv4Address = ipv4Address
    }
}
