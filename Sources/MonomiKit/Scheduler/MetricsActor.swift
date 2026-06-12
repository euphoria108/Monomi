/// メトリクス収集専用の global actor。
/// Mach / IOKit / sysctl のブロッキング C 呼び出しを MainActor から隔離する。
@globalActor
public actor MetricsActor {
    public static let shared = MetricsActor()
}
