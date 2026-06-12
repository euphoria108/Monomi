import Darwin
import Foundation

@MetricsActor
public final class MemoryCollector {
    private let totalMemory: UInt64
    private let pageSize: UInt64

    public init() {
        var memsize: UInt64 = 0
        var size = MemoryLayout<UInt64>.size
        sysctlbyname("hw.memsize", &memsize, &size, nil, 0)
        totalMemory = memsize

        var pages: vm_size_t = 0
        host_page_size(mach_host_self(), &pages)
        pageSize = UInt64(pages)
    }

    public func sample() throws -> MemorySnapshot {
        var stats = vm_statistics64_data_t()
        var count = mach_msg_type_number_t(
            MemoryLayout<vm_statistics64_data_t>.stride / MemoryLayout<integer_t>.stride
        )
        let kr = withUnsafeMutablePointer(to: &stats) { ptr in
            ptr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        guard kr == KERN_SUCCESS else {
            throw MetricError.machCallFailed(name: "host_statistics64", code: kr)
        }

        // Activity Monitor 準拠: アプリメモリ = anonymous(internal) - purgeable
        let appPages = stats.internal_page_count >= stats.purgeable_count
            ? stats.internal_page_count - stats.purgeable_count
            : 0
        let app = UInt64(appPages) * pageSize
        let wired = UInt64(stats.wire_count) * pageSize
        let compressed = UInt64(stats.compressor_page_count) * pageSize

        var swap = xsw_usage()
        var swapSize = MemoryLayout<xsw_usage>.size
        if sysctlbyname("vm.swapusage", &swap, &swapSize, nil, 0) != 0 {
            throw MetricError.sysctlFailed(name: "vm.swapusage", errno: errno)
        }

        var level: UInt32 = 1
        var levelSize = MemoryLayout<UInt32>.size
        sysctlbyname("kern.memorystatus_vm_pressure_level", &level, &levelSize, nil, 0)
        let pressure = MemorySnapshot.PressureLevel(rawValue: Int(level)) ?? .normal

        return MemorySnapshot(
            timestamp: Date(),
            total: totalMemory,
            app: app,
            wired: wired,
            compressed: compressed,
            swapUsed: swap.xsu_used,
            swapTotal: swap.xsu_total,
            pressure: pressure
        )
    }
}
