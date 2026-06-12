import AppKit
import MonomiKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var store: MetricStore?
    private var statusItemManager: StatusItemManager?
    private var lastInterval: Double = 2.0

    func applicationDidFinishLaunching(_ notification: Notification) {
        // swift run（バンドル外実行）でも Dock アイコンを出さない
        NSApp.setActivationPolicy(.accessory)

        let store = MetricStore()
        store.start()
        self.store = store
        statusItemManager = StatusItemManager(store: store)

        let interval = AppPreferences.shared.updateInterval
        if interval != lastInterval {
            store.setUpdateInterval(interval)
            lastInterval = interval
        }

        applyPreferences()
        observePreferences()

        // センサーは SMC が読めた場合だけ表示する（最初のスナップショット到着で判定）
        Task { @MainActor [weak self] in
            for _ in 0..<10 {
                try? await Task.sleep(for: .seconds(2))
                if store.sensors != nil {
                    self?.applyPreferences()
                    break
                }
            }
        }
    }

    private func visibleItems() -> [StatusItemManager.Item] {
        AppPreferences.shared.enabledItems.filter { item in
            switch item {
            case .battery: BatteryCollector.isBatteryPresent()
            case .sensors: store?.sensors != nil
            default: true
            }
        }
    }

    private func applyPreferences() {
        statusItemManager?.show(visibleItems())

        let interval = AppPreferences.shared.updateInterval
        if interval != lastInterval {
            store?.setUpdateInterval(interval)
            lastInterval = interval
        }
    }

    /// @Observable な AppPreferences の変更を監視して表示・間隔へ反映する
    private func observePreferences() {
        withObservationTracking {
            _ = AppPreferences.shared.enabledItems
            _ = AppPreferences.shared.updateInterval
        } onChange: { [weak self] in
            Task { @MainActor in
                guard let self else { return }
                self.applyPreferences()
                self.observePreferences()
            }
        }
    }
}
