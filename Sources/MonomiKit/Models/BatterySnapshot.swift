import Foundation

public struct BatterySnapshot: Sendable {
    public let timestamp: Date
    /// 0...1
    public let level: Double
    public let isCharging: Bool
    /// AC 電源接続中か
    public let isPluggedIn: Bool
    /// 残り時間（分）。算出中・非該当は nil
    public let minutesRemaining: Int?

    public init(
        timestamp: Date,
        level: Double,
        isCharging: Bool,
        isPluggedIn: Bool,
        minutesRemaining: Int?
    ) {
        self.timestamp = timestamp
        self.level = level
        self.isCharging = isCharging
        self.isPluggedIn = isPluggedIn
        self.minutesRemaining = minutesRemaining
    }
}
