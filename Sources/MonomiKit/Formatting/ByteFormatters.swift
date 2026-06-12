import Foundation

public enum ByteFormat {
    /// 1024 基数で "1.2 GB" 形式に整形する
    public static func bytes(_ value: UInt64) -> String {
        let units = ["B", "KB", "MB", "GB", "TB"]
        var amount = Double(value)
        var unitIndex = 0
        while amount >= 1024, unitIndex < units.count - 1 {
            amount /= 1024
            unitIndex += 1
        }
        let digits = amount >= 100 || unitIndex == 0 ? 0 : 1
        return String(format: "%.\(digits)f %@", amount, units[unitIndex])
    }

    /// 転送レートを "3.4 MB/s" 形式に整形する
    public static func rate(_ bytesPerSecond: Double) -> String {
        bytes(UInt64(max(bytesPerSecond, 0))) + "/s"
    }

    public static func percent(_ fraction: Double) -> String {
        String(format: "%.0f%%", min(max(fraction, 0), 1) * 100)
    }
}
