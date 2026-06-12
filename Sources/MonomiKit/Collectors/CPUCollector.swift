import Darwin
import Foundation

@MetricsActor
public final class CPUCollector {
    struct CoreTicks {
        var user: UInt32
        var system: UInt32
        var idle: UInt32
        var nice: UInt32
    }

    private var previous: [CoreTicks]?

    public init() {}

    /// 前回呼び出しからのティック差分で使用率を計算する。
    /// 初回はベースラインがないため nil を返す。
    public func sample() throws -> CPUSnapshot? {
        let current = try Self.readTicks()
        defer { previous = current }
        guard let previous, previous.count == current.count else { return nil }

        let cores = zip(previous, current).map { prev, cur -> CPUSnapshot.CoreUsage in
            // カウンタは 32bit でラップするため &- で差分を取る
            let user = Double(cur.user &- prev.user)
            let system = Double(cur.system &- prev.system)
            let idle = Double(cur.idle &- prev.idle)
            let nice = Double(cur.nice &- prev.nice)
            let totalTicks = user + system + idle + nice
            guard totalTicks > 0 else {
                return .init(user: 0, system: 0, nice: 0, idle: 1)
            }
            return .init(
                user: user / totalTicks,
                system: system / totalTicks,
                nice: nice / totalTicks,
                idle: idle / totalTicks
            )
        }

        var loads = [Double](repeating: 0, count: 3)
        getloadavg(&loads, 3)

        return CPUSnapshot(timestamp: Date(), cores: cores, loadAverage: loads)
    }

    private static func readTicks() throws -> [CoreTicks] {
        var cpuCount: natural_t = 0
        var info: processor_info_array_t?
        var infoCount: mach_msg_type_number_t = 0

        let kr = host_processor_info(
            mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &cpuCount, &info, &infoCount
        )
        guard kr == KERN_SUCCESS, let info else {
            throw MetricError.machCallFailed(name: "host_processor_info", code: kr)
        }
        defer {
            vm_deallocate(
                mach_task_self_,
                vm_address_t(UInt(bitPattern: info)),
                vm_size_t(Int(infoCount) * MemoryLayout<integer_t>.stride)
            )
        }

        return (0..<Int(cpuCount)).map { core in
            let base = core * Int(CPU_STATE_MAX)
            return CoreTicks(
                user: UInt32(bitPattern: info[base + Int(CPU_STATE_USER)]),
                system: UInt32(bitPattern: info[base + Int(CPU_STATE_SYSTEM)]),
                idle: UInt32(bitPattern: info[base + Int(CPU_STATE_IDLE)]),
                nice: UInt32(bitPattern: info[base + Int(CPU_STATE_NICE)])
            )
        }
    }
}
