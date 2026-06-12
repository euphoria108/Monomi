import Foundation

/// コレクターを周期実行し、結果を AsyncStream で配信する。
/// コレクター呼び出しはすべて MetricsActor 上で行う。
@MetricsActor
public final class MetricScheduler {
    public nonisolated let events: AsyncStream<MetricEvent>
    private nonisolated let continuation: AsyncStream<MetricEvent>.Continuation

    private var pollers: [Task<Void, Never>] = []

    public nonisolated init() {
        (events, continuation) = AsyncStream.makeStream(of: MetricEvent.self)
    }

    public func start(
        fastInterval: Duration = .seconds(2),
        slowInterval: Duration = .seconds(5)
    ) {
        stop()

        let cpu = CPUCollector()
        let memory = MemoryCollector()
        let process = ProcessCollector()
        let network = NetworkCollector()
        let disk = DiskCollector()
        let battery = BatteryCollector()
        // SMC を開けない環境（Apple Silicon の一部キー欠如等）ではセンサー収集を無効化
        let sensors = try? SensorCollector()
        let continuation = continuation

        pollers.append(Task { @MetricsActor in
            while !Task.isCancelled {
                if let snapshot = try? cpu.sample() {
                    continuation.yield(.cpu(snapshot))
                }
                if let snapshot = try? memory.sample() {
                    continuation.yield(.memory(snapshot))
                }
                if let snapshot = try? network.sample() {
                    continuation.yield(.network(snapshot))
                }
                try? await Task.sleep(for: fastInterval)
            }
        })

        pollers.append(Task { @MetricsActor in
            while !Task.isCancelled {
                let samples = process.sample(limit: 5)
                if !samples.isEmpty {
                    continuation.yield(.processes(samples))
                }
                continuation.yield(.disk(disk.sample()))
                if let snapshot = battery.sample() {
                    continuation.yield(.battery(snapshot))
                }
                if let sensors {
                    continuation.yield(.sensors(sensors.sample()))
                }
                try? await Task.sleep(for: slowInterval)
            }
        })
    }

    public func stop() {
        pollers.forEach { $0.cancel() }
        pollers.removeAll()
    }
}
