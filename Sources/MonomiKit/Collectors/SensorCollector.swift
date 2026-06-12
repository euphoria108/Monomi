import Foundation

@MetricsActor
public final class SensorCollector {
    private let client: SMCClient
    private let cpuKey: String?
    private let gpuKey: String?
    private let fanCount: Int

    /// SMC を開けない・有効なキーが 1 つもない場合は throw し、
    /// 呼び出し側（スケジューラー）がセンサー収集を無効化する。
    public init(catalog: SensorCatalog = IntelSensorCatalog()) throws {
        let smc = try SMCClient()

        func probe(_ keys: [String]) -> String? {
            keys.first { key in
                guard let value = try? smc.readDouble(key) else { return false }
                return Self.isPlausibleTemperature(value)
            }
        }
        client = smc
        cpuKey = probe(catalog.cpuTemperatureKeys)
        gpuKey = probe(catalog.gpuTemperatureKeys)
        fanCount = (try? smc.readDouble("FNum")).map { Int($0) } ?? 0

        guard cpuKey != nil || gpuKey != nil || fanCount > 0 else {
            throw SMCError.serviceNotFound
        }
    }

    public func sample() -> SensorSnapshot {
        let fans = (0..<fanCount).compactMap { index -> SensorSnapshot.Fan? in
            guard let rpm = try? client.readDouble("F\(index)Ac") else { return nil }
            return SensorSnapshot.Fan(
                id: index,
                rpm: rpm,
                minRPM: try? client.readDouble("F\(index)Mn"),
                maxRPM: try? client.readDouble("F\(index)Mx")
            )
        }

        return SensorSnapshot(
            timestamp: Date(),
            cpuTemperature: cpuKey.flatMap { try? client.readDouble($0) },
            gpuTemperature: gpuKey.flatMap { try? client.readDouble($0) },
            fans: fans
        )
    }

    static func isPlausibleTemperature(_ value: Double) -> Bool {
        value > 0 && value < 110
    }
}
