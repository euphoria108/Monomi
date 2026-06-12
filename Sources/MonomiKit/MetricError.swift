import Foundation

public enum MetricError: Error, Sendable {
    case machCallFailed(name: String, code: Int32)
    case sysctlFailed(name: String, errno: Int32)
    case unavailable(String)
}
