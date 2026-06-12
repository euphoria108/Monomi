/// スケジューラーから UI 層へ流れるメトリクス更新イベント
public enum MetricEvent: Sendable {
    case cpu(CPUSnapshot)
    case memory(MemorySnapshot)
    case processes([ProcessSample])
    case network(NetworkSnapshot)
    case disk(DiskSnapshot)
    case battery(BatterySnapshot)
    case sensors(SensorSnapshot)
}
