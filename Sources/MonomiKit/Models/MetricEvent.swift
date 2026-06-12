/// スケジューラーから UI 層へ流れるメトリクス更新イベント
public enum MetricEvent: Sendable {
    case cpu(CPUSnapshot)
    case memory(MemorySnapshot)
    case processes([ProcessSample])
}
