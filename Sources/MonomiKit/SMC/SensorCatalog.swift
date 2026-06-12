/// 機種ごとの SMC キーカタログ。優先順に並べ、起動時に妥当値を返すキーを採用する。
public protocol SensorCatalog: Sendable {
    var cpuTemperatureKeys: [String] { get }
    var gpuTemperatureKeys: [String] { get }
}

/// Intel Mac の古典的キー
public struct IntelSensorCatalog: SensorCatalog {
    public let cpuTemperatureKeys = ["TC0P", "TC0D", "TC0E", "TC0F"]
    public let gpuTemperatureKeys = ["TG0P", "TG0D"]

    public init() {}
}

/// Apple Silicon 用スタブ（v2 で実装）。
/// AppleSMC が公開する温度キーは少なく、HID センサー（AppleSMC 外）への
/// フォールバックが必要になる。TODO: IOHIDEventSystemClient 経由の実装
public struct AppleSiliconSensorCatalog: SensorCatalog {
    public let cpuTemperatureKeys = ["Tp01", "Tp05", "Tp0D", "Tp0H"]
    public let gpuTemperatureKeys = ["Tg05", "Tg0D"]

    public init() {}
}
