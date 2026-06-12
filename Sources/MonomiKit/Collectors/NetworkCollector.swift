import CShims
import Darwin
import Foundation
import SystemConfiguration

@MetricsActor
public final class NetworkCollector {
    struct Counters {
        var received: UInt64 = 0
        var sent: UInt64 = 0
    }

    private var previous: (counters: Counters, time: ContinuousClock.Instant)?
    private var baseline: Counters?

    public init() {}

    /// 前回呼び出しからのカウンタ差分でスループットを計算する。初回は nil。
    public func sample() throws -> NetworkSnapshot? {
        let current = try Self.readCounters()
        let now = ContinuousClock.now
        defer { previous = (current, now) }

        if baseline == nil { baseline = current }

        guard let previous else { return nil }
        let seconds = Double(previous.time.duration(to: now).components.seconds)
            + Double(previous.time.duration(to: now).components.attoseconds) / 1e18
        guard seconds > 0 else { return nil }

        let primary = Self.primaryInterfaceName()
        return NetworkSnapshot(
            timestamp: Date(),
            downloadBytesPerSecond: Self.rate(
                previous: previous.counters.received, current: current.received, seconds: seconds
            ),
            uploadBytesPerSecond: Self.rate(
                previous: previous.counters.sent, current: current.sent, seconds: seconds
            ),
            sessionReceived: current.received &- (baseline?.received ?? 0),
            sessionSent: current.sent &- (baseline?.sent ?? 0),
            primaryInterface: primary,
            ipv4Address: primary.flatMap(Self.ipv4Address(of:))
        )
    }

    /// スリープ復帰やカウンタリセットで負になった差分は 0 にクランプする
    nonisolated static func rate(previous: UInt64, current: UInt64, seconds: Double) -> Double {
        guard current >= previous, seconds > 0 else { return 0 }
        return Double(current - previous) / seconds
    }

    /// NET_RT_IFLIST2 で全インターフェースの 64bit カウンタを合算（ループバック除外）
    private static func readCounters() throws -> Counters {
        var mib: [Int32] = [CTL_NET, PF_ROUTE, 0, 0, NET_RT_IFLIST2, 0]
        var length = 0
        guard sysctl(&mib, u_int(mib.count), nil, &length, nil, 0) == 0 else {
            throw MetricError.sysctlFailed(name: "NET_RT_IFLIST2(size)", errno: errno)
        }
        var buffer = [UInt8](repeating: 0, count: length)
        guard sysctl(&mib, u_int(mib.count), &buffer, &length, nil, 0) == 0 else {
            throw MetricError.sysctlFailed(name: "NET_RT_IFLIST2", errno: errno)
        }

        var counters = Counters()
        buffer.withUnsafeBytes { raw in
            var offset = 0
            while offset + MemoryLayout<if_msghdr>.size <= length {
                let header = raw.loadUnaligned(fromByteOffset: offset, as: if_msghdr.self)
                guard header.ifm_msglen > 0 else { break }
                if Int32(header.ifm_type) == RTM_IFINFO2,
                   offset + MemoryLayout<if_msghdr2>.size <= length {
                    let header2 = raw.loadUnaligned(fromByteOffset: offset, as: if_msghdr2.self)
                    if header2.ifm_flags & IFF_LOOPBACK == 0 {
                        counters.received &+= header2.ifm_data.ifi_ibytes
                        counters.sent &+= header2.ifm_data.ifi_obytes
                    }
                }
                offset += Int(header.ifm_msglen)
            }
        }
        return counters
    }

    private static func primaryInterfaceName() -> String? {
        guard let value = SCDynamicStoreCopyValue(nil, "State:/Network/Global/IPv4" as CFString),
              let dict = value as? [String: Any] else { return nil }
        return dict["PrimaryInterface"] as? String
    }

    private static func ipv4Address(of interface: String) -> String? {
        var addrs: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&addrs) == 0 else { return nil }
        defer { freeifaddrs(addrs) }

        var pointer = addrs
        while let current = pointer {
            defer { pointer = current.pointee.ifa_next }
            guard let addr = current.pointee.ifa_addr,
                  addr.pointee.sa_family == sa_family_t(AF_INET),
                  String(cString: current.pointee.ifa_name) == interface else { continue }

            var host = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            if getnameinfo(
                addr, socklen_t(addr.pointee.sa_len),
                &host, socklen_t(host.count), nil, 0, NI_NUMERICHOST
            ) == 0 {
                return String(cString: host)
            }
        }
        return nil
    }
}
