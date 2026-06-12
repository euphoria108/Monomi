import Testing
@testable import MonomiKit

@Suite struct NetworkDeltaTests {
    @Test func normalDelta() {
        let rate = NetworkCollector.rate(previous: 1000, current: 3000, seconds: 2)
        #expect(rate == 1000)
    }

    @Test func counterResetClampsToZero() {
        // スリープ復帰・カウンタリセットで current < previous になったら 0
        let rate = NetworkCollector.rate(previous: 5000, current: 100, seconds: 2)
        #expect(rate == 0)
    }

    @Test func zeroElapsedClampsToZero() {
        let rate = NetworkCollector.rate(previous: 0, current: 1000, seconds: 0)
        #expect(rate == 0)
    }

    @Test func liveCountersAreReadable() async throws {
        let collector = await NetworkCollector()
        let first = try await collector.sample()
        #expect(first == nil)  // 初回はベースラインのみ

        try await Task.sleep(for: .milliseconds(200))
        let snapshot = try await collector.sample()
        let unwrapped = try #require(snapshot)
        #expect(unwrapped.downloadBytesPerSecond >= 0)
        #expect(unwrapped.uploadBytesPerSecond >= 0)
    }

    @Test @MetricsActor func diskCollectorReturnsVolumes() {
        let collector = DiskCollector()
        let snapshot = collector.sample()
        #expect(!snapshot.volumes.isEmpty)
        for volume in snapshot.volumes {
            #expect(volume.total > 0)
            #expect(volume.available <= volume.total)
        }
    }
}
