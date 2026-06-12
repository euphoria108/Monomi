import CShims
import Darwin
import Foundation

/// CPU 使用率上位のプロセスを取得する。
/// root 権限なしでは自ユーザーのプロセスの task 情報しか読めない（v1 の既知の制限）。
@MetricsActor
public final class ProcessCollector {
    private struct Reading {
        let cpuTime: UInt64  // Mach absolute time
        let wallClock: UInt64
    }

    private var previous: [Int32: Reading] = [:]
    private let timebaseFactor: Double

    public init() {
        var timebase = mach_timebase_info_data_t()
        mach_timebase_info(&timebase)
        timebaseFactor = Double(timebase.numer) / Double(timebase.denom)
    }

    /// 前回呼び出しからの CPU 時間差分で上位プロセスを返す。初回は空配列。
    public func sample(limit: Int = 5) -> [ProcessSample] {
        let pidCount = proc_listallpids(nil, 0)
        guard pidCount > 0 else { return [] }

        var pids = [Int32](repeating: 0, count: Int(pidCount) * 2)
        let filled = proc_listallpids(&pids, Int32(pids.count) * Int32(MemoryLayout<Int32>.size))
        guard filled > 0 else { return [] }

        let now = mach_absolute_time()
        var current: [Int32: Reading] = [:]
        var samples: [ProcessSample] = []

        for pid in pids.prefix(Int(filled)) where pid > 0 {
            var info = proc_taskinfo()
            let size = Int32(MemoryLayout<proc_taskinfo>.size)
            guard proc_pidinfo(pid, PROC_PIDTASKINFO, 0, &info, size) == size else { continue }

            let cpuTime = info.pti_total_user &+ info.pti_total_system
            current[pid] = Reading(cpuTime: cpuTime, wallClock: now)

            guard let prev = previous[pid], cpuTime >= prev.cpuTime, now > prev.wallClock else {
                continue
            }
            let cpuDelta = Double(cpuTime - prev.cpuTime) * timebaseFactor
            let wallDelta = Double(now - prev.wallClock) * timebaseFactor
            let fraction = cpuDelta / wallDelta
            guard fraction > 0.001 else { continue }

            var nameBuffer = [CChar](repeating: 0, count: Int(MAXPATHLEN))
            proc_name(pid, &nameBuffer, UInt32(nameBuffer.count))
            let name = String(cString: nameBuffer)

            samples.append(ProcessSample(
                pid: pid,
                name: name.isEmpty ? "pid \(pid)" : name,
                cpuFraction: fraction
            ))
        }

        previous = current
        return Array(samples.sorted { $0.cpuFraction > $1.cpuFraction }.prefix(limit))
    }
}
