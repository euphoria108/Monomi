import Foundation
import Testing
@testable import MonomiKit

/// 実ホストでコレクターが妥当な値を返すことのスモークテスト
@Suite struct CollectorSmokeTests {
    @Test @MetricsActor func cpuCollectorReturnsSaneValues() async throws {
        let collector = CPUCollector()
        // 初回はベースラインがないため nil
        let first = try await collector.sample()
        #expect(first == nil)

        try await Task.sleep(for: .milliseconds(200))
        let snapshot = try await collector.sample()
        let unwrapped = try #require(snapshot)

        #expect(!unwrapped.cores.isEmpty)
        #expect((0...1).contains(unwrapped.totalUsage))
        for core in unwrapped.cores {
            #expect((0...1.001).contains(core.user + core.system + core.nice + core.idle))
        }
        #expect(unwrapped.loadAverage.count == 3)
        #expect(unwrapped.loadAverage[0] >= 0)
    }

    @Test @MetricsActor func memoryCollectorReturnsSaneValues() async throws {
        let collector = MemoryCollector()
        let snapshot = try await collector.sample()

        #expect(snapshot.total > 1 << 30)  // 1 GB 以上
        #expect(snapshot.used > 0)
        #expect(snapshot.used < snapshot.total * 2)
        #expect(snapshot.swapUsed <= snapshot.swapTotal || snapshot.swapTotal == 0)
    }

    @Test @MetricsActor func processCollectorFindsBusyProcesses() async throws {
        let collector = ProcessCollector()
        _ = await collector.sample()

        // CPU を確実に使うビジーループを回して検出させる
        let spinner = Task.detached {
            var x = 0.0
            let deadline = Date().addingTimeInterval(0.4)
            while Date() < deadline { x += sin(x) }
            return x
        }
        try await Task.sleep(for: .milliseconds(400))
        _ = await spinner.value

        let samples = await collector.sample(limit: 5)
        #expect(!samples.isEmpty)
        for sample in samples {
            #expect(sample.pid > 0)
            #expect(!sample.name.isEmpty)
            #expect(sample.cpuFraction > 0)
        }
    }
}
