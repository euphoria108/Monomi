import Foundation
import MonomiKit
import Observation

@MainActor
@Observable
final class MetricStore {
    private(set) var cpu: CPUSnapshot?
    private(set) var cpuHistory = RingBuffer<CPUSnapshot>(capacity: 120)
    private(set) var memory: MemorySnapshot?
    private(set) var memoryHistory = RingBuffer<MemorySnapshot>(capacity: 120)
    private(set) var topProcesses: [ProcessSample] = []

    private let scheduler = MetricScheduler()
    private var consumeTask: Task<Void, Never>?

    func start() {
        guard consumeTask == nil else { return }
        let scheduler = scheduler
        consumeTask = Task { [weak self] in
            for await event in scheduler.events {
                self?.apply(event)
            }
        }
        Task { @MetricsActor in
            scheduler.start()
        }
    }

    private func apply(_ event: MetricEvent) {
        switch event {
        case .cpu(let snapshot):
            cpu = snapshot
            cpuHistory.append(snapshot)
        case .memory(let snapshot):
            memory = snapshot
            memoryHistory.append(snapshot)
        case .processes(let samples):
            topProcesses = samples
        }
    }
}
