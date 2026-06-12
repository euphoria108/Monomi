import Foundation
import IOKit.ps

@MetricsActor
public final class BatteryCollector {
    public init() {}

    /// バッテリー非搭載機（デスクトップ）は nil を返す
    public func sample() -> BatterySnapshot? {
        guard let info = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let list = IOPSCopyPowerSourcesList(info)?.takeRetainedValue() as? [CFTypeRef]
        else { return nil }

        for source in list {
            guard let description = IOPSGetPowerSourceDescription(info, source)?
                .takeUnretainedValue() as? [String: Any],
                description[kIOPSTypeKey] as? String == kIOPSInternalBatteryType,
                let current = description[kIOPSCurrentCapacityKey] as? Int,
                let max = description[kIOPSMaxCapacityKey] as? Int, max > 0
            else { continue }

            let isCharging = description[kIOPSIsChargingKey] as? Bool ?? false
            let state = description[kIOPSPowerSourceStateKey] as? String
            let isPluggedIn = state == kIOPSACPowerValue

            let minutes: Int? = {
                let key = isCharging ? kIOPSTimeToFullChargeKey : kIOPSTimeToEmptyKey
                guard let value = description[key] as? Int, value > 0 else { return nil }
                return value
            }()

            return BatterySnapshot(
                timestamp: Date(),
                level: Double(current) / Double(max),
                isCharging: isCharging,
                isPluggedIn: isPluggedIn,
                minutesRemaining: minutes
            )
        }
        return nil
    }

    /// 起動時の表示判定用（バッテリー搭載機かどうか）
    public nonisolated static func isBatteryPresent() -> Bool {
        guard let info = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let list = IOPSCopyPowerSourcesList(info)?.takeRetainedValue() as? [CFTypeRef]
        else { return false }

        return list.contains { source in
            guard let description = IOPSGetPowerSourceDescription(info, source)?
                .takeUnretainedValue() as? [String: Any] else { return false }
            return description[kIOPSTypeKey] as? String == kIOPSInternalBatteryType
        }
    }
}
